//
//  HelpView.swift
//  Fondy
//
//  FAQ & Help chat — same UX as ChatView but powered by a local
//  knowledge base instead of the AI analysis service.
//
//  Usage (drop-in anywhere):
//      @State private var help = HelpViewModel()
//      HelpView(viewModel: help)
//

import SwiftUI

// MARK: - Help View

struct HelpView: View {
    @Bindable var viewModel: HelpViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            messageList
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            inputArea
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            // Title + subtitle
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text("Help Center")
                        .font(.headline)
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                Text("How can we help you today?")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.sm) {
                // Clear button — only when conversation has started
                if !viewModel.messages.isEmpty {
                    Button {
                        Haptics.light()
                        withAnimation(.springGentle) { viewModel.clear() }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(FondyColors.labelSecondary)
                            .frame(width: 34, height: 34)
                            .liquidGlass(cornerRadius: 12)
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel("Clear conversation")
                }

                // Escalate to human support
                Button {
                    Haptics.medium()
                    withAnimation(.springGentle) { viewModel.escalateToSupport() }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "person.fill")
                            .font(.caption.weight(.semibold))
                            .accessibilityHidden(true)
                        Text("Support")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .liquidGlass(tint: .blue, cornerRadius: 50)
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .accessibilityLabel("Talk to a support agent")
            }
            .animation(.springGentle, value: viewModel.messages.isEmpty)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    if viewModel.messages.isEmpty {
                        emptyState
                            .padding(.top, Spacing.xxxl)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    } else {
                        ForEach(viewModel.messages) { message in
                            HelpBubble(
                                message: message,
                                onFeedback: { id, isHelpful in
                                    viewModel.provideFeedback(messageId: id, isHelpful: isHelpful)
                                },
                                onRelatedTap: { faq in
                                    withAnimation(.springGentle) { viewModel.selectFAQ(faq) }
                                }
                            )
                            .transition(bubbleTransition(for: message))
                        }

                        if viewModel.isThinking {
                            HelpThinkingDotsView()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }

                        // Auto-scroll anchor
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                }
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.lg)
                .animation(.springGentle, value: viewModel.messages.count)
                .animation(.springGentle, value: viewModel.isThinking)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.messages.count) {
                withAnimation(.springGentle) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isThinking) {
                withAnimation(.springGentle) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.last?.content) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            // Icon hero
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.tint)
            }
            .accessibilityHidden(true)

            VStack(spacing: Spacing.sm) {
                Text("How can we help?")
                    .font(.title3.bold())
                    .foregroundStyle(FondyColors.labelPrimary)

                Text("Browse by topic or type your question\nand we'll find the answer instantly.")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            // Category chips (wrapping flow layout)
            HelpFlowLayout(spacing: Spacing.sm) {
                ForEach(FAQCategory.allCases) { category in
                    categoryChip(category)
                }
            }

            popularQuestionsSection
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.pageMargin)
    }

    private func categoryChip(_ category: FAQCategory) -> some View {
        Button {
            Haptics.selection()
            withAnimation(.springGentle) { viewModel.selectCategory(category) }
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(category.tint)
                    .accessibilityHidden(true)
                Text(category.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .liquidGlass(cornerRadius: 14)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("\(category.rawValue) category")
    }

    private var popularQuestionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Popular Questions")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: Spacing.sm) {
                ForEach(FAQKnowledgeBase.popular) { faq in
                    Button {
                        Haptics.light()
                        withAnimation(.springGentle) { viewModel.selectFAQ(faq) }
                    } label: {
                        HStack {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: faq.category.icon)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(faq.category.tint)
                                    .accessibilityHidden(true)
                                Text(faq.question)
                                    .font(.subheadline)
                                    .foregroundStyle(FondyColors.labelPrimary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(FondyColors.labelTertiary)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md)
                        .liquidGlass(cornerRadius: 14)
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                    .accessibilityLabel(faq.question)
                    .accessibilityHint("Double-tap to see the answer")
                }
            }
        }
    }

    // MARK: - Input Area

    private var inputArea: some View {
        ChatInputBar(
            text: $viewModel.inputText,
            isDisabled: viewModel.isThinking
        ) {
            withAnimation(.springGentle) { viewModel.send() }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.md)
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Helpers

    private func bubbleTransition(for message: HelpMessage) -> AnyTransition {
        switch message.role {
        case .user:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity
            )
        case .bot:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .opacity
            )
        case .system:
            return .asymmetric(
                insertion: .scale(scale: 0.85).combined(with: .opacity),
                removal: .opacity
            )
        }
    }
}

// MARK: - Flow Layout

/// Wrapping layout for category chips — identical algorithm to ChatFlowLayout.
private struct HelpFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: height + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Previews

#Preview("Empty state") {
    HelpView(viewModel: HelpViewModel())
}

#Preview("With conversation") {
    let vm = HelpViewModel()
    let faq = FAQKnowledgeBase.all.first!
    let _ = {
        vm.messages = [
            HelpMessage(role: .user, content: "How do I buy stocks?"),
            HelpMessage(
                role: .bot,
                content: faq.answer,
                relatedFAQs: faq.relatedIDs.compactMap { FAQKnowledgeBase.faq(by: $0) }
            ),
        ]
    }()
    HelpView(viewModel: vm)
}

#Preview("Thinking state") {
    let vm = HelpViewModel()
    let _ = {
        vm.messages = [HelpMessage(role: .user, content: "Is my money safe?")]
        vm.isThinking = true
    }()
    HelpView(viewModel: vm)
}

#Preview("System pill + feedback") {
    let vm = HelpViewModel()
    let _ = {
        vm.messages = [
            HelpMessage(role: .system, content: "Showing Security questions"),
            HelpMessage(
                role: .bot,
                content: "Your funds are protected on multiple levels:\n\n• SIPC insured up to $500,000\n• FDIC insured up to $250,000\n• 256-bit encryption",
                relatedFAQs: [
                    FAQ(id: "sec_2", category: .security, question: "How do I enable 2FA?", answer: "", relatedIDs: [])
                ]
            ),
        ]
    }()
    HelpView(viewModel: vm)
}

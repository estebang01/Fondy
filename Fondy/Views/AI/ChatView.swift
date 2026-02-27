//
//  ChatView.swift
//  Fondy
//
//  Claude-style chat experience embeddable inside any existing screen.
//  Self-contained: bring your own ChatViewModel instance.
//
//  Usage:
//      @State private var chat = ChatViewModel()
//      ChatView(viewModel: chat)
//

import SwiftUI

// MARK: - Chat View

/// A Claude-style conversational chat interface embeddable inside any screen.
///
/// Displays a message list, an animated thinking indicator, an aurora-glow
/// input bar, and an empty-state with suggestion chips when no messages exist.
struct ChatView: View {
    @Bindable var viewModel: ChatViewModel

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
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text("Fondy AI")
                        .font(.headline)
                        .foregroundStyle(FondyColors.labelPrimary)
                }

                Text("Portfolio insights at a glance")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer()

            if !viewModel.messages.isEmpty {
                Button {
                    Haptics.light()
                    withAnimation(.springGentle) {
                        viewModel.clear()
                    }
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
                            ChatBubble(message: message)
                                .transition(.asymmetric(
                                    insertion: .move(edge: message.role == .user ? .trailing : .leading)
                                        .combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }

                        if viewModel.isThinking {
                            ThinkingDotsView()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }

                        // Invisible anchor for auto-scroll
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
            // Auto-scroll when last message streams new content
            .onChange(of: viewModel.messages.last?.content) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.1))
                    .frame(width: 72, height: 72)

                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.tint)
            }
            .accessibilityHidden(true)

            VStack(spacing: Spacing.sm) {
                Text("Ask me anything")
                    .font(.title3.bold())
                    .foregroundStyle(FondyColors.labelPrimary)

                Text("Get instant insights about your portfolio,\nrisk, and investment strategy.")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            // Suggestion chips
            ChatFlowLayout(spacing: Spacing.sm) {
                ForEach(ChatViewModel.suggestions, id: \.text) { suggestion in
                    suggestionChip(suggestion)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.pageMargin)
    }

    private func suggestionChip(_ suggestion: (icon: String, text: String)) -> some View {
        Button {
            Haptics.selection()
            withAnimation(.springGentle) {
                viewModel.sendSuggestion(suggestion.text)
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: suggestion.icon)
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)

                Text(suggestion.text)
                    .font(.caption.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(FondyColors.labelPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .liquidGlass(cornerRadius: 14)
        }
        .buttonStyle(LiquidGlassButtonStyle())
    }

    // MARK: - Input Area

    private var inputArea: some View {
        ChatInputBar(
            text: $viewModel.inputText,
            isDisabled: viewModel.isThinking
        ) {
            withAnimation(.springGentle) {
                viewModel.send()
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.md)
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Flow Layout (wrapping chip grid)

/// A simple wrapping layout for suggestion chips that fills rows left-to-right.
private struct ChatFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Previews

#Preview("Empty") {
    ChatView(viewModel: ChatViewModel())
}

#Preview("With messages") {
    let vm = ChatViewModel()
    let _ = {
        vm.messages = [
            ChatMessage(role: .user, content: "How is my portfolio doing?"),
            ChatMessage(role: .assistant, content: "Here's what I found\n• Diversification across sectors can improve risk-adjusted returns.\n• Dollar-cost averaging helps reduce timing risk.\n\nYou might also explore:\n→ Review your monthly contribution plan\n→ Try the AI Portfolio Generator")
        ]
    }()
    ChatView(viewModel: vm)
}

#Preview("Thinking") {
    let vm = ChatViewModel()
    let _ = {
        vm.messages = [
            ChatMessage(role: .user, content: "Should I rebalance my portfolio?")
        ]
        vm.isThinking = true
    }()
    ChatView(viewModel: vm)
}

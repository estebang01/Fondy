//
//  HelpBubble.swift
//  Fondy
//
//  Three bubble variants for the Help chat module:
//   • User — right-aligned blue glass (identical to ChatBubble user)
//   • Bot  — left-aligned glass + streaming cursor + feedback bar + related Q chips
//   • System — centered pill (category notices, escalation events)
//

import SwiftUI

// MARK: - Help Bubble

struct HelpBubble: View {
    let message: HelpMessage
    var onFeedback: (UUID, Bool) -> Void
    var onRelatedTap: (FAQ) -> Void

    var body: some View {
        switch message.role {
        case .user:   userBubble
        case .bot:    botBubble
        case .system: systemPill
        }
    }

    // MARK: - User Bubble

    private var userBubble: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            Spacer(minLength: 48)
            Text(message.content)
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .lineSpacing(3)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .liquidGlass(tint: .blue, cornerRadius: 18)
        }
        .accessibilityLabel("You said: \(message.content)")
    }

    // MARK: - Bot Bubble

    private var botBubble: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            botAvatar

            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Text + streaming cursor
                botText

                // Feedback + related questions appear after streaming finishes
                if !message.isStreaming {
                    feedbackBar
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    if !message.relatedFAQs.isEmpty {
                        relatedQuestionsStrip
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }

            Spacer(minLength: 8)
        }
        .animation(.springGentle, value: message.isStreaming)
    }

    private var botText: some View {
        Text(message.content)
            .font(.subheadline)
            .foregroundStyle(FondyColors.labelPrimary)
            .multilineTextAlignment(.leading)
            .lineSpacing(3)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .liquidGlass(cornerRadius: 18)
            .overlay(
                Group {
                    if message.isStreaming {
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(FondyColors.labelSecondary)
                                .frame(width: 2, height: 14)
                                .modifier(HelpBlinkingCursorModifier())
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                    }
                }
            )
            .animation(.springGentle, value: message.content)
            .accessibilityLabel("Help bot: \(message.content)")
    }

    // MARK: - Feedback Bar

    private var feedbackBar: some View {
        HStack(spacing: Spacing.sm) {
            Text("Was this helpful?")
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)

            Spacer()

            thumbButton(isUp: true)
            thumbButton(isUp: false)
        }
        .padding(.horizontal, Spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Feedback for this answer")
    }

    private func thumbButton(isUp: Bool) -> some View {
        let isSelected = isUp
            ? message.feedbackState == .helpful
            : message.feedbackState == .notHelpful
        let icon = isUp
            ? (isSelected ? "hand.thumbsup.fill"   : "hand.thumbsup")
            : (isSelected ? "hand.thumbsdown.fill" : "hand.thumbsdown")
        let tintColor: Color = isUp ? .green : .red

        return Button {
            onFeedback(message.id, isUp)
        } label: {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? tintColor : FondyColors.labelSecondary)
                .frame(width: 30, height: 30)
                .liquidGlass(
                    tint: isSelected ? tintColor : .clear,
                    cornerRadius: 9,
                    disabled: message.feedbackState != .none && !isSelected
                )
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .disabled(message.feedbackState != .none)
        .accessibilityLabel(isUp ? "Mark as helpful" : "Mark as not helpful")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Related Questions Strip

    private var relatedQuestionsStrip: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Related questions")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .padding(.horizontal, Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(message.relatedFAQs) { faq in
                        Button {
                            Haptics.light()
                            onRelatedTap(faq)
                        } label: {
                            Text(faq.question)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(FondyColors.labelPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .frame(maxWidth: 200, alignment: .leading)
                                .liquidGlass(cornerRadius: 12)
                        }
                        .buttonStyle(LiquidGlassButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
            }
        }
    }

    // MARK: - System Pill

    private var systemPill: some View {
        HStack {
            Spacer()
            Text(message.content)
                .font(.caption.weight(.medium))
                .foregroundStyle(FondyColors.labelSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(FondyColors.fillTertiary, in: Capsule())
            Spacer()
        }
        .accessibilityLabel(message.content)
    }

    // MARK: - Bot Avatar

    private var botAvatar: some View {
        Image(systemName: "questionmark.circle.fill")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.tint)
            .frame(width: 28, height: 28)
            .liquidGlass(cornerRadius: 10)
            .accessibilityHidden(true)
    }
}

// MARK: - Blinking Cursor Modifier

struct HelpBlinkingCursorModifier: ViewModifier {
    @State private var visible = true

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
    }
}

// MARK: - Help Thinking Dots

/// Thinking indicator using the Help bot avatar (questionmark) instead of sparkles.
struct HelpThinkingDotsView: View {
    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tint)
                .frame(width: 28, height: 28)
                .liquidGlass(cornerRadius: 10)
                .accessibilityHidden(true)

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(FondyColors.labelTertiary)
                        .frame(width: 7, height: 7)
                        .scaleEffect(animating ? 1.3 : 0.8)
                        .opacity(animating ? 1 : 0.45)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .liquidGlass(cornerRadius: 18)

            Spacer(minLength: 48)
        }
        .onAppear { animating = true }
        .accessibilityLabel("Help bot is typing")
    }
}

// MARK: - Previews

#Preview("User Bubble") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        HelpBubble(
            message: HelpMessage(role: .user, content: "How do I buy stocks?"),
            onFeedback: { _, _ in },
            onRelatedTap: { _ in }
        )
        .padding()
    }
}

#Preview("Bot Bubble with Feedback") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        HelpBubble(
            message: HelpMessage(
                role: .bot,
                content: "Buying stocks on Fondy is straightforward:\n\n1. Tap the search bar or browse the Stocks tab\n2. Find the stock you want\n3. Tap \"Buy\" and enter your amount\n4. Review and confirm",
                relatedFAQs: [
                    FAQ(id: "port_2", category: .portfolio, question: "What are the trading hours?", answer: "", relatedIDs: []),
                    FAQ(id: "pay_1",  category: .payments,  question: "How do I add money to my account?", answer: "", relatedIDs: []),
                ]
            ),
            onFeedback: { _, _ in },
            onRelatedTap: { _ in }
        )
        .padding()
    }
}

#Preview("System Pill") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        HelpBubble(
            message: HelpMessage(role: .system, content: "Showing Portfolio questions"),
            onFeedback: { _, _ in },
            onRelatedTap: { _ in }
        )
        .padding()
    }
}

#Preview("Thinking Dots") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        HelpThinkingDotsView()
            .padding()
    }
}

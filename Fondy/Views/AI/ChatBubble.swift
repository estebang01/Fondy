//
//  ChatBubble.swift
//  Fondy
//
//  Individual chat bubble for user and assistant messages,
//  plus the animated thinking-dots indicator.
//

import SwiftUI

// MARK: - Chat Bubble

/// Renders a single chat message as a left- or right-aligned glass bubble.
struct ChatBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            if isUser {
                Spacer(minLength: 48)
                bubbleContent
            } else {
                assistantAvatar
                bubbleContent
                Spacer(minLength: 48)
            }
        }
    }

    // MARK: - Bubble Content

    private var bubbleContent: some View {
        Text(message.content)
            .font(.subheadline)
            .foregroundStyle(isUser ? .white : FondyColors.labelPrimary)
            .multilineTextAlignment(isUser ? .trailing : .leading)
            .lineSpacing(3)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .liquidGlass(
                tint: isUser ? .blue : .clear,
                cornerRadius: 18,
                disabled: false
            )
            .overlay(
                // Streaming cursor at end of assistant message
                Group {
                    if message.isStreaming && message.role == .assistant {
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(FondyColors.labelSecondary)
                                .frame(width: 2, height: 14)
                                .blinkingStreamCursor()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                    }
                }
            )
            .animation(.springGentle, value: message.content)
    }

    // MARK: - Assistant Avatar

    private var assistantAvatar: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.tint)
            .frame(width: 28, height: 28)
            .liquidGlass(cornerRadius: 10)
            .accessibilityHidden(true)
    }
}

// MARK: - Thinking Dots View

/// Three animated dots indicating the assistant is composing a response.
struct ThinkingDotsView: View {
    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            assistantAvatar

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
    }

    private var assistantAvatar: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.tint)
            .frame(width: 28, height: 28)
            .liquidGlass(cornerRadius: 10)
            .accessibilityHidden(true)
    }
}

// MARK: - Blinking Stream Cursor Modifier

private struct BlinkingStreamCursorModifier: ViewModifier {
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

private extension View {
    func blinkingStreamCursor() -> some View {
        modifier(BlinkingStreamCursorModifier())
    }
}

// MARK: - Previews

#Preview("User Bubble") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ChatBubble(message: ChatMessage(
            role: .user,
            content: "How is my portfolio performing this month?"
        ))
        .padding()
    }
}

#Preview("Assistant Bubble") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ChatBubble(message: ChatMessage(
            role: .assistant,
            content: "Here's what I found\n• Diversification across sectors can improve risk-adjusted returns.\n• Dollar-cost averaging helps reduce timing risk."
        ))
        .padding()
    }
}

#Preview("Thinking Dots") {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ThinkingDotsView()
            .padding()
    }
}

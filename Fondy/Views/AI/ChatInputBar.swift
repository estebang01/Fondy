//
//  ChatInputBar.swift
//  Fondy
//
//  Aurora-glow input bar for the chat module.
//  Mirrors the aesthetic of AIQueryBar with submit-on-return support.
//

import SwiftUI

// MARK: - Chat Input Bar

/// Floating input bar with aurora glow for the chat experience.
///
/// Exposes a text binding and a send action. Disables the send button
/// while `isDisabled` is true (e.g., during streaming).
struct ChatInputBar: View {
    @Binding var text: String
    var isDisabled: Bool
    var onSend: () -> Void

    @FocusState private var isFocused: Bool
    @State private var rotateAurora = false

    private let cornerRadius: CGFloat = 28

    private var auroraGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                Color.cyan,
                Color.pink,
                Color.purple,
                Color.orange,
                Color.cyan
            ]),
            center: .center
        )
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Sparkle icon
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            // Text input
            TextField("Ask anything about your portfolio…", text: $text, axis: .vertical)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(1...5)
                .submitLabel(.send)
                .onSubmit {
                    guard !isDisabled else { return }
                    Haptics.medium()
                    onSend()
                }

            // Send button
            Button {
                Haptics.medium()
                isFocused = false
                onSend()
            } label: {
                ZStack {
                    Circle()
                        .fill(.tint.opacity(isDisabled ? 0.08 : 0.15))
                        .frame(width: 28, height: 28)

                    if isDisabled {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.mini)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tint)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isDisabled || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .animation(.springInteractive, value: isDisabled)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        // Glass surface
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        // Inner border
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.6)
        )
        // Aurora outer glow
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(auroraGradient, lineWidth: 2)
                .blur(radius: 14)
                .opacity(0.35)
                .blendMode(.plusLighter)
                .rotationEffect(.degrees(rotateAurora ? 360 : 0))
                .animation(.linear(duration: 36).repeatForever(autoreverses: false), value: rotateAurora)
                .allowsHitTesting(false)
        )
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .onAppear {
            rotateAurora = true
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        StatefulPreviewWrapper("") { text in
            ChatInputBar(text: text, isDisabled: false) {}
                .padding()
        }
    }
}

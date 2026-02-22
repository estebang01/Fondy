import SwiftUI

// MARK: - AI Query Bar

/// A floating, playful AI query bar that sits above content and provides
/// a text field with an Analysis button. Uses materials and subtle motion
/// to feel lightweight and premium.
struct AIQueryBar: View {
    @Binding var text: String
    @Binding var isLoading: Bool
    var onAnalyze: () -> Void
    var autoFocus: Bool = true
    var onClose: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            TextField("Message GPT-5", text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelPrimary)
                .submitLabel(.go)

            Button {
                Haptics.medium()
                onAnalyze()
            } label: {
                ZStack {
                    Circle()
                        .fill(.tint.opacity(0.15))
                        .frame(width: 28, height: 28)
                    if isLoading {
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
            .animation(.springInteractive, value: isLoading)
            .accessibilityLabel("Send")

            if let onClose {
                Button {
                    Haptics.light()
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(FondyColors.labelTertiary)
                        .padding(.leading, Spacing.xs)
                        .accessibilityLabel("Close AI bar")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .glassEffect(.regular.interactive(), in: .capsule)
        .overlay(
            Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.6)
        )
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(.springInteractive, value: isHovering)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.springGentle) { isHovering = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.springGentle) { isHovering = false }
                }
            }
            if autoFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isFocused = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StatefulPreviewWrapper("") { text in
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            AIQueryBar(text: text, isLoading: .constant(false)) {}
        }
        .padding()
    }
}

// Helper for previews to bind simple values
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View { content($value) }
}


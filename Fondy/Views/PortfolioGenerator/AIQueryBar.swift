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
    @State private var rotateAurora = false

    private let cornerRadius: CGFloat = 26

    private var auroraGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.7),
                Color.pink.opacity(0.6),
                Color.orange.opacity(0.7),
                Color.blue.opacity(0.8) // close the loop for smoothness
            ]),
            center: .center
        )
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Gradient sparkles icon
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.purple, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.blue.opacity(0.3), radius: 2)
                .accessibilityHidden(true)

            TextField("Ask AI anything...", text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .submitLabel(.send)
                .onSubmit {
                    onAnalyze()
                }

            // Send button with improved styling
            Button {
                Haptics.medium()
                onAnalyze()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.blue.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.mini)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
            .accessibilityLabel("Send message")
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)

            if let onClose {
                Button {
                    Haptics.light()
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FondyColors.labelSecondary)
                        .frame(width: 28, height: 28)
                        .accessibilityLabel("Close AI assistant")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, 12)
        // Glassmorphism container with improved material
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        // Enhanced border with gradient
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        // Refined aurora outer glow
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(auroraGradient, lineWidth: 1.5)
                .blur(radius: 12)
                .opacity(0.4)
                .blendMode(.plusLighter)
                .rotationEffect(.degrees(rotateAurora ? 360 : 0))
                .animation(.linear(duration: 25).repeatForever(autoreverses: false), value: rotateAurora)
                .allowsHitTesting(false)
        )
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        .shadow(color: Color.blue.opacity(0.15), radius: 20, x: 0, y: 8)
        .scaleEffect(isHovering ? 1.01 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isHovering)
        .onAppear {
            // Subtle entrance bounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { 
                    isHovering = true 
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { 
                        isHovering = false 
                    }
                }
            }
            if autoFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isFocused = true
                }
            }
            // Start the slow, continuous aurora rotation
            rotateAurora = true
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


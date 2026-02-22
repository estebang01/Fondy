import SwiftUI

// MARK: - Rainbow Activity Indicator

/// A premium, Apple-like rainbow activity indicator.
/// A rotating angular gradient ring with subtle glow and motion.
struct RainbowActivityView: View {
    var size: CGFloat = 120
    var lineWidth: CGFloat = 10

    @State private var rotation: Double = 0
    @State private var pulse: Bool = false

    private var gradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [
                .blue, .purple, .pink, .orange, .yellow, .green, .cyan, .blue
            ]),
            center: .center
        )
    }

    var body: some View {
        ZStack {
            // Subtle base ring
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

            // Glow layer
            Circle()
                .trim(from: 0, to: 1)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .blur(radius: 10)
                .opacity(0.6)
                .rotationEffect(.degrees(rotation))

            // Main ring
            Circle()
                .trim(from: 0, to: 1)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(rotation))

            // Center sparkles for a touch of delight
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.18, weight: .semibold))
                .foregroundStyle(gradient)
                .symbolEffect(.pulse, options: .repeating, value: pulse)
                .accessibilityHidden(true)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        RainbowActivityView()
    }
}

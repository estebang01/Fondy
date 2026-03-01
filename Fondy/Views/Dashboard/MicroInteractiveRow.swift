import SwiftUI

struct MicroInteractiveRow: ViewModifier {
    // Configurable parameters
    var minimumDuration: Double = 0.38
    var pressedScale: CGFloat = 0.98
    var pressedHorizontalInset: CGFloat = 16
    var pressedVerticalInset: CGFloat = 2
    var pressedCornerRadius: CGFloat = 22

    // Layered shadow to mimic iOS lifted card
    var shadowPrimaryColor: Color = Color.black.opacity(0.12)
    var shadowPrimaryRadius: CGFloat = 18
    var shadowPrimaryY: CGFloat = 10

    var shadowSecondaryColor: Color = Color.black.opacity(0.04)
    var shadowSecondaryRadius: CGFloat = 6
    var shadowSecondaryY: CGFloat = 2

    // White during interaction (lifted card), clear at rest
    var pressedBackground: Color = Color(.systemBackground)

    // Keep the card look briefly after long press ends to match context menu presentation
    var holdAfterEnd: TimeInterval = 1.1

    @State private var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            // Breathing room around the lifted card
            .padding(.horizontal, isPressed ? pressedHorizontalInset : 0)
            .padding(.vertical, isPressed ? pressedVerticalInset : 0)
            // White card background with a subtle border while pressed
            .background(
                Group {
                    if isPressed {
                        RoundedRectangle(cornerRadius: pressedCornerRadius, style: .continuous)
                            .fill(pressedBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: pressedCornerRadius, style: .continuous)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                            )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: isPressed ? pressedCornerRadius : 0, style: .continuous))
            // Layered shadows for a natural lift
            .shadow(color: isPressed ? shadowPrimaryColor : .clear,
                    radius: isPressed ? shadowPrimaryRadius : 0,
                    x: 0,
                    y: isPressed ? shadowPrimaryY : 0)
            .shadow(color: isPressed ? shadowSecondaryColor : .clear,
                    radius: isPressed ? shadowSecondaryRadius : 0,
                    x: 0,
                    y: isPressed ? shadowSecondaryY : 0)
            .scaleEffect(isPressed ? pressedScale : 1.0)
            .zIndex(isPressed ? 100 : 0)
            .compositingGroup()
            .contentShape(Rectangle())
            .animation(.spring(response: 0.26, dampingFraction: 0.9), value: isPressed)
            // Detect context menu presentation
            .onLongPressGesture(minimumDuration: minimumDuration, pressing: { pressing in
                if pressing && !isPressed {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.88)) {
                        isPressed = true
                    }
                    triggerHaptic()
                } else if !pressing && isPressed {
                    // Context menu is being shown, hold the pressed state briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + holdAfterEnd) {
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.9)) {
                            isPressed = false
                        }
                    }
                }
            }, perform: {
                // This is called when long press completes
            })
    }

    private func triggerHaptic() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

extension View {
    func microInteractiveRow(
        minimumDuration: Double = 0.38,
        scale: CGFloat = 0.98,
        horizontalInset: CGFloat = 16,
        verticalInset: CGFloat = 2,
        cornerRadius: CGFloat = 22,
        holdAfterEnd: TimeInterval = 1.1
    ) -> some View {
        modifier(
            MicroInteractiveRow(
                minimumDuration: minimumDuration,
                pressedScale: scale,
                pressedHorizontalInset: horizontalInset,
                pressedVerticalInset: verticalInset,
                pressedCornerRadius: cornerRadius,
                holdAfterEnd: holdAfterEnd
            )
        )
    }
}

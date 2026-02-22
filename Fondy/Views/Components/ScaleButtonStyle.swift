import SwiftUI

/// A reusable button style that subtly scales the button when pressed.
/// Use via `.buttonStyle(ScaleButtonStyle())`.
public struct ScaleButtonStyle: ButtonStyle {
    /// The scale to apply when the button is pressed. Defaults to 0.96.
    public var pressedScale: CGFloat = 0.96

    public init(pressedScale: CGFloat = 0.96) {
        self.pressedScale = pressedScale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.2), value: configuration.isPressed)
    }
}

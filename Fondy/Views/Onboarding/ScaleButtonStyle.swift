//
//  ScaleButtonStyle.swift
//  Fondy
//
//  A lightweight button style that provides a subtle press-down scale effect.
//  Useful for plain buttons that already define their own background/tint.
//

import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    private let pressedScale: CGFloat
    private let animation: Animation

    public init(scale: CGFloat = 0.98, animation: Animation = .spring(response: 0.25, dampingFraction: 0.9)) {
        self.pressedScale = scale
        self.animation = animation
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}

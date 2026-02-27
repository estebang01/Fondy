//
//  PositiveButtonStyle.swift
//  Fondy
//
//  ButtonStyle for primary / affirmative actions:
//  confirm, save, continue, submit, sign up, log in.
//

import SwiftUI

// MARK: - PositiveButtonStyle

/// Primary action button with iOS 26 Liquid Glass treatment and a blue tint.
///
/// Encapsulates layout (full-width, standardized vertical padding),
/// visual chrome (Liquid Glass + tint), and press interaction (scale + brightness).
///
/// Usage:
/// ```swift
/// Button("Log in") { ... }
///     .buttonStyle(PositiveButtonStyle())
///     .disabled(!isFormValid)
/// ```
///
/// Capsule variant:
/// ```swift
/// Button("Got it") { ... }
///     .buttonStyle(PositiveButtonStyle(cornerRadius: 50))
/// ```
struct PositiveButtonStyle: ButtonStyle {

    // MARK: Configuration

    /// Corner radius of the glass container. Default 16 for rounded rect, 50 for pill/capsule.
    var cornerRadius: CGFloat = 16

    /// Tint color overlaid on the glass background. Default is `.blue`.
    var tint: Color = .blue

    // MARK: Environment

    @Environment(\.isEnabled) private var isEnabled

    // MARK: Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg + Spacing.xs)
            .liquidGlass(tint: tint, cornerRadius: cornerRadius, disabled: !isEnabled)
            // Press interaction: subtle scale + brightness shift
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            // Independent animations: press is snappy, enabled/disabled is gentle
            .animation(.spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.2), value: configuration.isPressed)
            .animation(.springGentle, value: isEnabled)
    }
}

//
//  NegativeButtonStyle.swift
//  Fondy
//
//  ButtonStyle for destructive / negative actions:
//  log out, delete, remove, cancel (destructive context).
//

import SwiftUI

// MARK: - NegativeButtonStyle

/// Destructive action button with iOS 26 Liquid Glass treatment and no tint.
///
/// Use for actions that are irreversible or have a destructive consequence.
/// The label is expected to use `FondyColors.negative` (system red) for foreground
/// to signal danger clearly to the user.
///
/// Encapsulates layout (full-width, standardized vertical padding),
/// visual chrome (Liquid Glass, no tint), and press interaction (scale + brightness).
///
/// Usage:
/// ```swift
/// Button("Log out") { ... }
///     .buttonStyle(NegativeButtonStyle())
/// ```
struct NegativeButtonStyle: ButtonStyle {

    // MARK: Configuration

    /// Corner radius of the glass container. Default 14 matches card radius.
    var cornerRadius: CGFloat = 14

    // MARK: Environment

    @Environment(\.isEnabled) private var isEnabled

    // MARK: Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg + Spacing.xs)
            .liquidGlass(cornerRadius: cornerRadius, disabled: !isEnabled)
            // Press interaction: subtle scale + brightness shift (matches Positive)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.2), value: configuration.isPressed)
            .animation(.springGentle, value: isEnabled)
    }
}

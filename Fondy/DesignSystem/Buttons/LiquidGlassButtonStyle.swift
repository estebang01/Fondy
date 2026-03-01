//
//  LiquidGlassButtonStyle.swift
//  Fondy
//
//  ButtonStyle for navigation and modal-control actions:
//  back, close, dismiss, return, secondary dismiss CTAs.
//

import SwiftUI

// MARK: - LiquidGlassButtonStyle

/// Navigation and modal-control button style providing the Liquid Glass
/// press interaction: a subtle scale and brightness shift.
///
/// This style handles **interaction only** — layout and visual chrome
/// (the `liquidGlass()` modifier, frame size, padding) are applied in the
/// label so that navigation buttons can have varied appearances:
/// icon-only circles, full-width secondary CTAs, pill badges, etc.
///
/// Usage — icon navigation button:
/// ```swift
/// Button { dismiss() } label: {
///     Image(systemName: "arrow.left")
///         .font(.title3.weight(.medium))
///         .foregroundStyle(FondyColors.labelPrimary)
///         .frame(width: 40, height: 40)
///         .liquidGlass(cornerRadius: 13)
/// }
/// .buttonStyle(LiquidGlassButtonStyle())
/// .accessibilityLabel("Go back")
/// ```
///
/// Usage — full-width secondary CTA:
/// ```swift
/// Button("Not now") { dismiss() }
///     .font(.headline)
///     .foregroundStyle(FondyColors.labelPrimary)
///     .frame(maxWidth: .infinity)
///     .padding(.vertical, Spacing.lg + Spacing.xs)
///     .liquidGlass(cornerRadius: 16)
/// ```
///
/// > Note: For primary / affirmative actions use `PositiveButtonStyle`.
/// > For destructive actions use `NegativeButtonStyle`.
struct LiquidGlassButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.2), value: configuration.isPressed)
    }
}

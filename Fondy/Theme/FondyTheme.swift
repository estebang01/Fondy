//
//  FondyTheme.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI

// MARK: - Spacing (8pt Grid System)

/// Apple HIG-aligned spacing constants based on the 8pt grid.
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32

    /// Standard horizontal page margin (HIG: 16–20pt).
    static let pageMargin: CGFloat = 20

    /// Standard section spacing between major content blocks.
    static let sectionGap: CGFloat = 28

    /// Standard icon/avatar size used throughout the app (HIG minimum touch target).
    static let iconSize: CGFloat = 44

    /// Leading inset for dividers that visually align after a standard icon (iconSize + md).
    static let iconDividerInset: CGFloat = 56

    /// Standard card corner radius used across all rounded cards.
    static let cardRadius: CGFloat = 14
}

// MARK: - Adaptive Colors

/// Semantic color palette that adapts to light/dark mode automatically.
enum FondyColors {
    // MARK: Surfaces

    /// Primary background — adapts to system background.
    static let background = Color(.systemBackground)

    /// Secondary grouped background for cards and sections.
    static let surfaceSecondary = Color(.secondarySystemGroupedBackground)

    /// Tertiary surface for nested elements.
    static let surfaceTertiary = Color(.tertiarySystemGroupedBackground)

    // MARK: Labels

    /// Primary text color.
    static let labelPrimary = Color(.label)

    /// Secondary text color for subtitles and metadata.
    static let labelSecondary = Color(.secondaryLabel)

    /// Tertiary text color for placeholders and hints.
    static let labelTertiary = Color(.tertiaryLabel)

    // MARK: Semantic

    /// Positive performance / gains — uses system green for automatic dark-mode adaptation.
    static let positive = Color(.systemGreen)

    /// Negative performance / losses — uses system red for automatic dark-mode adaptation.
    static let negative = Color(.systemRed)

    // MARK: Separators

    /// Standard separator color.
    static let separator = Color(.separator)

    // MARK: Fills

    /// Subtle fill for badges, pills, and inactive elements.
    static let fillTertiary = Color(.tertiarySystemFill)

    /// Quaternary fill for very subtle backgrounds.
    static let fillQuaternary = Color(.quaternarySystemFill)
}

// MARK: - Haptics

/// Centralized haptic feedback helpers.
enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Spring Animations

extension Animation {
    /// Standard interactive spring for button presses and micro-interactions.
    static let springInteractive = Animation.spring(
        response: 0.35,
        dampingFraction: 0.7
    )

    /// Gentle spring for content transitions and state changes.
    static let springGentle = Animation.spring(
        response: 0.45,
        dampingFraction: 0.85
    )
}

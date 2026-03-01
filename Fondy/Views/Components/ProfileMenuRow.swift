//
//  ProfileMenuRow.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import SwiftUI

struct ProfileMenuRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    var badgeCount: Int? = nil
    var action: () -> Void = {}

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            HStack(spacing: Spacing.md) {
                iconView
                titleStack
                Spacer(minLength: Spacing.sm)
                trailingContent
            }
            // Ensure the full row is tappable, not just the text
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Subviews

    private var iconView: some View {
        Image(systemName: iconName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(iconColor)
            // 36×36 container tinted with icon color for the Revolut-style pill icon
            .frame(width: 36, height: 36)
            .background(iconColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .accessibilityHidden(true)
    }

    private var titleStack: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        HStack(spacing: Spacing.sm) {
            if let badgeCount, badgeCount > 0 {
                Text(badgeCount < 100 ? "\(badgeCount)" : "99+")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xs + 1)
                    .frame(minWidth: 22, minHeight: 22)
                    .background(FondyColors.negative, in: Capsule())
                    .accessibilityLabel("\(badgeCount) notifications")
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelTertiary)
        }
    }

    private var accessibilityDescription: String {
        var parts = [title]
        if let subtitle { parts.append(subtitle) }
        if let badgeCount, badgeCount > 0 { parts.append("\(badgeCount) notifications") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        ProfileMenuRow(iconName: "person.fill",      iconColor: .blue,   title: "Personal details")
        Divider().padding(.leading, Spacing.iconDividerInset)
        ProfileMenuRow(iconName: "bell.fill",        iconColor: .orange, title: "Notifications",  badgeCount: 3)
        Divider().padding(.leading, Spacing.iconDividerInset)
        ProfileMenuRow(iconName: "lock.fill",        iconColor: .purple, title: "Security & Privacy", subtitle: "PIN, Biometrics")
        Divider().padding(.leading, Spacing.iconDividerInset)
        ProfileMenuRow(iconName: "questionmark.circle.fill", iconColor: .teal, title: "Help centre")
    }
    .padding(.horizontal, Spacing.pageMargin)
    .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    .padding(.horizontal, Spacing.pageMargin)
    .background(Color(.systemGroupedBackground))
}

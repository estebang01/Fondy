//
//  ActionItemRow.swift
//  Fondy
//
//  Reusable action/notification row with icon, title, subtitle, trailing amount, and status.
//

import SwiftUI

/// A row displaying an actionable item with a colored icon, title/subtitle,
/// and an optional trailing amount with status label.
struct ActionItemRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    var subtitle: String?
    var subtitleColor: Color = .orange
    var trailingAmount: String?
    var trailingStatus: String?
    var trailingStatusColor: Color = .orange
    var action: () -> Void = {}

    // MARK: - Body

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            HStack(spacing: Spacing.md) {
                iconView
                titleColumn
                Spacer(minLength: Spacing.sm)
                trailingColumn
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = [title]
        if let subtitle { parts.append(subtitle) }
        if let trailingAmount { parts.append(trailingAmount) }
        if let trailingStatus { parts.append(trailingStatus) }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Subviews

private extension ActionItemRow {

    var iconView: some View {
        Image(systemName: iconName)
            .font(.body.weight(.semibold))
            .foregroundStyle(iconColor)
            .frame(width: Spacing.iconSize, height: Spacing.iconSize)
            .background(iconColor.opacity(0.12), in: Circle())
            .accessibilityHidden(true)
    }

    var titleColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(1)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(subtitleColor)
                    .lineLimit(1)
            }
        }
    }

    var trailingColumn: some View {
        VStack(alignment: .trailing, spacing: Spacing.xxs) {
            if let trailingAmount {
                Text(trailingAmount)
                    .font(.body.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
            }

            if let trailingStatus {
                Text(trailingStatus)
                    .font(.caption)
                    .foregroundStyle(trailingStatusColor)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        ActionItemRow(
            iconName: "leaf.fill",
            iconColor: .green,
            title: "Metal plan",
            subtitle: "Verifying identity",
            subtitleColor: .orange,
            trailingAmount: "-$19.99",
            trailingStatus: "Pending",
            trailingStatusColor: .orange
        )
        .padding(Spacing.lg)
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )

        ActionItemRow(
            iconName: "checkmark.circle.fill",
            iconColor: FondyColors.positive,
            title: "Account verified",
            subtitle: "Complete",
            subtitleColor: FondyColors.positive,
            trailingStatus: "Done",
            trailingStatusColor: FondyColors.positive
        )
        .padding(Spacing.lg)
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }
    .padding(.horizontal, Spacing.pageMargin)
    .background(Color(.systemGroupedBackground))
}

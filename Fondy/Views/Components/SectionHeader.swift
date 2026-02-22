//
//  SectionHeader.swift
//  Fondy
//
//  Reusable section header with title and optional trailing action button.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var trailingTitle: String? = nil
    var trailingIconName: String = "chevron.right"
    var onAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if let onAction {
                Button {
                    Haptics.light()
                    onAction()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        if let trailingTitle {
                            Text(trailingTitle)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(FondyColors.labelSecondary)
                        }
                        Image(systemName: trailingIconName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FondyColors.labelTertiary)
                    }
                    // Ensure a comfortable touch target
                    .frame(minWidth: Spacing.iconSize, minHeight: Spacing.iconSize)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(trailingTitle ?? "More options")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xl) {
        SectionHeader(title: "Recent transactions", trailingTitle: "See all") {}
        SectionHeader(title: "Watchlist") {}
        SectionHeader(title: "Top movers")
    }
    .padding(.horizontal, Spacing.pageMargin)
}

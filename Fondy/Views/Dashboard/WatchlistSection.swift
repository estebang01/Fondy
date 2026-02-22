//
//  WatchlistSection.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import SwiftUI

/// Displays the "Watchlist" section with a "See all" link and watchlist item rows.
struct WatchlistSection: View {
    let items: [WatchlistItem]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            sectionHeader

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    watchlistRow(item: item)

                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 44 + Spacing.md + Spacing.md)
                    }
                }
            }
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Text("Watchlist")
                .font(.title3.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer()

            Button {
                Haptics.light()
            } label: {
                Text("See all")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.blue)
            }
        }
    }

    // MARK: - Row

    private func watchlistRow(item: WatchlistItem) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: item.iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 44, height: 44)
                .background(item.iconBackground, in: Circle())
                .accessibilityHidden(true)

            Text(item.name)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer(minLength: Spacing.sm)

            Text(item.value)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
        }
        .padding(.vertical, Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name), \(item.value)")
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        WatchlistSection(items: PortfolioService.mockWatchlist)
            .padding(.horizontal, Spacing.pageMargin)
    }
    .background(FondyColors.background)
}

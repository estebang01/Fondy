//
//  TopMoversGrid.swift
//  Fondy
//
//  Reusable 4-column grid of top-moving stocks.
//

import SwiftUI

struct TopMoversGrid: View {
    let movers: [TopMover]
    var onTap: ((TopMover) -> Void)? = nil
    var onSeeAll: (() -> Void)? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 4)

    var body: some View {
        let maxItems = columns.count * 2 // two rows
        let displayed = Array(movers.prefix(maxItems))

        return VStack(spacing: Spacing.md) {
            LazyVGrid(columns: columns, spacing: Spacing.xl) {
                ForEach(displayed) { mover in
                    TopMoverCell(mover: mover, onTap: onTap)
                }
            }

            if movers.count > displayed.count, let onSeeAll {
                Button {
                    Haptics.light()
                    onSeeAll()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See all top movers")
            }
        }
    }
}

struct TopMoverCell: View {
    let mover: TopMover
    var onTap: ((TopMover) -> Void)? = nil

    var body: some View {
        Button {
            Haptics.light()
            onTap?(mover)
        } label: {
            VStack(spacing: Spacing.xs) {
                logoView
                tickerLabel
                changeLabel
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mover.ticker), \(mover.formattedChange)")
    }
}

private extension TopMoverCell {

    var logoView: some View {
        Image(systemName: mover.logoSystemName)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(mover.logoColor)
            .frame(width: 56, height: 56)
            .background(mover.logoBackground, in: Circle())
            .accessibilityHidden(true)
    }

    var tickerLabel: some View {
        Text(mover.ticker)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(FondyColors.labelPrimary)
            .lineLimit(1)
    }

    var changeLabel: some View {
        Text(mover.formattedChange)
            .font(.caption2.weight(.medium))
            // Use semantic colors instead of raw .green/.red
            .foregroundStyle(mover.isPositive ? FondyColors.positive : FondyColors.negative)
            .lineLimit(1)
    }
}

// MARK: - Preview

#Preview {
    TopMoversGrid(movers: StocksViewModel.mockTopMovers)
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.lg)
}

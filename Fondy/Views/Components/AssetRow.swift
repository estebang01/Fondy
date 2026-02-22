//
//  AssetRow.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI

/// A single row displaying an investment asset with circular icon, name, amount, and performance.
struct AssetRow: View {
    let asset: Asset

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.md) {
            assetIcon
            assetInfo
            Spacer(minLength: Spacing.sm)
            assetPerformance
        }
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
        .contextMenu {
            Button { Haptics.selection() } label: {
                Label("View details", systemImage: "info.circle")
            }
            Button { Haptics.selection() } label: {
                Label("Invest more", systemImage: "plus.circle")
            }
            Divider()
            Button(role: .destructive) { Haptics.selection() } label: {
                Label("Withdraw", systemImage: "arrow.up.circle")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(asset.name), \(asset.category), " +
            "invested \(asset.investedAmount.formatted(.currency(code: "USD"))), " +
            "return \(asset.performancePercentage.formatted(.number.precision(.fractionLength(2))))%"
        )
    }

    // MARK: - Subviews

    private var assetIcon: some View {
        Image(systemName: asset.iconName)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .frame(width: Spacing.iconSize, height: Spacing.iconSize)
            .background(asset.iconBackground.gradient, in: Circle())
            .accessibilityHidden(true)
    }

    private var assetInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(asset.name)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(1)
            Text(asset.category)
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)
        }
    }

    private var assetPerformance: some View {
        VStack(alignment: .trailing, spacing: Spacing.xxs) {
            Text(asset.investedAmount, format: .currency(code: "USD"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
            Text("\(asset.isPositive ? "+" : "")\(asset.performancePercentage, specifier: "%.2f")%")
                .font(.caption.weight(.medium))
                .foregroundStyle(asset.isPositive ? FondyColors.positive : FondyColors.negative)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        ForEach(PortfolioService.createMockPortfolio().assets) { asset in
            AssetRow(asset: asset)
            if asset.id != PortfolioService.createMockPortfolio().assets.last?.id {
                Divider().padding(.leading, Spacing.iconDividerInset)
            }
        }
    }
    .padding(.horizontal, Spacing.pageMargin)
}

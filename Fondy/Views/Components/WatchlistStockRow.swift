//
//  WatchlistStockRow.swift
//  Fondy
//
//  Reusable row for a watchlist stock item.
//  Matches the "Apple / AAPL / $168.02 / ▲0.68%" card in the Stocks view.
//

import SwiftUI

/// A row showing a watchlist stock: logo, name/ticker, and price/change.
///
/// Matches the Revolut-style watchlist row — circular black logo,
/// company name, ticker subtitle, trailing price and colored change %.
struct WatchlistStockRow: View {
    let stock: WatchlistStock
    var onTap: (() -> Void)? = nil
    var accessibilityID: String? = nil

    // MARK: - Body

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            HStack(spacing: Spacing.md) {
                logoView
                nameColumn
                Spacer(minLength: Spacing.sm)
                priceColumn
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityID ?? "watchlist_row_\(stock.ticker)")
        .accessibilityLabel("\(stock.name), \(stock.ticker), \(stock.formattedPrice), \(stock.formattedChange)")
    }
}

// MARK: - Subviews

private extension WatchlistStockRow {

    var logoView: some View {
        CompanyLogoView(
            domain: stock.domain,
            systemName: stock.logoSystemName,
            symbolColor: stock.logoColor,
            background: Color(.systemGray5),
            size: Spacing.iconSize
        )
    }

    var nameColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(stock.name)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(1)

            Text(stock.ticker)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineLimit(1)
        }
    }

    var priceColumn: some View {
        VStack(alignment: .trailing, spacing: Spacing.xxs) {
            Text(stock.formattedPrice)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)

            Text(stock.formattedChange)
                .font(.subheadline)
                .foregroundStyle(stock.isPositive ? FondyColors.positive : FondyColors.negative)
        }
    }
}

// MARK: - Preview

#Preview {
    WatchlistStockRow(stock: WatchlistStock(
        id: UUID(),
        name: "Apple",
        ticker: "AAPL",
        logoSystemName: "apple.logo",
        logoColor: .white,
        price: 168.02,
        changePercent: 0.68,
        currencySymbol: "$"
    ))
    .padding(Spacing.lg)
    .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    .padding(.horizontal, Spacing.pageMargin)
    .background(Color(.systemGroupedBackground))
}

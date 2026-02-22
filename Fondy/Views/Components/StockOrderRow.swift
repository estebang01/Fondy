//
//  StockOrderRow.swift
//  Fondy
//
//  Reusable row for a pending or completed stock order.
//

import SwiftUI

struct StockOrderRow: View {
    let order: StockOrder

    var body: some View {
        Button { Haptics.light() } label: {
            HStack(spacing: Spacing.md) {
                logoView
                detailColumn
                Spacer(minLength: Spacing.sm)
                amountLabel
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(order.orderType.rawValue) \(order.ticker), \(order.formattedShares), \(order.formattedAmount)")
    }
}

private extension StockOrderRow {

    var logoView: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: order.logoSystemName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(order.logoColor)
                .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                // Neutral fill — adapts to light/dark automatically
                .background(Color(.systemGray5), in: Circle())

            // Status badge
            Image(systemName: isPending ? "clock.fill" : "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(isPending ? Color.blue : FondyColors.positive, in: Circle())
                .offset(x: 2, y: 2)
        }
        .accessibilityHidden(true)
    }

    var detailColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("\(order.orderType.rawValue) \(order.ticker)")
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(1)
            Text(order.formattedShares)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineLimit(1)
            Text(order.statusLabel)
                .font(.caption)
                .foregroundStyle(isPending ? .orange : FondyColors.labelSecondary)
                .lineLimit(1)
        }
    }

    var amountLabel: some View {
        Text(order.formattedAmount)
            .font(.body.weight(.semibold))
            .foregroundStyle(FondyColors.labelPrimary)
    }

    /// Infers "pending" state from the status label text.
    var isPending: Bool {
        order.statusLabel.localizedCaseInsensitiveContains("pending")
        || order.statusLabel.localizedCaseInsensitiveContains("processing")
        || order.statusLabel.localizedCaseInsensitiveContains("open")
    }
}

// MARK: - Preview

#Preview {
    let order = StockOrder(
        id: UUID(),
        ticker: "AAPL",
        companyName: "Apple Inc.",
        logoSystemName: "apple.logo",
        logoColor: .white,
        orderType: .buy,
        shares: 0.5,
        statusLabel: "Pending",
        amount: 99.50,
        currencySymbol: "$"
    )
    StockOrderRow(order: order)
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.md)
}

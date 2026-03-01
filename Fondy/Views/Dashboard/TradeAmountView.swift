//
//  TradeAmountView.swift
//  Fondy
//
//  Screen 1: Amount entry with swap cards + numpad.
//

import SwiftUI

// MARK: - Screen 1: Amount Entry

struct TradeAmountView: View {
    let stock: StockDetail
    let orderType: TradeOrderType
    @Binding var amountText: String
    @Binding var showReview: Bool
    let fee: Double
    let estimatedShares: Double

    @Environment(\.dismiss) private var dismiss
    @State private var inputMode: InputMode = .usd  // typing USD or shares

    private enum InputMode { case usd, shares }

    var amount: Double { Double(amountText) ?? 0 }
    var sharesForDisplay: Double {
        guard stock.price > 0, amount > fee else { return 0 }
        return (amount - fee) / stock.price
    }

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            navBar

            // Title
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\(orderType.title) \(stock.ticker)")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(FondyColors.positive)
                    Text("1 \(stock.ticker) = \(stock.formattedPrice)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                    Image(systemName: "moon.fill")
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                    Text("·  Capital at risk")
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)

            // Swap cards
            swapCards
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.xl)

            Spacer(minLength: 0)

            // Confirm / Buy button
            Button {
                Haptics.medium()
                showReview = true
            } label: {
                Text("\(orderType.title) \(stock.ticker)")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(amount > 0 ? .white : FondyColors.labelTertiary)
            }
            .buttonStyle(PositiveButtonStyle(cornerRadius: 50, tint: amount > 0 ? orderType.accentColor : .clear))
            .disabled(amount <= 0)
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.md)
            .animation(.springGentle, value: amount > 0)
            .accessibilityLabel("\(orderType.title) \(stock.ticker)")

            // Numpad
            numpad
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xxxl)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button {
                Haptics.light()
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.headline)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(width: Spacing.iconSize, height: Spacing.iconSize)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .accessibilityLabel("Back")

            Spacer()

            Button {
                Haptics.light()
            } label: {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                    Text("Market order")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Order type: Market order")
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Swap Cards

    private var swapCards: some View {
        ZStack(alignment: .center) {
            VStack(spacing: Spacing.xxs) {
                // Top card: shares received
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(stock.ticker)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(FondyColors.labelPrimary)
                        Text("Owned: 0")
                            .font(.footnote)
                            .foregroundStyle(FondyColors.labelTertiary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text(amount > 0 ? String(format: "+%.8g", sharesForDisplay) : "+0")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(amount > 0 ? FondyColors.labelPrimary : FondyColors.labelTertiary)
                            .animation(.springGentle, value: sharesForDisplay)
                        if amount > 0 && sharesForDisplay > 0 {
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: "info.circle")
                                    .font(.caption2)
                                    .foregroundStyle(FondyColors.labelTertiary)
                                Text(String(format: "after %@%.2f fee", stock.currencySymbol, fee))
                                    .font(.caption)
                                    .foregroundStyle(FondyColors.labelTertiary)
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .trailing)))
                        }
                    }
                    .animation(.springGentle, value: amount > 0 && sharesForDisplay > 0)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                )

                // Bottom card: USD amount (active input)
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(stock.currencySymbol == "$" ? "USD" : "EUR")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(FondyColors.labelPrimary)
                        Text("Balance: \(stock.currencySymbol)3")
                            .font(.footnote)
                            .foregroundStyle(FondyColors.labelTertiary)
                    }
                    Spacer()
                    (
                        Text(amount > 0
                             ? "\(orderType.sign)\(stock.currencySymbol)\(amountText)"
                             : "\(orderType.sign)\(stock.currencySymbol)0")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(amount > 0 ? FondyColors.labelPrimary : FondyColors.labelTertiary)
                        + Text("|")
                            .font(.body.weight(.ultraLight))
                            .foregroundStyle(.blue)
                    )
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                )
            }

            // Swap button
            Button {
                Haptics.selection()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(width: 34, height: 34)
                    .background(FondyColors.background, in: Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .accessibilityLabel("Swap input currency")
        }
    }

    // MARK: - Numpad

    private var numpad: some View {
        let rows: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [".", "0", "⌫"]
        ]
        let subLabels: [String: String] = [
            "2": "ABC", "3": "DEF",
            "4": "GHI", "5": "JKL", "6": "MNO",
            "7": "PQRS", "8": "TUV", "9": "WXYZ"
        ]

        return VStack(spacing: 2) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            ZStack {
                                if key == "⌫" {
                                    Image(systemName: "delete.left")
                                        .font(.system(size: 22, weight: .light))
                                        .foregroundStyle(FondyColors.labelPrimary)
                                } else {
                                    VStack(spacing: 1) {
                                        Text(key)
                                            .font(.system(size: 26, weight: .light))
                                            .foregroundStyle(FondyColors.labelPrimary)
                                        if let sub = subLabels[key] {
                                            Text(sub)
                                                .font(.system(size: 8, weight: .medium))
                                                .foregroundStyle(FondyColors.labelTertiary)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                        .buttonStyle(NumpadButtonStyle())
                        .accessibilityLabel(key == "⌫" ? "Delete" : key)
                    }
                }
            }
        }
    }

    private func handleKey(_ key: String) {
        Haptics.selection()
        switch key {
        case "⌫":
            if amountText.count > 1 {
                amountText.removeLast()
            } else {
                amountText = "0"
            }
        case ".":
            if !amountText.contains(".") {
                if amountText == "0" { amountText = "0." }
                else { amountText += "." }
            }
        default:
            if amountText == "0" {
                amountText = key
            } else if amountText.count < 10 {
                amountText += key
            }
        }
    }
}

// MARK: - Numpad Button Style

/// Specialized input-key style for the numeric entry keypad.
/// This is intentionally scoped to TradeAmountView — it is a numeric input
/// interaction component, not an action button, and therefore falls outside
/// the three design-system categories (Positive / Negative / LiquidGlass).
private struct NumpadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray5) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.springInteractive, value: configuration.isPressed)
    }
}

// MARK: - Preview

private struct TradeAmountPreviewContainer: View {
    @State private var amountText: String = "0"
    @State private var showReview: Bool = false

    var body: some View {
        TradeAmountView(
            stock: StockDetail.apple,
            orderType: .buy,
            amountText: $amountText,
            showReview: $showReview,
            fee: 0.99,
            estimatedShares: 0
        )
    }
}

#Preview("Trade Amount - Buy") {
    NavigationStack {
        TradeAmountPreviewContainer()
    }
}


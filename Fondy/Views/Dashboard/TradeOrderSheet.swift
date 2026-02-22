//
//  TradeOrderSheet.swift
//  Fondy
//
//  Full-screen buy/sell flow matching the Revolut-style trading UI.
//  Screen 1: Amount entry with swap cards + numpad.
//  Screen 2: Order review with fee breakdown + Submit.
//

import SwiftUI

// MARK: - Order Type

enum TradeOrderType {
    case buy, sell

    var title: String { self == .buy ? "Buy" : "Sell" }
    var accentColor: Color { self == .buy ? .blue : Color(red: 0.85, green: 0.1, blue: 0.35) }
    var sign: String { self == .buy ? "-" : "+" }
}

// MARK: - Trade Order Sheet (Entry point — full screen cover)

struct TradeOrderSheet: View {
    let stock: StockDetail
    let orderType: TradeOrderType

    @Environment(\.dismiss) private var dismiss
    @State private var showReview = false
    @State private var amountText: String = "0"

    private static let fee: Double = 0.99

    var amount: Double { Double(amountText) ?? 0 }

    var estimatedShares: Double {
        guard stock.price > 0, amount > Self.fee else { return 0 }
        return (amount - Self.fee) / stock.price
    }

    var tradedValue: Double {
        max(0, amount - Self.fee)
    }

    var body: some View {
        NavigationStack {
            TradeAmountView(
                stock: stock,
                orderType: orderType,
                amountText: $amountText,
                showReview: $showReview,
                fee: Self.fee,
                estimatedShares: estimatedShares
            )
            .navigationDestination(isPresented: $showReview) {
                TradeReviewView(
                    stock: stock,
                    orderType: orderType,
                    amount: amount,
                    fee: Self.fee,
                    tradedValue: tradedValue,
                    estimatedShares: estimatedShares,
                    onDismiss: { dismiss() }
                )
            }
        }
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(20)
    }
}

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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md + 2)
                    .background(
                        amount > 0 ? orderType.accentColor : FondyColors.fillTertiary,
                        in: Capsule()
                    )
            }
            .buttonStyle(TradeScaleButtonStyle())
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
            .buttonStyle(.plain)
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
            .buttonStyle(ScaleButtonStyle())
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

// MARK: - Generic Scale Button Style

private struct TradeScaleButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Numpad Button Style

private struct NumpadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray5) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.springInteractive, value: configuration.isPressed)
    }
}

// MARK: - Screen 2: Order Review

struct TradeReviewView: View {
    let stock: StockDetail
    let orderType: TradeOrderType
    let amount: Double
    let fee: Double
    let tradedValue: Double
    let estimatedShares: Double
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isSubmitted = false

    private var formattedAmount: String {
        String(format: "%@%@%.2f", orderType.sign, stock.currencySymbol, amount)
    }
    private var formattedShares: String {
        String(format: "%.8g \(stock.ticker)", estimatedShares)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            navBar

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                    // Header
                    headerSection

                    // Market info card
                    infoCard

                    // Breakdown card
                    breakdownCard
                }
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xxxl + 100)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            bottomBar
        }
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
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
            Spacer()
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedAmount)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                Text("\(orderType.title) \(formattedShares)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelSecondary)
            }
            Spacer()
            Image(systemName: stock.logoSystemName)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(stock.logoColor)
                .frame(width: 64, height: 64)
                .background(stock.logoBackground, in: Circle())
                .accessibilityHidden(true)
        }
    }

    // MARK: - Market Info Card

    private var infoCard: some View {
        Text("Your order will be executed at the best available price when the market opens again")
            .font(.body)
            .foregroundStyle(FondyColors.labelPrimary)
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    // MARK: - Breakdown Card

    private var breakdownCard: some View {
        VStack(spacing: 0) {
            reviewRow(label: "Amount", value: String(format: "%@%.2f", stock.currencySymbol, amount))
            Divider().padding(.horizontal, Spacing.lg)

            // Fees row — blue info icon + blue value
            HStack {
                Text("Fees")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.blue)
                    Text(String(format: "%@%.2f", stock.currencySymbol, fee))
                        .font(.body.weight(.medium))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + 2)
            Divider().padding(.horizontal, Spacing.lg)

            reviewRow(
                label: "Traded value",
                value: String(format: "%@%.0f", stock.currencySymbol, tradedValue)
            )
            Divider().padding(.horizontal, Spacing.lg)

            // Price row — blue arrow + blue price
            HStack {
                Text("Price:")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("1 \(stock.ticker) = \(stock.formattedPrice)")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + 2)
            Divider().padding(.horizontal, Spacing.lg)

            reviewRow(label: "Estimated shares", value: formattedShares)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(FondyColors.labelTertiary)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: Spacing.sm) {
            // Submit button
            Button {
                Haptics.success()
                withAnimation(.springGentle) { isSubmitted = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onDismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    if isSubmitted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                        Text("Order placed!")
                            .font(.body.weight(.semibold))
                    } else {
                        Text("Submit")
                            .font(.body.weight(.semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md + 2)
                .background(
                    isSubmitted ? FondyColors.positive : orderType.accentColor,
                    in: Capsule()
                )
            }
            .buttonStyle(TradeScaleButtonStyle())
            .disabled(isSubmitted)
            .animation(.springGentle, value: isSubmitted)
            .accessibilityLabel(isSubmitted ? "Order placed" : "Submit order")

            // Legal footer
            Group {
                Text("Your capital is at risk.")
                    .foregroundStyle(.blue)
                + Text("\nOur ")
                    .foregroundStyle(FondyColors.labelTertiary)
                + Text("Terms of business")
                    .foregroundStyle(.blue)
                + Text(" and ")
                    .foregroundStyle(FondyColors.labelTertiary)
                + Text("Best Execution Policy")
                    .foregroundStyle(.blue)
                + Text(" apply")
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .font(.footnote)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xxxl)
        .background(
            Color(.systemGroupedBackground)
                .overlay(alignment: .top) { Divider() }
        )
    }
}

// MARK: - Previews

#Preview("Amount Entry") {
    TradeOrderSheet(stock: .apple, orderType: .buy)
}

#Preview("Review") {
    NavigationStack {
        TradeReviewView(
            stock: .apple,
            orderType: .buy,
            amount: 1.99,
            fee: 0.99,
            tradedValue: 1.0,
            estimatedShares: 0.00595167,
            onDismiss: {}
        )
    }
}


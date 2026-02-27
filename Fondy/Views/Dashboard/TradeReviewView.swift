//
//  TradeReviewView.swift
//  Fondy
//
//  Screen 2: Order review with fee breakdown + Submit.
//

import SwiftUI

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
                .liquidGlass(tint: isSubmitted ? FondyColors.positive : orderType.accentColor, cornerRadius: 50)
            }
            .buttonStyle(LiquidGlassButtonStyle())
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

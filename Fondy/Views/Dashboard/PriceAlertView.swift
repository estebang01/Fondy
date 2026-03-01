//
//  PriceAlertView.swift
//  Fondy
//
//  Price alert creation screen pushed from the stock detail bell icon.
//  Matches the Revolut "AAPL Alert" screen: decimal pad entry, live
//  percentage-difference feedback, and a "Create alert" button.
//

import SwiftUI

struct PriceAlertView: View {
    let stock: StockDetail
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @FocusState private var isInputFocused: Bool

    // MARK: - Computed

    private var enteredAmount: Double? {
        Double(amountText)
    }

    private var isValid: Bool {
        guard let value = enteredAmount else { return false }
        return value > 0
    }

    /// Percentage difference vs current price.
    private var percentageDiff: String? {
        guard let value = enteredAmount, value > 0, stock.price > 0 else { return nil }
        let diff = (value - stock.price) / stock.price * 100
        if diff > 0 {
            return String(format: "%.2f%% increase", diff)
        } else {
            return String(format: "%.2f%% decrease", abs(diff))
        }
    }

    private var displayAmount: String {
        amountText.isEmpty ? "$0" : "$\(amountText)"
    }

    private var currencyLabel: String {
        stock.currencySymbol == "$" ? "USD" : "EUR"
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    titleSection
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.xl)

                    amountCard
                        .padding(.horizontal, Spacing.pageMargin)
                }

                Spacer()
            }
            .background(Color(.systemGroupedBackground))

            createAlertButton
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.xl + (isInputFocused ? 0 : Spacing.lg))
        }
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Haptics.light()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Auto-focus to show the numpad immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isInputFocused = true
            }
        }
    }
}

// MARK: - Title

private extension PriceAlertView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("\(stock.ticker) Alert")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            Text("Alert triggers when 1 \(stock.ticker) equals")
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
        }
    }
}

// MARK: - Amount Card

private extension PriceAlertView {

    var amountCard: some View {
        // Hidden TextField to capture decimal pad input
        ZStack {
            TextField("", text: $amountText)
                .keyboardType(.decimalPad)
                .focused($isInputFocused)
                .opacity(0)
                .frame(width: 1, height: 1)
                .onChange(of: amountText) { _, newValue in
                    // Only allow digits and a single decimal point
                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                    let parts = filtered.components(separatedBy: ".")
                    if parts.count > 2 {
                        amountText = parts[0] + "." + parts[1]
                    } else {
                        amountText = filtered
                    }
                }

            // Visual card
            Button {
                isInputFocused = true
            } label: {
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        Text(currencyLabel)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(FondyColors.labelPrimary)

                        Spacer()

                        // Amount display
                        Text(displayAmount)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(isValid ? FondyColors.labelPrimary : FondyColors.labelTertiary)
                            .overlay(alignment: .trailing) {
                                // Blinking cursor when focused and empty
                                if amountText.isEmpty && isInputFocused {
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: 2, height: 20)
                                        .offset(x: 4)
                                }
                            }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.sm)

                    HStack {
                        Text("Current · 1 \(stock.ticker) = \(stock.formattedPrice)\(currencyLabel)")
                            .font(.subheadline)
                            .foregroundStyle(FondyColors.labelTertiary)

                        Spacer()

                        if let diff = percentageDiff {
                            Text(diff)
                                .font(.subheadline)
                                .foregroundStyle(FondyColors.labelTertiary)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(FondyColors.fillQuaternary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityLabel("Enter alert price")
        }
    }
}

// MARK: - Create Alert Button

private extension PriceAlertView {

    var createAlertButton: some View {
        Button {
            Haptics.success()
            dismiss()
        } label: {
            Text("Create alert")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
        }
        .buttonStyle(PositiveButtonStyle(cornerRadius: 50))
        .disabled(!isValid)
        .accessibilityLabel("Create price alert")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PriceAlertView(stock: .apple)
    }
}


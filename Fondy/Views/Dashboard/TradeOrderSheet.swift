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

// MARK: - Preview

#Preview("Trade Order") {
    TradeOrderSheet(stock: .apple, orderType: .buy)
}


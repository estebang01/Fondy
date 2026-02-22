//
//  StockOrder.swift
//  Fondy
//

import SwiftUI

/// A pending or completed stock order.
struct StockOrder: Identifiable {
    let id: UUID
    let ticker: String
    let companyName: String
    /// SF Symbol or asset name for the logo circle background
    let logoSystemName: String
    let logoColor: Color
    let orderType: OrderType
    let shares: Double
    let statusLabel: String
    let amount: Double
    let currencySymbol: String

    enum OrderType: String {
        case buy = "Buy"
        case sell = "Sell"
    }

    var formattedShares: String {
        let formatted = String(format: "%.8g", shares)
        return "\(formatted) shares"
    }

    var formattedAmount: String {
        String(format: "-\(currencySymbol)%.2f", abs(amount))
    }
}

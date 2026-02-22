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
    var domain: String? = nil

    enum OrderType: String {
        case buy = "Buy"
        case sell = "Sell"
    }

    init(
        id: UUID,
        ticker: String,
        companyName: String,
        logoSystemName: String,
        logoColor: Color,
        orderType: OrderType,
        shares: Double,
        statusLabel: String,
        amount: Double,
        currencySymbol: String,
        domain: String? = nil
    ) {
        self.id = id
        self.ticker = ticker
        self.companyName = companyName
        self.logoSystemName = logoSystemName
        self.logoColor = logoColor
        self.orderType = orderType
        self.shares = shares
        self.statusLabel = statusLabel
        self.amount = amount
        self.currencySymbol = currencySymbol
        self.domain = domain
    }

    var formattedShares: String {
        let formatted = String(format: "%.8g", shares)
        return "\(formatted) shares"
    }

    var formattedAmount: String {
        String(format: "-\(currencySymbol)%.2f", abs(amount))
    }
    
    var logoURL: URL? {
        guard let domain else { return nil }
        return URL(string: "https://img.logo.dev/\(domain)?size=64")
    }
}

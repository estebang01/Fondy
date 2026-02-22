//
//  WatchlistStock.swift
//  Fondy
//

import SwiftUI

/// A stock item in the user's watchlist.
struct WatchlistStock: Identifiable {
    let id: UUID
    let name: String
    let ticker: String
    let logoSystemName: String
    let logoColor: Color
    let price: Double
    let changePercent: Double
    let currencySymbol: String

    var isPositive: Bool { changePercent >= 0 }

    var formattedPrice: String {
        String(format: "\(currencySymbol)%.2f", price)
    }

    var formattedChange: String {
        let sign = isPositive ? "▲" : "▼"
        return String(format: "%@ %.2f%%", sign, abs(changePercent))
    }
}

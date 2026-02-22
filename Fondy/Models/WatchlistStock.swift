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
    var domain: String? = nil

    var isPositive: Bool { changePercent >= 0 }

    var formattedPrice: String {
        String(format: "\(currencySymbol)%.2f", price)
    }

    var formattedChange: String {
        let sign = isPositive ? "▲" : "▼"
        return String(format: "%@ %.2f%%", sign, abs(changePercent))
    }
    
    var logoURL: URL? {
        guard let domain else { return nil }
        return URL(string: "https://img.logo.dev/\(domain)?size=64")
    }
    
    init(
        id: UUID,
        name: String,
        ticker: String,
        logoSystemName: String,
        logoColor: Color,
        price: Double,
        changePercent: Double,
        currencySymbol: String,
        domain: String? = nil
    ) {
        self.id = id
        self.name = name
        self.ticker = ticker
        self.logoSystemName = logoSystemName
        self.logoColor = logoColor
        self.price = price
        self.changePercent = changePercent
        self.currencySymbol = currencySymbol
        self.domain = domain
    }
}

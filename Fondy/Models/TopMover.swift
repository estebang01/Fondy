//
//  TopMover.swift
//  Fondy
//

import SwiftUI

/// A stock item shown in the "Today's Top movers" grid and full-screen list.
struct TopMover: Identifiable {
    let id: UUID
    let companyName: String
    let ticker: String
    let sector: String
    let logoSystemName: String
    let logoColor: Color
    let logoBackground: Color
    let price: Double
    let changePercent: Double
    let currencySymbol: String
    var domain: String? = nil

    var isPositive: Bool { changePercent >= 0 }

    var formattedChange: String {
        let sign = isPositive ? "▲" : "▼"
        return String(format: "%@ %.2f%%", sign, abs(changePercent))
    }

    var formattedPrice: String {
        String(format: "\(currencySymbol)%.2f", price)
    }
    
    var logoURL: URL? {
        guard let domain else { return nil }
        return URL(string: "https://img.logo.dev/\(domain)?size=64")
    }

    init(
        id: UUID,
        companyName: String,
        ticker: String,
        sector: String,
        logoSystemName: String,
        logoColor: Color,
        logoBackground: Color,
        price: Double,
        changePercent: Double,
        currencySymbol: String,
        domain: String? = nil
    ) {
        self.id = id
        self.companyName = companyName
        self.ticker = ticker
        self.sector = sector
        self.logoSystemName = logoSystemName
        self.logoColor = logoColor
        self.logoBackground = logoBackground
        self.price = price
        self.changePercent = changePercent
        self.currencySymbol = currencySymbol
        self.domain = domain
    }
}

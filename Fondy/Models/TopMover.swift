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

    var isPositive: Bool { changePercent >= 0 }

    var formattedChange: String {
        let sign = isPositive ? "▲" : "▼"
        return String(format: "%@ %.2f%%", sign, abs(changePercent))
    }

    var formattedPrice: String {
        String(format: "\(currencySymbol)%.2f", price)
    }
}

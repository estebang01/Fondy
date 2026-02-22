//
//  StockFilterModels.swift
//  Fondy
//
//  Stock screener filter models: sectors, market cap, and stock listings.
//

import SwiftUI

// MARK: - Stock Sector

/// Sector categories for the stock screener.
enum StockSector: String, CaseIterable, Identifiable {
    case technology = "Technology"
    case financial = "Financial"
    case consumerStaples = "Consumer Staples"
    case healthcare = "Healthcare"
    case consumerDiscretionary = "Consumer Discretionary"
    case industrials = "Industrials"
    case realEstate = "Real Estate"
    case basicMaterials = "Basic Materials"
    case energy = "Energy"
    case utilities = "Utilities"
    case communication = "Communication"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .technology:            return "cpu.fill"
        case .financial:             return "dollarsign.circle.fill"
        case .consumerStaples:       return "cart.fill"
        case .healthcare:            return "heart.fill"
        case .consumerDiscretionary: return "bag.fill"
        case .industrials:           return "gearshape.fill"
        case .realEstate:            return "house.fill"
        case .basicMaterials:        return "square.stack.3d.up.fill"
        case .energy:                return "bolt.fill"
        case .utilities:             return "lightbulb.fill"
        case .communication:         return "antenna.radiowaves.left.and.right"
        }
    }
}

// MARK: - Market Cap

/// Market capitalization categories for the stock screener.
enum MarketCapCategory: String, CaseIterable, Identifiable {
    case smallCap = "Small-cap"
    case midCap = "Mid-cap"
    case largeCap = "Large-cap"
    case megaCap = "Mega-cap"

    var id: String { rawValue }
}

// MARK: - All Stock (for screener)

/// A stock shown in the "All Stocks" screener list.
struct AllStock: Identifiable {
    let id: UUID
    let companyName: String
    let ticker: String
    let sector: StockSector
    let sectorDetail: String
    let logoSystemName: String
    let logoColor: Color
    let logoBackground: Color
    let price: Double
    let changePercent: Double
    let marketCap: MarketCapCategory
    let peRatio: Double
    let dividendYield: Double
    let yearlyChange: Double
    let currencySymbol: String

    var isPositive: Bool { changePercent >= 0 }

    var formattedPrice: String {
        String(format: "\(currencySymbol)%.2f", price)
    }

    var formattedChange: String {
        let sign = isPositive ? "▲" : "▼"
        return String(format: "%@ %.2f%%", sign, abs(changePercent))
    }

    init(companyName: String, ticker: String, sector: StockSector, sectorDetail: String,
         logoSystemName: String, logoColor: Color, logoBackground: Color,
         price: Double, changePercent: Double, marketCap: MarketCapCategory,
         peRatio: Double, dividendYield: Double, yearlyChange: Double,
         currencySymbol: String = "$") {
        self.id = UUID()
        self.companyName = companyName
        self.ticker = ticker
        self.sector = sector
        self.sectorDetail = sectorDetail
        self.logoSystemName = logoSystemName
        self.logoColor = logoColor
        self.logoBackground = logoBackground
        self.price = price
        self.changePercent = changePercent
        self.marketCap = marketCap
        self.peRatio = peRatio
        self.dividendYield = dividendYield
        self.yearlyChange = yearlyChange
        self.currencySymbol = currencySymbol
    }
}

// MARK: - Selectable Stock (for Add Stocks sheet)

/// A stock shown in the "Add Stocks" search/selection sheet.
struct SelectableStock: Identifiable {
    let id: UUID
    let companyName: String
    let ticker: String
    let logoSystemName: String
    let logoColor: Color
    let logoBackground: Color
    var isSelected: Bool = false
}

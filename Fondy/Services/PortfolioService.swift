//
//  PortfolioService.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI

/// Provides mock portfolio data for development and previews.
struct PortfolioService {

    /// Creates a mock portfolio with sample data matching the dashboard design.
    static func createMockPortfolio() -> Portfolio {
        Portfolio(
            walletName: "My Portfolio",
            walletAddress: "0xc8a4b7e3d9f1023a5c6e8b2d4f7a9c1e3b5d720f",
            totalBalance: 6_158.42,
            dailyPerformancePercentage: 5.2,
            assets: mockAssets,
            currencyCode: "GBP",
            currencyName: "British Pound",
            transactions: mockTransactions,
            weeklySpent: 248,
            weeklySpentChange: 20,
            budgetUsed: 2_724,
            budgetTotal: 4_000,
            budgetDaysLeft: 3,
            watchlistItems: mockWatchlist
        )
    }

    // MARK: - Mock Transactions

    static let mockTransactions: [Transaction] = [
        Transaction(
            id: UUID(),
            name: "Airbnb",
            iconName: "house.fill",
            iconBackground: Color(.systemPink),
            amount: -99.00,
            currencySymbol: "£",
            time: "12:10"
        ),
        Transaction(
            id: UUID(),
            name: "Spotify",
            iconName: "music.note",
            iconBackground: Color(.systemGreen),
            amount: -9.99,
            currencySymbol: "£",
            time: "Yesterday"
        ),
        Transaction(
            id: UUID(),
            name: "Transfer In",
            iconName: "arrow.down.left",
            iconBackground: Color(.systemBlue),
            amount: 500.00,
            currencySymbol: "£",
            time: "Monday"
        ),
        Transaction(
            id: UUID(),
            name: "Netflix",
            iconName: "play.tv.fill",
            iconBackground: Color(.systemRed),
            amount: -17.99,
            currencySymbol: "£",
            time: "Sunday"
        ),
        Transaction(
            id: UUID(),
            name: "Amazon",
            iconName: "cart.fill",
            iconBackground: Color(.systemOrange),
            amount: -43.50,
            currencySymbol: "£",
            time: "Sat"
        ),
    ]

    // MARK: - Mock Watchlist

    static let mockWatchlist: [WatchlistItem] = [
        WatchlistItem(
            id: UUID(),
            name: "Apple",
            value: "$227.82",
            iconName: "apple.logo",
            iconBackground: Color(.systemGray5)
        ),
        WatchlistItem(
            id: UUID(),
            name: "NVIDIA",
            value: "$875.39",
            iconName: "cpu.fill",
            iconBackground: Color(.systemGreen).opacity(0.15)
        ),
        WatchlistItem(
            id: UUID(),
            name: "EUR to GBP",
            value: "£0.8502",
            iconName: "eurosign.circle.fill",
            iconBackground: Color(.systemBlue).opacity(0.15)
        ),
    ]

    // MARK: - Mock Assets

    static let mockAssets: [Asset] = [
        Asset(
            id: UUID(),
            name: "S&P 500 ETF",
            category: "ETF",
            iconName: "chart.line.uptrend.xyaxis",
            iconBackground: Color(.systemBlue),
            investedAmount: 82_324.14,
            performancePercentage: 24.52
        ),
        Asset(
            id: UUID(),
            name: "Tech Growth Fund",
            category: "Fund",
            iconName: "cpu.fill",
            iconBackground: Color(.systemPurple),
            investedAmount: 102_458.75,
            performancePercentage: 14.78
        ),
        Asset(
            id: UUID(),
            name: "Gold ETF",
            category: "Commodity",
            iconName: "star.circle.fill",
            iconBackground: Color(.systemYellow),
            investedAmount: 42_547.04,
            performancePercentage: 7.95
        ),
        Asset(
            id: UUID(),
            name: "Bond Portfolio",
            category: "Fixed Income",
            iconName: "building.columns.fill",
            iconBackground: Color(.systemIndigo),
            investedAmount: 84_245.39,
            performancePercentage: -0.45
        ),
        Asset(
            id: UUID(),
            name: "Global Equity",
            category: "Equity",
            iconName: "globe.americas.fill",
            iconBackground: Color(.systemTeal),
            investedAmount: 147_523.87,
            performancePercentage: -4.78
        ),
    ]
}

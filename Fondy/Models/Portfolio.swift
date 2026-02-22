//
//  Portfolio.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import Foundation

/// Represents the user's complete investment portfolio.
@Observable
class Portfolio {
    var walletName: String
    var walletAddress: String
    var totalBalance: Double
    var dailyPerformancePercentage: Double
    var assets: [Asset]
    var currencyCode: String
    var currencyName: String
    var transactions: [Transaction]
    var weeklySpent: Double
    var weeklySpentChange: Double
    var budgetUsed: Double
    var budgetTotal: Double
    var budgetDaysLeft: Int
    var watchlistItems: [WatchlistItem]

    // MARK: - Computed Properties

    var shortenedAddress: String {
        guard walletAddress.count > 10 else { return walletAddress }
        let prefix = walletAddress.prefix(6)
        let suffix = walletAddress.suffix(4)
        return "\(prefix)...\(suffix)"
    }

    var isDailyPositive: Bool {
        dailyPerformancePercentage >= 0
    }

    // MARK: - Initialization

    init(
        walletName: String,
        walletAddress: String,
        totalBalance: Double,
        dailyPerformancePercentage: Double,
        assets: [Asset],
        currencyCode: String = "GBP",
        currencyName: String = "British Pound",
        transactions: [Transaction] = [],
        weeklySpent: Double = 0,
        weeklySpentChange: Double = 0,
        budgetUsed: Double = 0,
        budgetTotal: Double = 0,
        budgetDaysLeft: Int = 0,
        watchlistItems: [WatchlistItem] = []
    ) {
        self.walletName = walletName
        self.walletAddress = walletAddress
        self.totalBalance = totalBalance
        self.dailyPerformancePercentage = dailyPerformancePercentage
        self.assets = assets
        self.currencyCode = currencyCode
        self.currencyName = currencyName
        self.transactions = transactions
        self.weeklySpent = weeklySpent
        self.weeklySpentChange = weeklySpentChange
        self.budgetUsed = budgetUsed
        self.budgetTotal = budgetTotal
        self.budgetDaysLeft = budgetDaysLeft
        self.watchlistItems = watchlistItems
    }
}

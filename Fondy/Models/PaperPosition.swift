//
//  PaperPosition.swift
//  Fondy
//

import Foundation

/// A simulated stock position in the paper portfolio.
struct PaperPosition: Identifiable, Codable, Equatable {
    let id: UUID
    var ticker: String
    var shares: Double
    var avgCost: Double
    var createdAt: Date

    init(id: UUID = UUID(), ticker: String, shares: Double, avgCost: Double, createdAt: Date = Date()) {
        self.id = id
        self.ticker = ticker
        self.shares = shares
        self.avgCost = avgCost
        self.createdAt = createdAt
    }

    var totalCost: Double { shares * avgCost }

    var formattedShares: String {
        if shares == shares.rounded() { return "\(Int(shares))" }
        return String(format: "%.4f", shares)
    }

    var formattedAvgCost: String {
        String(format: "$%.2f", avgCost)
    }

    var formattedTotalCost: String {
        String(format: "$%.2f", totalCost)
    }
}

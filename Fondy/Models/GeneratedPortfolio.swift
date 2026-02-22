//
//  GeneratedPortfolio.swift
//  Fondy
//
//  Data models for AI-generated portfolio results.
//

import SwiftUI

// MARK: - Generated Portfolio

struct GeneratedPortfolio {
    let name: String
    let riskScore: Int
    let riskLabel: String
    let allocations: [PortfolioAllocation]
    let expectedReturn: Double
    let monthlyInvestment: Double
    let projectedValueOneYear: Double
    let projectedValueFiveYear: Double
}

struct PortfolioAllocation: Identifiable {
    let id = UUID()
    let assetName: String
    let ticker: String
    let sector: String
    let percentage: Double
    let color: Color
}

//
//  PortfolioGeneratorService.swift
//  Fondy
//
//  Mock service that simulates AI portfolio generation based on user preferences.
//

import SwiftUI

enum PortfolioGeneratorService {

    /// Simulates AI portfolio generation with progress updates.
    static func generate(
        state: PortfolioGeneratorState
    ) async {
        let messages = [
            "Analyzing your preferences...",
            "Evaluating risk parameters...",
            "Selecting optimal assets...",
            "Optimizing allocations...",
            "Building your portfolio..."
        ]

        for (index, message) in messages.enumerated() {
            await MainActor.run {
                state.currentGenerationMessage = message
                state.generationProgress = Double(index + 1) / Double(messages.count)
            }
            try? await Task.sleep(for: .milliseconds(500))
        }

        let portfolio = buildPortfolio(
            goal: state.selectedGoal ?? .wealthGrowth,
            risk: state.selectedRisk ?? .moderate,
            horizon: state.selectedHorizon ?? .mediumTerm,
            amount: state.monthlyAmount ?? 100,
            sectors: state.selectedSectors
        )

        await MainActor.run {
            state.generatedPortfolio = portfolio
            state.isGenerating = false
        }
    }

    // MARK: - Portfolio Builder

    private static func buildPortfolio(
        goal: PG.InvestmentGoal,
        risk: PG.RiskTolerance,
        horizon: PG.InvestmentHorizon,
        amount: Double,
        sectors: Set<PG.InvestmentSector>
    ) -> GeneratedPortfolio {
        let name = portfolioName(goal: goal, risk: risk)
        let riskScore = riskScoreValue(risk: risk)
        let allocations = buildAllocations(risk: risk, sectors: sectors)
        let expectedReturn = expectedReturnRate(risk: risk, horizon: horizon)
        let projectedOne = amount * 12 * (1 + expectedReturn / 100)
        let projectedFive = amount * 60 * pow(1 + expectedReturn / 100 / 12, 60) / (expectedReturn / 100 / 12)
            * (expectedReturn / 100 / 12)

        // Simplified future value of annuity
        let monthlyRate = expectedReturn / 100.0 / 12.0
        let fvOne = amount * ((pow(1 + monthlyRate, 12) - 1) / monthlyRate)
        let fvFive = amount * ((pow(1 + monthlyRate, 60) - 1) / monthlyRate)

        return GeneratedPortfolio(
            name: name,
            riskScore: riskScore,
            riskLabel: risk.title,
            allocations: allocations,
            expectedReturn: expectedReturn,
            monthlyInvestment: amount,
            projectedValueOneYear: fvOne,
            projectedValueFiveYear: fvFive
        )
    }

    private static func portfolioName(goal: PG.InvestmentGoal, risk: PG.RiskTolerance) -> String {
        switch (goal, risk) {
        case (.wealthGrowth, .aggressive): "Alpha Accelerator"
        case (.wealthGrowth, .moderate): "Growth Navigator"
        case (.wealthGrowth, .conservative): "Steady Climber"
        case (.passiveIncome, _): "Income Engine"
        case (.retirement, .aggressive): "Horizon Booster"
        case (.retirement, _): "Retirement Shield"
        case (.capitalPreservation, _): "Safe Harbor"
        }
    }

    private static func riskScoreValue(risk: PG.RiskTolerance) -> Int {
        switch risk {
        case .conservative: 3
        case .moderate: 6
        case .aggressive: 8
        }
    }

    private static func expectedReturnRate(risk: PG.RiskTolerance, horizon: PG.InvestmentHorizon) -> Double {
        let base: Double = switch risk {
        case .conservative: 4.5
        case .moderate: 7.5
        case .aggressive: 11.0
        }
        let horizonBonus: Double = switch horizon {
        case .shortTerm: -0.5
        case .mediumTerm: 0.0
        case .longTerm: 1.5
        }
        return base + horizonBonus
    }

    private static func buildAllocations(
        risk: PG.RiskTolerance,
        sectors: Set<PG.InvestmentSector>
    ) -> [PortfolioAllocation] {
        let palette: [Color] = [.blue, .green, .orange, .purple, .cyan, .pink, .indigo, .mint]

        switch risk {
        case .conservative:
            var items: [PortfolioAllocation] = [
                .init(assetName: "US Treasury Bond ETF", ticker: "BND", sector: "Bonds", percentage: 35, color: palette[0]),
                .init(assetName: "Investment Grade Corp", ticker: "LQD", sector: "Bonds", percentage: 20, color: palette[1]),
                .init(assetName: "Dividend Aristocrats", ticker: "NOBL", sector: "Equities", percentage: 15, color: palette[2]),
                .init(assetName: "Real Estate Trust", ticker: "VNQ", sector: "Real Estate", percentage: 10, color: palette[3]),
                .init(assetName: "Gold ETF", ticker: "GLD", sector: "Commodities", percentage: 10, color: palette[4]),
            ]
            if sectors.contains(.technology) {
                items.append(.init(assetName: "Tech Value Fund", ticker: "VGT", sector: "Technology", percentage: 10, color: palette[5]))
            } else {
                items.append(.init(assetName: "Short-Term Treasury", ticker: "SHV", sector: "Bonds", percentage: 10, color: palette[5]))
            }
            return items

        case .moderate:
            var items: [PortfolioAllocation] = [
                .init(assetName: "S&P 500 Index", ticker: "VOO", sector: "Equities", percentage: 30, color: palette[0]),
                .init(assetName: "International Developed", ticker: "VEA", sector: "Equities", percentage: 15, color: palette[1]),
                .init(assetName: "Aggregate Bond ETF", ticker: "AGG", sector: "Bonds", percentage: 20, color: palette[2]),
                .init(assetName: "Real Estate Trust", ticker: "VNQ", sector: "Real Estate", percentage: 10, color: palette[3]),
            ]
            if sectors.contains(.technology) {
                items.append(.init(assetName: "Nasdaq 100 ETF", ticker: "QQQ", sector: "Technology", percentage: 15, color: palette[4]))
            } else {
                items.append(.init(assetName: "Emerging Markets", ticker: "VWO", sector: "Equities", percentage: 15, color: palette[4]))
            }
            if sectors.contains(.sustainability) {
                items.append(.init(assetName: "ESG Leaders ETF", ticker: "ESGU", sector: "Sustainability", percentage: 10, color: palette[5]))
            } else {
                items.append(.init(assetName: "Dividend Growth", ticker: "VIG", sector: "Equities", percentage: 10, color: palette[5]))
            }
            return items

        case .aggressive:
            var items: [PortfolioAllocation] = [
                .init(assetName: "Nasdaq 100 ETF", ticker: "QQQ", sector: "Technology", percentage: 25, color: palette[0]),
                .init(assetName: "Growth Stocks ETF", ticker: "VUG", sector: "Equities", percentage: 20, color: palette[1]),
                .init(assetName: "Emerging Markets", ticker: "VWO", sector: "Equities", percentage: 15, color: palette[2]),
            ]
            if sectors.contains(.aiML) {
                items.append(.init(assetName: "AI & Robotics ETF", ticker: "BOTZ", sector: "AI & ML", percentage: 15, color: palette[3]))
            } else {
                items.append(.init(assetName: "Small Cap Growth", ticker: "VBK", sector: "Equities", percentage: 15, color: palette[3]))
            }
            if sectors.contains(.energy) {
                items.append(.init(assetName: "Clean Energy ETF", ticker: "ICLN", sector: "Energy", percentage: 10, color: palette[4]))
            } else {
                items.append(.init(assetName: "Semiconductor ETF", ticker: "SOXX", sector: "Technology", percentage: 10, color: palette[4]))
            }
            if sectors.contains(.healthcare) {
                items.append(.init(assetName: "Biotech ETF", ticker: "IBB", sector: "Healthcare", percentage: 15, color: palette[5]))
            } else {
                items.append(.init(assetName: "Crypto Equity ETF", ticker: "BITO", sector: "Crypto", percentage: 15, color: palette[5]))
            }
            return items
        }
    }
}

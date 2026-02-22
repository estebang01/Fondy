//
//  PortfolioGeneratorState.swift
//  Fondy
//
//  State model for the AI portfolio generation questionnaire flow.
//

import SwiftUI

// MARK: - Generator Step

enum GeneratorStep: Equatable {
    case welcome
    case goal
    case risk
    case horizon
    case amount
    case sectors
    case generating
    case result
}

// MARK: - Investment Goal

enum InvestmentGoal: String, CaseIterable, Identifiable {
    case wealthGrowth
    case passiveIncome
    case retirement
    case capitalPreservation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wealthGrowth: "Wealth Growth"
        case .passiveIncome: "Passive Income"
        case .retirement: "Retirement"
        case .capitalPreservation: "Capital Preservation"
        }
    }

    var description: String {
        switch self {
        case .wealthGrowth: "Maximize long-term capital appreciation"
        case .passiveIncome: "Generate steady recurring income"
        case .retirement: "Build a secure retirement fund"
        case .capitalPreservation: "Protect your wealth with low risk"
        }
    }

    var iconName: String {
        switch self {
        case .wealthGrowth: "chart.line.uptrend.xyaxis"
        case .passiveIncome: "dollarsign.arrow.circlepath"
        case .retirement: "building.columns.fill"
        case .capitalPreservation: "shield.checkerboard"
        }
    }
}

// MARK: - Risk Tolerance

enum RiskTolerance: String, CaseIterable, Identifiable {
    case conservative
    case moderate
    case aggressive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .conservative: "Conservative"
        case .moderate: "Moderate"
        case .aggressive: "Aggressive"
        }
    }

    var description: String {
        switch self {
        case .conservative: "Steady growth, lower volatility"
        case .moderate: "Balanced risk and reward"
        case .aggressive: "Higher risk, higher potential"
        }
    }

    var iconName: String {
        switch self {
        case .conservative: "tortoise.fill"
        case .moderate: "hare.fill"
        case .aggressive: "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .conservative: .green
        case .moderate: .orange
        case .aggressive: .red
        }
    }

    var gaugePosition: CGFloat {
        switch self {
        case .conservative: 0.17
        case .moderate: 0.5
        case .aggressive: 0.83
        }
    }
}

// MARK: - Investment Horizon

enum InvestmentHorizon: String, CaseIterable, Identifiable {
    case shortTerm
    case mediumTerm
    case longTerm

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shortTerm: "Short-term"
        case .mediumTerm: "Medium-term"
        case .longTerm: "Long-term"
        }
    }

    var subtitle: String {
        switch self {
        case .shortTerm: "Less than 1 year"
        case .mediumTerm: "1 to 5 years"
        case .longTerm: "More than 5 years"
        }
    }

    var iconName: String {
        switch self {
        case .shortTerm: "calendar"
        case .mediumTerm: "calendar.badge.clock"
        case .longTerm: "calendar.badge.plus"
        }
    }
}

// MARK: - Investment Sector

enum InvestmentSector: String, CaseIterable, Identifiable {
    case technology
    case healthcare
    case energy
    case finance
    case realEstate
    case consumer
    case aiML
    case sustainability

    var id: String { rawValue }

    var title: String {
        switch self {
        case .technology: "Technology"
        case .healthcare: "Healthcare"
        case .energy: "Energy"
        case .finance: "Finance"
        case .realEstate: "Real Estate"
        case .consumer: "Consumer"
        case .aiML: "AI & ML"
        case .sustainability: "Sustainability"
        }
    }

    var iconName: String {
        switch self {
        case .technology: "laptopcomputer"
        case .healthcare: "heart.fill"
        case .energy: "bolt.fill"
        case .finance: "banknote.fill"
        case .realEstate: "building.2.fill"
        case .consumer: "cart.fill"
        case .aiML: "brain.head.profile.fill"
        case .sustainability: "leaf.fill"
        }
    }
}

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

// MARK: - Portfolio Generator State

@Observable
class PortfolioGeneratorState {

    // MARK: - Navigation

    var step: GeneratorStep = .welcome

    // MARK: - User Selections

    var selectedGoal: InvestmentGoal?
    var selectedRisk: RiskTolerance?
    var selectedHorizon: InvestmentHorizon?
    var monthlyAmount: Double?
    var customAmountText: String = ""
    var selectedSectors: Set<InvestmentSector> = []

    // MARK: - Generation

    var isGenerating: Bool = false
    var generationProgress: Double = 0
    var currentGenerationMessage: String = ""
    var generatedPortfolio: GeneratedPortfolio?

    // MARK: - Preset Amounts

    static let presetAmounts: [Double] = [50, 100, 250, 500, 1000]

    // MARK: - Validation

    var canProceedFromGoal: Bool { selectedGoal != nil }
    var canProceedFromRisk: Bool { selectedRisk != nil }
    var canProceedFromHorizon: Bool { selectedHorizon != nil }
    var canProceedFromAmount: Bool { monthlyAmount != nil && (monthlyAmount ?? 0) > 0 }
    var canProceedFromSectors: Bool { selectedSectors.count >= 2 }

    /// Total question steps (goal through sectors).
    var totalSteps: Int { 5 }

    /// Current question step index (0-based), used by the progress bar.
    var currentStepIndex: Int {
        switch step {
        case .goal: 0
        case .risk: 1
        case .horizon: 2
        case .amount: 3
        case .sectors: 4
        default: 0
        }
    }

    /// Whether the progress bar should be visible.
    var showsProgressBar: Bool {
        switch step {
        case .goal, .risk, .horizon, .amount, .sectors: true
        default: false
        }
    }

    // MARK: - Navigation Actions

    func next() {
        switch step {
        case .welcome: step = .goal
        case .goal: step = .risk
        case .risk: step = .horizon
        case .horizon: step = .amount
        case .amount: step = .sectors
        case .sectors: step = .generating
        case .generating: step = .result
        case .result: break
        }
    }

    func back() {
        switch step {
        case .goal: step = .welcome
        case .risk: step = .goal
        case .horizon: step = .risk
        case .amount: step = .horizon
        case .sectors: step = .amount
        default: break
        }
    }

    func reset() {
        step = .welcome
        selectedGoal = nil
        selectedRisk = nil
        selectedHorizon = nil
        monthlyAmount = nil
        customAmountText = ""
        selectedSectors = []
        isGenerating = false
        generationProgress = 0
        currentGenerationMessage = ""
        generatedPortfolio = nil
    }

    // MARK: - Amount Helpers

    func selectPresetAmount(_ amount: Double) {
        monthlyAmount = amount
        customAmountText = ""
    }

    func applyCustomAmount() {
        let cleaned = customAmountText.filter { $0.isNumber || $0 == "." }
        if let value = Double(cleaned), value > 0 {
            monthlyAmount = value
        }
    }

    /// Formatted display string for the selected amount.
    var formattedAmount: String {
        guard let amount = monthlyAmount else { return "$0" }
        if amount == amount.rounded() && amount < 100_000 {
            return "$\(Int(amount))"
        }
        return String(format: "$%.2f", amount)
    }
}

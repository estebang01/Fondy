//
//  PortfolioGeneratorState.swift
//  Fondy
//
//  State model for the AI portfolio generation questionnaire flow.
//

import SwiftUI

// MARK: - Portfolio Generator State

@Observable
class PortfolioGeneratorState {

    // MARK: - Navigation

    var step: PG.GeneratorStep = .welcome

    // MARK: - User Selections

    var selectedGoal: PG.InvestmentGoal?
    var selectedRisk: PG.RiskTolerance?
    var selectedHorizon: PG.InvestmentHorizon?
    var monthlyAmount: Double?
    var customAmountText: String = ""
    var selectedSectors: Set<PG.InvestmentSector> = []

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
    let totalSteps: Int = 5

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


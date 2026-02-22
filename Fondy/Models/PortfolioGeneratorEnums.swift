//
//  PortfolioGeneratorEnums.swift
//  Fondy
//
//  Enums for the AI portfolio generation questionnaire flow.
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

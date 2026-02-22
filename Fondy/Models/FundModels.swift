//
//  FundModels.swift
//  Fondy
//
//  Fund-related data models: classes, stats, commissions, investment policy, financials.
//

import SwiftUI

// MARK: - Fund Class

/// Represents one share class of a fund (e.g. Class A, B, C).
struct FundClass: Identifiable {
    let id: UUID
    let name: String          // e.g. "Clase A"
    let description: String   // who it is for / key characteristics
    let minimumInvestment: String
    let managementFee: String
    let iconName: String      // SF Symbol

    init(name: String, description: String, minimumInvestment: String,
         managementFee: String, iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.minimumInvestment = minimumInvestment
        self.managementFee = managementFee
        self.iconName = iconName
    }
}

// MARK: - Fund Statistics

/// Detailed operational statistics for a fund.
struct FundStats {
    let valorUnidad: String                  // NAV per unit
    let numeroInversionistas: String         // Number of investors
    let inversionMinima: String              // Minimum investment
    let saldoMinimo: String                  // Minimum balance
    let preaviso: String                     // Withdrawal notice period (days)
    let pacto: String                        // Lock-up period (days)
    let sancion: String                      // Early withdrawal penalty (days)
    let updatedAt: Date

    static func makeDate(_ s: String) -> Date {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.date(from: s) ?? Date()
    }

    static let sample = FundStats(
        valorUnidad:          "$12,847.32",
        numeroInversionistas: "3,241",
        inversionMinima:      "$1,000,000",
        saldoMinimo:          "$500,000",
        preaviso:             "3 días",
        pacto:                "30 días",
        sancion:              "90 días",
        updatedAt:            makeDate("2025-03-31")
    )
}

// MARK: - Fund Commissions

/// Commission structure for a fund.
struct FundCommissions {
    let administracion: String      // Management fee
    let gestion: String             // Advisory/performance mgmt fee
    let exito: String               // Performance/success fee
    let entrada: String             // Entry fee
    let salida: String              // Exit fee
    let efectivoCobrado: String     // Effective total charged last month
    let updatedAt: Date

    static func makeDate(_ s: String) -> Date {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.date(from: s) ?? Date()
    }

    static let sample = FundCommissions(
        administracion:  "1.20% E.A.",
        gestion:         "0.30% E.A.",
        exito:           "10% sobre rentabilidad superior al benchmark",
        entrada:         "0.00%",
        salida:          "0.00%",
        efectivoCobrado: "$154,167",
        updatedAt:       makeDate("2025-03-31")
    )
}

// MARK: - Fund Investment Policy

/// A single data point in the fund investment policy, with a last-updated date.
struct PolicyDataPoint {
    let value: String
    let lastUpdated: Date

    init(value: String, lastUpdated: Date) {
        self.value = value
        self.lastUpdated = lastUpdated
    }
}

/// Investment policy information for a fund.
struct FundInvestmentPolicy {
    // Objective & Strategy
    let investmentObjective: PolicyDataPoint
    let investmentStrategy: PolicyDataPoint

    // Fund Details
    let fundType: PolicyDataPoint
    let inceptionDate: PolicyDataPoint
    let domicile: PolicyDataPoint
    let currency: PolicyDataPoint
    let replicationMethod: PolicyDataPoint

    // Risk & Costs
    let riskProfile: PolicyDataPoint
    let totalExpenseRatio: PolicyDataPoint
    let managementFee: PolicyDataPoint
    let distributionPolicy: PolicyDataPoint

    // Benchmark & Constraints
    let benchmark: PolicyDataPoint
    let geographicFocus: PolicyDataPoint
    let sectorFocus: PolicyDataPoint
    let liquidityRequirements: PolicyDataPoint

    static func makeDate(_ dateString: String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.date(from: dateString) ?? Date()
    }

    static let sampleETF = FundInvestmentPolicy(
        investmentObjective: PolicyDataPoint(
            value: "The fund seeks to track the performance of the S&P 500 Index, which measures the equity performance of 500 large-capitalization companies listed on stock exchanges in the United States. The fund aims to provide investment results that, before fees and expenses, correspond generally to the total return of the index.",
            lastUpdated: makeDate("2025-01-15")
        ),
        investmentStrategy: PolicyDataPoint(
            value: "The fund employs a passive or indexing approach, seeking to track the investment results of the benchmark index. The fund invests at least 80% of its assets in the component securities of its index and in investments that have economic characteristics that are substantially identical to the component securities of its index. The fund uses a representative sampling indexing strategy where applicable to minimize transaction costs and tracking error.",
            lastUpdated: makeDate("2025-01-15")
        ),
        fundType: PolicyDataPoint(value: "Exchange-Traded Fund (ETF)", lastUpdated: makeDate("2024-06-30")),
        inceptionDate: PolicyDataPoint(value: "January 22, 1993", lastUpdated: makeDate("2024-06-30")),
        domicile: PolicyDataPoint(value: "United States", lastUpdated: makeDate("2024-06-30")),
        currency: PolicyDataPoint(value: "USD", lastUpdated: makeDate("2024-06-30")),
        replicationMethod: PolicyDataPoint(value: "Full physical replication with representative sampling for illiquid constituents", lastUpdated: makeDate("2025-01-15")),
        riskProfile: PolicyDataPoint(value: "Moderate to High — Equity market risk, concentration risk, and currency risk for non-USD investors. Suitable for investors with a long-term investment horizon of 5 years or more.", lastUpdated: makeDate("2025-01-15")),
        totalExpenseRatio: PolicyDataPoint(value: "0.03% per annum", lastUpdated: makeDate("2025-01-01")),
        managementFee: PolicyDataPoint(value: "0.03% per annum", lastUpdated: makeDate("2025-01-01")),
        distributionPolicy: PolicyDataPoint(value: "Distributing — Dividends are paid quarterly based on the income received from the underlying securities, less applicable fund expenses.", lastUpdated: makeDate("2025-01-15")),
        benchmark: PolicyDataPoint(value: "S&P 500 Index", lastUpdated: makeDate("2024-06-30")),
        geographicFocus: PolicyDataPoint(value: "United States — 100% of the portfolio is invested in US-listed equities representing diverse industries across the American economy.", lastUpdated: makeDate("2025-01-15")),
        sectorFocus: PolicyDataPoint(value: "Diversified — No single sector concentration. Top sectors include Information Technology (~28%), Healthcare (~13%), Financials (~13%), and Consumer Discretionary (~11%).", lastUpdated: makeDate("2025-01-15")),
        liquidityRequirements: PolicyDataPoint(value: "High liquidity required. The fund only holds securities with sufficient market depth to allow efficient execution. Securities representing less than 0.05% of total AUM are subject to ongoing liquidity review.", lastUpdated: makeDate("2025-01-15"))
    )
}

// MARK: - Financials Models

/// A single bar entry in a financial chart (period label + values).
struct FinancialBarEntry: Identifiable {
    let id: UUID
    let period: String
    let primaryValue: Double   // e.g. Revenue, Total assets, Operating
    let secondaryValue: Double // e.g. Net income, Total liabilities, Investing
    let tertiaryValue: Double  // e.g. 0 for income/balance, Financing for cash flow

    init(period: String, primaryValue: Double, secondaryValue: Double, tertiaryValue: Double = 0) {
        self.id = UUID()
        self.period = period
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.tertiaryValue = tertiaryValue
    }
}

/// Financial statement data for a stock/fund, with both annual and quarterly views.
struct StockFinancials {
    // Income Statement
    let incomeAnnual: [FinancialBarEntry]
    let incomeQuarterly: [FinancialBarEntry]
    let profitMarginAnnual: Double
    let profitMarginQuarterly: Double

    // Balance Sheet
    let balanceAnnual: [FinancialBarEntry]
    let balanceQuarterly: [FinancialBarEntry]
    let debtToAssetsAnnual: Double
    let debtToAssetsQuarterly: Double

    // Cash Flow
    let cashFlowAnnual: [FinancialBarEntry]
    let cashFlowQuarterly: [FinancialBarEntry]

    // Investment Policy (optional — present for funds, nil for individual stocks)
    let investmentPolicy: FundInvestmentPolicy?

    // Fund-specific data (optional — present for funds, nil for individual stocks)
    let fundClasses: [FundClass]
    let fundStats: FundStats?
    let fundCommissions: FundCommissions?

    init(
        incomeAnnual: [FinancialBarEntry],
        incomeQuarterly: [FinancialBarEntry],
        profitMarginAnnual: Double,
        profitMarginQuarterly: Double,
        balanceAnnual: [FinancialBarEntry],
        balanceQuarterly: [FinancialBarEntry],
        debtToAssetsAnnual: Double,
        debtToAssetsQuarterly: Double,
        cashFlowAnnual: [FinancialBarEntry],
        cashFlowQuarterly: [FinancialBarEntry],
        investmentPolicy: FundInvestmentPolicy? = nil,
        fundClasses: [FundClass] = [],
        fundStats: FundStats? = nil,
        fundCommissions: FundCommissions? = nil
    ) {
        self.incomeAnnual = incomeAnnual
        self.incomeQuarterly = incomeQuarterly
        self.profitMarginAnnual = profitMarginAnnual
        self.profitMarginQuarterly = profitMarginQuarterly
        self.balanceAnnual = balanceAnnual
        self.balanceQuarterly = balanceQuarterly
        self.debtToAssetsAnnual = debtToAssetsAnnual
        self.debtToAssetsQuarterly = debtToAssetsQuarterly
        self.cashFlowAnnual = cashFlowAnnual
        self.cashFlowQuarterly = cashFlowQuarterly
        self.investmentPolicy = investmentPolicy
        self.fundClasses = fundClasses
        self.fundStats = fundStats
        self.fundCommissions = fundCommissions
    }

    static let apple = StockFinancials(
        incomeAnnual: [
            FinancialBarEntry(period: "2019", primaryValue: 260.17, secondaryValue: 55.26),
            FinancialBarEntry(period: "2020", primaryValue: 274.52, secondaryValue: 57.41),
            FinancialBarEntry(period: "2021", primaryValue: 365.82, secondaryValue: 94.68),
            FinancialBarEntry(period: "2022", primaryValue: 394.33, secondaryValue: 99.80),
            FinancialBarEntry(period: "2023", primaryValue: 383.29, secondaryValue: 96.99)
        ],
        incomeQuarterly: [
            FinancialBarEntry(period: "Q3'22", primaryValue: 83.00, secondaryValue: 19.44),
            FinancialBarEntry(period: "Q4'22", primaryValue: 117.15, secondaryValue: 29.96),
            FinancialBarEntry(period: "Q1'23", primaryValue: 117.15, secondaryValue: 30.33),
            FinancialBarEntry(period: "Q2'23", primaryValue: 94.84, secondaryValue: 24.16),
            FinancialBarEntry(period: "Q3'23", primaryValue: 81.80, secondaryValue: 19.88)
        ],
        profitMarginAnnual: 25.31,
        profitMarginQuarterly: 24.31,
        balanceAnnual: [
            FinancialBarEntry(period: "2018", primaryValue: 365.72, secondaryValue: 258.58),
            FinancialBarEntry(period: "2019", primaryValue: 338.52, secondaryValue: 248.03),
            FinancialBarEntry(period: "2020", primaryValue: 323.89, secondaryValue: 258.55),
            FinancialBarEntry(period: "2021", primaryValue: 351.00, secondaryValue: 287.91),
            FinancialBarEntry(period: "2022", primaryValue: 352.75, secondaryValue: 302.08)
        ],
        balanceQuarterly: [
            FinancialBarEntry(period: "Q3'22", primaryValue: 352.75, secondaryValue: 302.08),
            FinancialBarEntry(period: "Q4'22", primaryValue: 346.75, secondaryValue: 290.44),
            FinancialBarEntry(period: "Q1'23", primaryValue: 335.03, secondaryValue: 274.76),
            FinancialBarEntry(period: "Q2'23", primaryValue: 335.93, secondaryValue: 274.96),
            FinancialBarEntry(period: "Q3'23", primaryValue: 352.58, secondaryValue: 290.44)
        ],
        debtToAssetsAnnual: 85.64,
        debtToAssetsQuarterly: 82.37,
        cashFlowAnnual: [
            FinancialBarEntry(period: "2018", primaryValue: 77.43, secondaryValue: -14.07, tertiaryValue: -87.88),
            FinancialBarEntry(period: "2019", primaryValue: 69.39, secondaryValue: 45.90, tertiaryValue: -90.98),
            FinancialBarEntry(period: "2020", primaryValue: 80.67, secondaryValue: -4.29, tertiaryValue: -86.82),
            FinancialBarEntry(period: "2021", primaryValue: 104.04, secondaryValue: -14.55, tertiaryValue: -108.77),
            FinancialBarEntry(period: "2022", primaryValue: 122.15, secondaryValue: -22.36, tertiaryValue: -110.75)
        ],
        cashFlowQuarterly: [
            FinancialBarEntry(period: "Q3'22", primaryValue: 21.08, secondaryValue: -3.44, tertiaryValue: -22.96),
            FinancialBarEntry(period: "Q4'22", primaryValue: 34.00, secondaryValue: -1.71, tertiaryValue: -32.00),
            FinancialBarEntry(period: "Q1'23", primaryValue: 28.60, secondaryValue: -3.76, tertiaryValue: -25.17),
            FinancialBarEntry(period: "Q2'23", primaryValue: 23.21, secondaryValue: -8.76, tertiaryValue: -18.18),
            FinancialBarEntry(period: "Q3'23", primaryValue: 21.22, secondaryValue: -3.57, tertiaryValue: -18.97)
        ],
        investmentPolicy: .sampleETF,
        fundClasses: [
            FundClass(
                name: "Clase A",
                description: "Dirigida a personas naturales con inversión inicial desde $1.000.000 COP. Ideal para inversionistas que buscan liquidez con horizonte de mediano plazo.",
                minimumInvestment: "$1,000,000",
                managementFee: "1.50% E.A.",
                iconName: "person.fill"
            ),
            FundClass(
                name: "Clase B",
                description: "Para personas jurídicas y patrimonios autónomos con inversión inicial desde $50.000.000 COP. Condiciones preferenciales por volumen.",
                minimumInvestment: "$50,000,000",
                managementFee: "1.20% E.A.",
                iconName: "building.2.fill"
            ),
            FundClass(
                name: "Clase C",
                description: "Exclusiva para inversionistas institucionales e inversiones superiores a $500.000.000 COP. Comisiones negociadas individualmente y acceso a gestión personalizada.",
                minimumInvestment: "$500,000,000",
                managementFee: "0.80% E.A.",
                iconName: "star.fill"
            )
        ],
        fundStats: .sample,
        fundCommissions: .sample
    )
}

//
//  FundAnalysisModels.swift
//  Fondy
//
//  Data models for fund portfolio analysis breakdowns.
//

import SwiftUI

// MARK: - Analysis Slice

/// A single slice of a donut / breakdown chart.
struct AnalysisSlice: Identifiable {
    let id: UUID
    let label: String      // e.g. "0-180 días", "Colombia"
    let percent: Double    // 0-100
    let color: Color

    init(label: String, percent: Double, color: Color) {
        self.id = UUID()
        self.label = label
        self.percent = percent
        self.color = color
    }
}

// MARK: - Portfolio Duration

/// Duration metrics for the portfolio.
struct PortfolioDuration {
    let duracion: String          // e.g. "2.34 años"
    let duracionSinCash: String   // e.g. "2.51 años"
    let duracionFinal: String     // e.g. "2.41 años"
    let updatedAt: Date
}

// MARK: - Fund Issuer

/// One issuer shown in the Emisores card (always exactly 10).
struct FundIssuer: Identifiable {
    let id: UUID
    let name: String           // Full name e.g. "Bancolombia S.A."
    let ticker: String         // Short label e.g. "BCOL"
    let percent: Double        // Portfolio weight 0-100
    let color: Color           // Slice colour matching the donut
    let logoSymbol: String     // SF Symbol used as logo placeholder
    let logoColor: Color       // Icon tint
    let logoBackground: Color  // Icon circle background

    init(name: String, ticker: String, percent: Double, color: Color,
         logoSymbol: String, logoColor: Color, logoBackground: Color) {
        self.id = UUID()
        self.name = name; self.ticker = ticker; self.percent = percent
        self.color = color; self.logoSymbol = logoSymbol
        self.logoColor = logoColor; self.logoBackground = logoBackground
    }
}

// MARK: - Fund Analysis

/// Full analysis breakdown for a fund.
struct FundAnalysis {
    // Plazos y Duración
    let plazoSlices: [AnalysisSlice]    // time-to-maturity buckets
    let duration: PortfolioDuration

    // Breakdowns — each is an independent donut
    let sectorSlices: [AnalysisSlice]
    let monedaSlices: [AnalysisSlice]
    let paisSlices: [AnalysisSlice]
    let tipoActivoSlices: [AnalysisSlice]

    // Top 10 issuers
    let issuers: [FundIssuer]

    let updatedAt: Date

    static func makeDate(_ s: String) -> Date {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.date(from: s) ?? Date()
    }

    static let sample = FundAnalysis(
        plazoSlices: [
            AnalysisSlice(label: "0-180 días",    percent: 28.5, color: Color(red: 0.18, green: 0.52, blue: 1.0)),
            AnalysisSlice(label: "180-365 días",   percent: 21.3, color: Color(red: 0.35, green: 0.68, blue: 1.0)),
            AnalysisSlice(label: "1-3 años",       percent: 18.7, color: Color(red: 0.55, green: 0.82, blue: 1.0)),
            AnalysisSlice(label: "3-5 años",       percent: 15.2, color: Color(red: 0.20, green: 0.78, blue: 0.70)),
            AnalysisSlice(label: "5-10 años",      percent: 10.8, color: Color(red: 0.14, green: 0.62, blue: 0.55)),
            AnalysisSlice(label: "+10 años",       percent:  5.5, color: Color(red: 0.08, green: 0.44, blue: 0.40)),
        ],
        duration: PortfolioDuration(
            duracion:        "2.34 años",
            duracionSinCash: "2.51 años",
            duracionFinal:   "2.41 años",
            updatedAt: makeDate("2025-03-31")
        ),
        sectorSlices: [
            AnalysisSlice(label: "Financiero",     percent: 34.2, color: Color(red: 0.18, green: 0.52, blue: 1.0)),
            AnalysisSlice(label: "Gobierno",       percent: 28.7, color: Color(red: 0.35, green: 0.68, blue: 1.0)),
            AnalysisSlice(label: "Corporativo",    percent: 18.4, color: Color(red: 0.55, green: 0.82, blue: 1.0)),
            AnalysisSlice(label: "Infraestructura",percent: 10.1, color: Color(red: 0.20, green: 0.78, blue: 0.70)),
            AnalysisSlice(label: "Otros",          percent:  8.6, color: Color(red: 0.60, green: 0.60, blue: 0.65)),
        ],
        monedaSlices: [
            AnalysisSlice(label: "COP",            percent: 72.4, color: Color(red: 0.18, green: 0.52, blue: 1.0)),
            AnalysisSlice(label: "USD",            percent: 18.3, color: Color(red: 0.35, green: 0.68, blue: 1.0)),
            AnalysisSlice(label: "EUR",            percent:  5.8, color: Color(red: 0.55, green: 0.82, blue: 1.0)),
            AnalysisSlice(label: "Otros",          percent:  3.5, color: Color(red: 0.60, green: 0.60, blue: 0.65)),
        ],
        paisSlices: [
            AnalysisSlice(label: "Colombia",       percent: 68.5, color: Color(red: 0.18, green: 0.52, blue: 1.0)),
            AnalysisSlice(label: "Estados Unidos", percent: 15.2, color: Color(red: 0.35, green: 0.68, blue: 1.0)),
            AnalysisSlice(label: "Brasil",         percent:  7.4, color: Color(red: 0.55, green: 0.82, blue: 1.0)),
            AnalysisSlice(label: "México",         percent:  5.1, color: Color(red: 0.20, green: 0.78, blue: 0.70)),
            AnalysisSlice(label: "Otros",          percent:  3.8, color: Color(red: 0.60, green: 0.60, blue: 0.65)),
        ],
        tipoActivoSlices: [
            AnalysisSlice(label: "Renta Fija",     percent: 55.3, color: Color(red: 0.18, green: 0.52, blue: 1.0)),
            AnalysisSlice(label: "CDTs",           percent: 22.8, color: Color(red: 0.35, green: 0.68, blue: 1.0)),
            AnalysisSlice(label: "TES",            percent: 12.4, color: Color(red: 0.55, green: 0.82, blue: 1.0)),
            AnalysisSlice(label: "Liquidez",       percent:  6.2, color: Color(red: 0.20, green: 0.78, blue: 0.70)),
            AnalysisSlice(label: "Otros",          percent:  3.3, color: Color(red: 0.60, green: 0.60, blue: 0.65)),
        ],
        issuers: [
            FundIssuer(name: "Bancolombia S.A.",      ticker: "BCOL", percent: 14.2,
                       color: Color(red: 0.18, green: 0.52, blue: 1.0),
                       logoSymbol: "building.columns.fill", logoColor: .white,
                       logoBackground: Color(red: 0.10, green: 0.40, blue: 0.80)),
            FundIssuer(name: "República de Colombia", ticker: "GOV",  percent: 12.8,
                       color: Color(red: 0.35, green: 0.68, blue: 1.0),
                       logoSymbol: "flag.fill", logoColor: .white,
                       logoBackground: Color(red: 0.20, green: 0.55, blue: 0.30)),
            FundIssuer(name: "Davivienda S.A.",        ticker: "DAVI", percent: 10.5,
                       color: Color(red: 0.55, green: 0.82, blue: 1.0),
                       logoSymbol: "house.fill", logoColor: .white,
                       logoBackground: Color(red: 0.85, green: 0.15, blue: 0.20)),
            FundIssuer(name: "Grupo Bolívar",          ticker: "BOLI", percent:  9.1,
                       color: Color(red: 0.20, green: 0.78, blue: 0.70),
                       logoSymbol: "b.circle.fill", logoColor: .white,
                       logoBackground: Color(red: 0.00, green: 0.55, blue: 0.60)),
            FundIssuer(name: "Ecopetrol S.A.",         ticker: "EC",   percent:  8.3,
                       color: Color(red: 0.14, green: 0.62, blue: 0.55),
                       logoSymbol: "fuelpump.fill", logoColor: .white,
                       logoBackground: Color(red: 0.00, green: 0.35, blue: 0.65)),
            FundIssuer(name: "Banco de Bogotá",        ticker: "BBOG", percent:  7.6,
                       color: Color(red: 0.08, green: 0.44, blue: 0.80),
                       logoSymbol: "banknote.fill", logoColor: .white,
                       logoBackground: Color(red: 0.00, green: 0.30, blue: 0.60)),
            FundIssuer(name: "Celsia S.A.",            ticker: "CELS", percent:  6.2,
                       color: Color(red: 0.30, green: 0.75, blue: 0.90),
                       logoSymbol: "bolt.fill", logoColor: .white,
                       logoBackground: Color(red: 0.00, green: 0.55, blue: 0.75)),
            FundIssuer(name: "Grupo Aval",             ticker: "AVAL", percent:  5.8,
                       color: Color(red: 0.55, green: 0.40, blue: 0.90),
                       logoSymbol: "a.circle.fill", logoColor: .white,
                       logoBackground: Color(red: 0.40, green: 0.20, blue: 0.75)),
            FundIssuer(name: "ISA Intercolombia",      ticker: "ISA",  percent:  4.4,
                       color: Color(red: 0.90, green: 0.55, blue: 0.20),
                       logoSymbol: "powerplug.fill", logoColor: .white,
                       logoBackground: Color(red: 0.75, green: 0.35, blue: 0.00)),
            FundIssuer(name: "Otros emisores",         ticker: "OTROS",percent:  3.1,
                       color: Color(red: 0.60, green: 0.60, blue: 0.65),
                       logoSymbol: "ellipsis.circle.fill", logoColor: .white,
                       logoBackground: Color(red: 0.45, green: 0.45, blue: 0.50)),
        ],
        updatedAt: makeDate("2025-03-31")
    )
}

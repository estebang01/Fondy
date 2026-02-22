//
//  ChartModels.swift
//  Fondy
//

import Foundation

/// A single dated NAV/price data point used by the interactive chart.
struct ChartDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let value: Double

    init(date: Date, value: Double) {
        self.id = UUID()
        self.date = date
        self.value = value
    }
}

/// Chart time period selector.
enum ChartPeriod: String, CaseIterable {
    case oneDay = "1d"
    case oneWeek = "1w"
    case oneMonth = "1m"
    case sixMonths = "6m"
    case oneYear = "1y"
    case fiveYears = "5y"
    case max = "Max"
}

//
//  PeriodReturn.swift
//  Fondy
//

import Foundation

/// A single return figure for a named time period (e.g. "1M", "YTD", "3Y").
struct PeriodReturn: Identifiable {
    let id: UUID
    let label: String       // e.g. "1M", "6M", "YTD", "1Y", "2Y", "3Y"
    let percent: Double     // signed, e.g. 2.34 means +2.34 %
    /// The fund's rank among peers for this period (1 = best).
    let rank: Int
    /// Total number of funds in the peer universe for this period.
    let rankOutOf: Int
    /// Month/year of the data cut-off for this specific period figure.
    let updatedAt: Date

    var isPositive: Bool { percent >= 0 }

    var formattedPercent: String {
        String(format: "%@%.2f%%", percent >= 0 ? "+" : "", percent)
    }

    /// "Mar 2025" style label shown as the data cut-off.
    var formattedUpdatedAt: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt.string(from: updatedAt)
    }

    init(label: String, percent: Double, rank: Int, rankOutOf: Int, updatedAt: Date) {
        self.id = UUID()
        self.label = label
        self.percent = percent
        self.rank = rank
        self.rankOutOf = rankOutOf
        self.updatedAt = updatedAt
    }

    /// Convenience: build a Date from "yyyy-MM" string.
    static func date(_ ym: String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return fmt.date(from: ym) ?? Date()
    }
}

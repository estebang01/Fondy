//
//  AccountModels.swift
//  Fondy
//
//  Pure data models for the Home Account screen.
//  Kept separate from HomeAccountViewModel to respect SRP —
//  models have no dependency on view-level state.
//

import SwiftUI

// MARK: - Account Tab

/// The tabs shown on the Home Account screen.
enum AccountTab: String, CaseIterable, Identifiable {
    case stocks   = "Stocks"
    case accounts = "Accounts"
    case cards    = "Cards"

    var id: String { rawValue }
}

// MARK: - Account Info

/// Represents a single bank/currency account.
struct AccountInfo: Identifiable {
    let id: UUID
    let balance: Double
    let currencyCode: String
    let currencySymbol: String
    let currencyName: String
    let countryCode: String

    var flagURL: URL? {
        URL(string: "https://flagcdn.com/w160/\(countryCode.lowercased()).png")
    }
}

// MARK: - Home Action Item

/// An action/notification item displayed in the "Actions" section.
struct HomeActionItem: Identifiable {
    let id: UUID
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let subtitleColor: Color
    let trailingAmount: String?
    let trailingStatus: String?
    let trailingStatusColor: Color
}

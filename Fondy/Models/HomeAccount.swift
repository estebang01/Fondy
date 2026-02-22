//
//  HomeAccount.swift
//  Fondy
//
//  Data models and view model for the Home Account screen.
//

import SwiftUI

// MARK: - Account Tab

/// The tabs shown on the Home Account screen.
enum AccountTab: String, CaseIterable, Identifiable {
    case stocks = "Stocks"
    case accounts = "Accounts"
    case cards = "Cards"

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

// MARK: - Action Item

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

// MARK: - Home Account ViewModel

/// Manages state for the Home Account screen.
///
/// Owns the selected tab, account data, action items, and UI state
/// like the banner visibility and search text.
@Observable
class HomeAccountViewModel {
    // MARK: - Tab State

    var selectedTab: AccountTab = .stocks

    // MARK: - Account Data

    var account: AccountInfo
    var transactions: [Transaction]
    var actionItems: [HomeActionItem]

    // MARK: - UI State

    var searchText = ""
    var showCustomizeBanner = true

    // MARK: - User Info

    var userInitials: String

    // MARK: - Initialization

    init(
        account: AccountInfo,
        transactions: [Transaction] = [],
        actionItems: [HomeActionItem] = [],
        userInitials: String = "JS"
    ) {
        self.account = account
        self.transactions = transactions
        self.actionItems = actionItems
        self.userInitials = userInitials
    }

    // MARK: - Actions

    func removeActionItem(id: UUID) {
        actionItems.removeAll { $0.id == id }
    }

    // MARK: - Mock Data

    static func createMock() -> HomeAccountViewModel {
        HomeAccountViewModel(
            account: AccountInfo(
                id: UUID(),
                balance: 6_158.42,
                currencyCode: "GBP",
                currencySymbol: "£",
                currencyName: "British Pound",
                countryCode: "GB"
            ),
            transactions: mockTransactions,
            actionItems: mockActionItems,
            userInitials: "EG"
        )
    }

    // MARK: - Mock Transactions

    static let mockTransactions: [Transaction] = [
        Transaction(
            id: UUID(),
            name: "Airbnb",
            iconName: "house.fill",
            iconBackground: Color(.systemPink),
            amount: -99.00,
            currencySymbol: "£",
            time: "12:10"
        ),
        Transaction(
            id: UUID(),
            name: "Spotify",
            iconName: "music.note",
            iconBackground: Color(.systemGreen),
            amount: -9.99,
            currencySymbol: "£",
            time: "Yesterday"
        ),
        Transaction(
            id: UUID(),
            name: "Transfer In",
            iconName: "arrow.down.left",
            iconBackground: Color(.systemBlue),
            amount: 500.00,
            currencySymbol: "£",
            time: "Monday"
        ),
        Transaction(
            id: UUID(),
            name: "Netflix",
            iconName: "play.tv.fill",
            iconBackground: Color(.systemRed),
            amount: -17.99,
            currencySymbol: "£",
            time: "Sunday"
        ),
        Transaction(
            id: UUID(),
            name: "Amazon",
            iconName: "cart.fill",
            iconBackground: Color(.systemOrange),
            amount: -43.50,
            currencySymbol: "£",
            time: "Sat"
        ),
    ]

    // MARK: - Mock Action Items

    static let mockActionItems: [HomeActionItem] = [
        HomeActionItem(
            id: UUID(),
            iconName: "person.badge.shield.checkmark.fill",
            iconColor: .blue,
            title: "Verify your identity",
            subtitle: "Required to send & receive money",
            subtitleColor: .orange,
            trailingAmount: nil,
            trailingStatus: "Pending",
            trailingStatusColor: .orange
        ),
        HomeActionItem(
            id: UUID(),
            iconName: "leaf.fill",
            iconColor: .green,
            title: "Metal plan",
            subtitle: "Upgrade for more features",
            subtitleColor: Color(.systemGray),
            trailingAmount: "-£19.99/mo",
            trailingStatus: nil,
            trailingStatusColor: .orange
        ),
    ]
}


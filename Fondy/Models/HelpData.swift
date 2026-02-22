//
//  HelpData.swift
//  Fondy
//
//  Data models and mock content for the Help Center.
//

import SwiftUI

// MARK: - Help Category

/// A top-level help category shown on the Help Center landing page.
struct HelpCategory: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let articles: [HelpArticle]
    let transactions: [HelpTransaction]

    init(title: String, iconName: String, articles: [HelpArticle] = [], transactions: [HelpTransaction] = []) {
        self.title = title
        self.iconName = iconName
        self.articles = articles
        self.transactions = transactions
    }
}

// MARK: - Help Transaction

/// A transaction shown in the "Select a transaction" section of a help topic.
struct HelpTransaction: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let amount: String
    let iconName: String
    let iconColor: Color
    let iconBackground: Color
}

// MARK: - Help Article

/// A help article with rich content blocks.
struct HelpArticle: Identifiable {
    let id = UUID()
    let title: String
    let blocks: [ArticleBlock]
}

// MARK: - Article Block

/// A content block inside a help article.
enum ArticleBlock: Identifiable {
    case paragraph(String)
    case bold(String)
    case link(text: String, label: String)
    case orderedList([String])
    case unorderedList([String])
    case warning(emoji: String, text: String)

    var id: String {
        switch self {
        case .paragraph(let t): return "p_\(t.prefix(30))"
        case .bold(let t):      return "b_\(t.prefix(30))"
        case .link(let t, _):   return "l_\(t.prefix(30))"
        case .orderedList(let items): return "ol_\(items.first?.prefix(20) ?? "")"
        case .unorderedList(let items): return "ul_\(items.first?.prefix(20) ?? "")"
        case .warning(_, let t): return "w_\(t.prefix(30))"
        }
    }
}

// MARK: - Mock Data

enum HelpMockData {

    // MARK: - Categories

    static let categories: [HelpCategory] = [
        HelpCategory(
            title: "Security and fraud",
            iconName: "lock.fill"
        ),
        HelpCategory(
            title: "Account management",
            iconName: "person.fill"
        ),
        HelpCategory(
            title: "Adding money",
            iconName: "plus",
            articles: addingMoneyArticles
        ),
        HelpCategory(
            title: "Transfers",
            iconName: "arrow.left.arrow.right"
        ),
        HelpCategory(
            title: "Card payments",
            iconName: "creditcard.fill"
        ),
        HelpCategory(
            title: "Cards",
            iconName: "creditcard.fill"
        ),
        HelpCategory(
            title: "Subscriptions and upcoming payments",
            iconName: "calendar",
            articles: subscriptionArticles,
            transactions: subscriptionTransactions
        ),
        HelpCategory(
            title: "Referrals",
            iconName: "heart.fill"
        ),
        HelpCategory(
            title: "Currencies, crypto and trading",
            iconName: "chart.line.uptrend.xyaxis"
        ),
        HelpCategory(
            title: "Products and perks",
            iconName: "square.grid.2x2.fill"
        ),
    ]

    // MARK: - Subscription Transactions

    static let subscriptionTransactions: [HelpTransaction] = [
        HelpTransaction(
            name: "Spotify",
            subtitle: "Monthly, next on Nov 29",
            amount: "-S$1",
            iconName: "music.note",
            iconColor: .white,
            iconBackground: Color(red: 0.12, green: 0.72, blue: 0.39)
        ),
        HelpTransaction(
            name: "Jane Smith",
            subtitle: "Weekly, next on Oct 30",
            amount: "-S$1",
            iconName: "building.columns.fill",
            iconColor: .blue,
            iconBackground: Color(.systemGray5)
        ),
    ]

    // MARK: - Subscription Articles

    static let subscriptionArticles: [HelpArticle] = [
        HelpArticle(
            title: "What are Scheduled Payments?",
            blocks: [
                .paragraph("Scheduled Payments are recurring transfers that you set up to automatically send money at regular intervals."),
                .paragraph("They can be set to repeat daily, weekly, monthly, or at custom intervals."),
            ]
        ),
        HelpArticle(
            title: "Keeping track of your Scheduled Payments",
            blocks: [
                .paragraph("You can view all your scheduled payments in the Transfers tab under 'Scheduled'."),
                .paragraph("Each payment shows the recipient, amount, frequency, and next payment date."),
            ]
        ),
        HelpArticle(
            title: "How to set up Scheduled Payments with Fondy?",
            blocks: [
                .paragraph("Setting up a scheduled payment is easy:"),
                .orderedList([
                    "Go to the Transfers tab",
                    "Tap 'Send money'",
                    "Select or add a recipient",
                    "Enter the amount",
                    "Toggle on 'Make this a recurring payment'",
                    "Choose your frequency and start date",
                ]),
            ]
        ),
        HelpArticle(
            title: "How can I set aside money for a recurring payment?",
            blocks: [
                .paragraph("You can set aside money for any recurring payment using Pockets."),
                .link(text: "Pockets", label: "Pockets"),
                .paragraph("Pockets allow you to set aside money before a payment is due so the transaction never fails and you are not charged currency conversion fees!"),
                .bold("To set up a new pocket:"),
                .orderedList([
                    "Create and name your new pocket",
                    "Select the payment(s) to be paid out of the pocket",
                    "Set up recurring funding to the pocket",
                ]),
                .bold("To add a payment to an existing pocket:"),
                .unorderedList([
                    "Select the pocket",
                    "Click on **Manage** next to 'Scheduled outgoings'",
                    "Click **+ Add payment** and select or find the payment from your history.",
                ]),
                .paragraph("To remove a payment from a pocket, simply tap on the payment under 'Scheduled outgoings' and click"),
                .warning(emoji: "\u{274C}", text: "Stop paying from this pocket."),
            ]
        ),
        HelpArticle(
            title: "Scheduled and Recurring Transfers",
            blocks: [
                .paragraph("Scheduled and recurring transfers allow you to automate your regular payments so you never miss a due date."),
                .paragraph("You can modify or cancel any scheduled transfer at any time from the Transfers tab."),
            ]
        ),
    ]

    // MARK: - Adding Money Articles

    static let addingMoneyArticles: [HelpArticle] = [
        HelpArticle(
            title: "How to add money to your Fondy account",
            blocks: [
                .paragraph("There are several ways to add money to your Fondy account:"),
                .orderedList([
                    "Bank transfer from your linked bank account",
                    "Debit card top-up",
                    "Apple Pay",
                ]),
                .bold("Using bank transfer:"),
                .paragraph("Navigate to your account details and use the provided account number and bank name to initiate a transfer from your bank."),
            ]
        ),
    ]
}

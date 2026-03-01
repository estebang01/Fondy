//
//  HelpMessage.swift
//  Fondy
//
//  Data models, FAQ knowledge base, and @Observable HelpViewModel
//  for the FAQ / Help chat module.
//

import SwiftUI

// MARK: - Help Role

enum HelpRole {
    case user
    case bot
    /// Centered system pill — used for "Showing X category" and escalation notices.
    case system
}

// MARK: - Feedback State

enum FeedbackState {
    case none
    case helpful
    case notHelpful
}

// MARK: - FAQ Category

enum FAQCategory: String, CaseIterable, Identifiable {
    case gettingStarted = "Getting Started"
    case portfolio      = "Portfolio"
    case payments       = "Payments"
    case security       = "Security"
    case account        = "Account"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gettingStarted: return "star.fill"
        case .portfolio:      return "chart.pie.fill"
        case .payments:       return "creditcard.fill"
        case .security:       return "shield.fill"
        case .account:        return "person.fill"
        }
    }

    var tint: Color {
        switch self {
        case .gettingStarted: return .orange
        case .portfolio:      return .blue
        case .payments:       return .green
        case .security:       return .purple
        case .account:        return .cyan
        }
    }
}

// MARK: - FAQ

struct FAQ: Identifiable {
    let id: String
    let category: FAQCategory
    let question: String
    let answer: String
    var relatedIDs: [String]
}

// MARK: - Help Message

struct HelpMessage: Identifiable {
    let id: UUID
    var role: HelpRole
    var content: String
    var isStreaming: Bool
    var relatedFAQs: [FAQ]
    var feedbackState: FeedbackState

    init(
        id: UUID = UUID(),
        role: HelpRole,
        content: String,
        isStreaming: Bool = false,
        relatedFAQs: [FAQ] = [],
        feedbackState: FeedbackState = .none
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.isStreaming = isStreaming
        self.relatedFAQs = relatedFAQs
        self.feedbackState = feedbackState
    }
}

// MARK: - FAQ Knowledge Base

enum FAQKnowledgeBase {

    // MARK: Getting Started

    private static let gettingStarted: [FAQ] = [
        FAQ(
            id: "gs_1",
            category: .gettingStarted,
            question: "How do I get started with Fondy?",
            answer: "Welcome to Fondy! Here's how to get up and running:\n\n1. Complete your profile with personal information\n2. Verify your identity (takes ~2 minutes)\n3. Add funds to your account\n4. Start exploring investments\n\nNeed help with a specific step? Just ask!",
            relatedIDs: ["gs_2", "pay_1"]
        ),
        FAQ(
            id: "gs_2",
            category: .gettingStarted,
            question: "How does identity verification work?",
            answer: "Identity verification (KYC) is required by regulation to keep your account secure.\n\nYou'll need:\n• A valid government-issued ID (passport or driver's license)\n• A selfie for a liveness check\n\nVerification typically completes in 1–3 minutes. Your documents are encrypted and never shared with third parties.",
            relatedIDs: ["sec_1", "gs_1"]
        ),
        FAQ(
            id: "gs_3",
            category: .gettingStarted,
            question: "Is Fondy available in my country?",
            answer: "Fondy is currently available in:\n\n• United States\n• United Kingdom\n• European Union\n• Singapore\n• Australia\n\nWe're expanding rapidly. If your country isn't listed, join the waitlist in the app to be notified when we launch there.",
            relatedIDs: ["gs_1", "acc_1"]
        ),
    ]

    // MARK: Portfolio

    private static let portfolio: [FAQ] = [
        FAQ(
            id: "port_1",
            category: .portfolio,
            question: "How do I buy stocks?",
            answer: "Buying stocks on Fondy is straightforward:\n\n1. Tap the search bar or browse the Stocks tab\n2. Find the stock you want (e.g., AAPL, TSLA)\n3. Tap \"Buy\" and enter your amount\n4. Review the order details and confirm\n\nOrders execute at market price during trading hours (9:30 AM – 4:00 PM ET, Mon–Fri).",
            relatedIDs: ["port_2", "pay_1"]
        ),
        FAQ(
            id: "port_2",
            category: .portfolio,
            question: "What are the trading hours?",
            answer: "Fondy supports the following trading windows:\n\n• Regular hours: 9:30 AM – 4:00 PM ET (Mon–Fri)\n• Pre-market: 4:00 AM – 9:30 AM ET\n• After-hours: 4:00 PM – 8:00 PM ET\n\nMarkets are closed on US public holidays. Orders placed outside hours execute at the next market open.",
            relatedIDs: ["port_1", "port_3"]
        ),
        FAQ(
            id: "port_3",
            category: .portfolio,
            question: "How is portfolio performance calculated?",
            answer: "Your portfolio performance is calculated as:\n\n• Total return = (Current value − Invested) ÷ Invested × 100\n• Daily change = Change since yesterday's market close\n• All-time return = Since your very first investment\n\nAll figures are in your account's base currency. Returns include price appreciation; dividends are shown separately.",
            relatedIDs: ["port_1", "port_4"]
        ),
        FAQ(
            id: "port_4",
            category: .portfolio,
            question: "How do I rebalance my portfolio?",
            answer: "To rebalance:\n\n1. Go to your Portfolio tab\n2. Tap \"Rebalance\" in the header menu\n3. Review the suggested target vs. current allocation\n4. Confirm the rebalancing trades\n\nTip: Run the AI Portfolio Generator first to get a personalised target allocation based on your risk profile.",
            relatedIDs: ["port_3", "gs_1"]
        ),
    ]

    // MARK: Payments

    private static let payments: [FAQ] = [
        FAQ(
            id: "pay_1",
            category: .payments,
            question: "How do I add money to my account?",
            answer: "You can fund your Fondy account via:\n\n• Bank transfer (ACH) — Free, 1–3 business days\n• Instant transfer — Small fee, funds available immediately\n• Wire transfer — For large amounts over $10,000\n\nTo add funds: Account tab → \"Add Funds\" → choose your method.",
            relatedIDs: ["pay_2", "pay_3"]
        ),
        FAQ(
            id: "pay_2",
            category: .payments,
            question: "How long does a withdrawal take?",
            answer: "Withdrawal timelines:\n\n• Standard ACH: 1–3 business days\n• Instant withdrawal: Within minutes (up to $1,000/day)\n• Wire transfer: Same business day if initiated before 1 PM ET\n\nNote: Funds from recent stock sales must settle (T+2) before they can be withdrawn.",
            relatedIDs: ["pay_1", "pay_3"]
        ),
        FAQ(
            id: "pay_3",
            category: .payments,
            question: "What fees does Fondy charge?",
            answer: "Fondy's fee structure is transparent:\n\n• Stock & ETF trades: $0 commission\n• Instant deposits: 1.5% fee (min $0.50)\n• Outgoing wire transfers: $25\n• Monthly inactivity fee: None\n• Account maintenance: None\n\nPremium subscribers get additional features — see Plan details in your Profile.",
            relatedIDs: ["pay_1", "pay_2"]
        ),
    ]

    // MARK: Security

    private static let security: [FAQ] = [
        FAQ(
            id: "sec_1",
            category: .security,
            question: "Is my money safe with Fondy?",
            answer: "Your funds are protected on multiple levels:\n\n• Securities insured by SIPC up to $500,000\n• Uninvested cash insured by FDIC up to $250,000\n• 256-bit AES encryption for all data in transit and at rest\n• Two-factor authentication\n• Biometric login\n\nFondy is registered with FINRA and the SEC.",
            relatedIDs: ["sec_2", "sec_3"]
        ),
        FAQ(
            id: "sec_2",
            category: .security,
            question: "How do I enable two-factor authentication?",
            answer: "Enable 2FA in three steps:\n\n1. Profile → Security & Privacy\n2. Tap \"Two-Factor Authentication\"\n3. Choose SMS or an authenticator app (recommended)\n\nWe strongly recommend an authenticator app like 1Password or Authy over SMS for stronger protection.",
            relatedIDs: ["sec_1", "sec_3"]
        ),
        FAQ(
            id: "sec_3",
            category: .security,
            question: "I think my account has been compromised",
            answer: "Act quickly if you suspect unauthorised access:\n\n1. Change your password immediately (Profile → Account → Change Password)\n2. Enable 2FA if not already active\n3. Revoke all active sessions (Profile → Account → Active Sessions)\n4. Email our security team at security@fondy.app\n\nWe monitor all accounts 24/7 for suspicious activity.",
            relatedIDs: ["sec_1", "sec_2"]
        ),
    ]

    // MARK: Account

    private static let account: [FAQ] = [
        FAQ(
            id: "acc_1",
            category: .account,
            question: "How do I change my email or password?",
            answer: "To update your credentials:\n\n• Change email: Profile → Account → Edit Profile\n• Change password: Profile → Account → Change Password\n\nEmail changes require confirmation from both old and new addresses. Password changes immediately sign out all other active sessions.",
            relatedIDs: ["acc_2", "sec_2"]
        ),
        FAQ(
            id: "acc_2",
            category: .account,
            question: "How do I close my account?",
            answer: "To close your account:\n\n1. Sell all open positions\n2. Withdraw all remaining funds\n3. Profile → Account → Delete Account\n4. Confirm via the email we send you\n\nClosure is permanent. We retain transaction records for 7 years per legal requirements. Contact support within 30 days if you change your mind.",
            relatedIDs: ["acc_1", "pay_2"]
        ),
        FAQ(
            id: "acc_3",
            category: .account,
            question: "Where can I find my tax documents?",
            answer: "Tax documents are available in the app:\n\n1. Profile → Documents → Tax Documents\n2. Select the tax year\n3. Download 1099-B (stock sales) or 1099-DIV (dividends)\n\nDocuments are published by mid-February each year. You'll receive an email when they're ready.",
            relatedIDs: ["acc_1", "acc_2"]
        ),
    ]

    // MARK: - Accessors

    static let all: [FAQ] = gettingStarted + portfolio + payments + security + account

    static func faq(by id: String) -> FAQ? {
        all.first { $0.id == id }
    }

    static func faqs(for category: FAQCategory) -> [FAQ] {
        all.filter { $0.category == category }
    }

    /// Hand-picked popular questions shown in the empty state.
    static var popular: [FAQ] {
        ["gs_1", "pay_1", "port_1", "sec_1"].compactMap { faq(by: $0) }
    }
}

// MARK: - Help View Model

@Observable
final class HelpViewModel {

    // MARK: State

    var messages: [HelpMessage] = []
    var inputText: String = ""
    var isThinking: Bool = false

    // MARK: - Public Actions

    /// Send the current inputText as a user message.
    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isThinking else { return }
        messages.append(HelpMessage(role: .user, content: trimmed))
        inputText = ""
        Task { await generateAnswer(to: trimmed) }
    }

    /// Tap a suggestion chip or popular question.
    func selectFAQ(_ faq: FAQ) {
        guard !isThinking else { return }
        messages.append(HelpMessage(role: .user, content: faq.question))
        Task { await streamAnswer(for: faq) }
    }

    /// Select a category from the empty-state chips.
    func selectCategory(_ category: FAQCategory) {
        messages.append(HelpMessage(role: .system, content: "Showing \(category.rawValue) questions"))
        let faqs = FAQKnowledgeBase.faqs(for: category)
        let botContent = "Here are the \(category.rawValue) topics I can help with:"
        let msg = HelpMessage(role: .bot, content: botContent, relatedFAQs: faqs)
        messages.append(msg)
    }

    /// Record thumbs up / down on a bot message.
    func provideFeedback(messageId: UUID, isHelpful: Bool) {
        guard let i = messages.firstIndex(where: { $0.id == messageId }),
              messages[i].feedbackState == .none else { return }
        messages[i].feedbackState = isHelpful ? .helpful : .notHelpful
        Haptics.selection()
    }

    /// Escalate to a human support agent.
    func escalateToSupport() {
        guard !isThinking else { return }
        messages.append(HelpMessage(role: .system, content: "Connecting you to support…"))
        Task {
            isThinking = true
            try? await Task.sleep(for: .milliseconds(1100))
            isThinking = false
            let reply = HelpMessage(
                role: .bot,
                content: "I've flagged your conversation for our support team.\n\nYou can also reach us directly:\n\n• Email: support@fondy.app\n• Response time: Usually within 2 hours (Mon–Fri, 9 AM–6 PM ET)\n\nA support agent will follow up with you at your registered email address shortly."
            )
            messages.append(reply)
        }
    }

    /// Clear the entire conversation.
    func clear() {
        messages.removeAll()
    }

    // MARK: - Private

    private func generateAnswer(to query: String) async {
        isThinking = true
        try? await Task.sleep(for: .milliseconds(650))

        if let match = findBestFAQ(for: query) {
            await streamAnswer(for: match)
        } else {
            await streamFallback()
        }
    }

    private func findBestFAQ(for query: String) -> FAQ? {
        let lower = query.lowercased()
        let scored: [(FAQ, Int)] = FAQKnowledgeBase.all.map { faq in
            var score = 0
            // Exact question-word matches score highest
            let questionWords = faq.question.lowercased().split(separator: " ").map(String.init)
            for word in questionWords where word.count > 3 {
                if lower.contains(word) { score += 3 }
            }
            // Category keyword match
            if lower.contains(faq.category.rawValue.lowercased()) { score += 1 }
            // Answer body keyword match
            let answerWords = faq.answer.lowercased().split(separator: " ").map(String.init)
            for word in answerWords where word.count > 5 {
                if lower.contains(word) { score += 1 }
            }
            return (faq, score)
        }
        return scored.max(by: { $0.1 < $1.1 }).flatMap { $0.1 >= 3 ? $0.0 : nil }
    }

    private func streamAnswer(for faq: FAQ) async {
        isThinking = false
        let related = faq.relatedIDs.compactMap { FAQKnowledgeBase.faq(by: $0) }
        var msg = HelpMessage(role: .bot, content: "", isStreaming: true, relatedFAQs: related)
        messages.append(msg)
        let msgId = msg.id

        for char in faq.answer {
            try? await Task.sleep(for: .milliseconds(12))
            guard !Task.isCancelled else { break }
            guard let i = messages.firstIndex(where: { $0.id == msgId }) else { break }
            messages[i].content.append(char)
        }
        if let i = messages.firstIndex(where: { $0.id == msgId }) {
            messages[i].isStreaming = false
        }
    }

    private func streamFallback() async {
        isThinking = false
        let text = "I couldn't find an exact match for that question.\n\nHere are a few things to try:\n• Rephrase your question with different keywords\n• Browse topics using the category chips\n• Tap \"Support\" at the top to reach a human agent\n\nIs there anything else I can help with?"
        var msg = HelpMessage(role: .bot, content: "", isStreaming: true)
        messages.append(msg)
        let msgId = msg.id

        for char in text {
            try? await Task.sleep(for: .milliseconds(12))
            guard !Task.isCancelled else { break }
            guard let i = messages.firstIndex(where: { $0.id == msgId }) else { break }
            messages[i].content.append(char)
        }
        if let i = messages.firstIndex(where: { $0.id == msgId }) {
            messages[i].isStreaming = false
        }
    }
}

//
//  StockInvestmentCarousel.swift
//  Fondy
//
//  Horizontal scrolling strip of compact investment cards.
//  Each card shows the stock logo, ticker, amount invested,
//  and a masked account reference — matching the currency-card
//  carousel pattern in the image reference.
//

import SwiftUI

// MARK: - Entry Model

/// Lightweight model backing a single investment card in the carousel.
struct StockInvestmentEntry: Identifiable {
    let id: UUID
    let ticker: String
    let companyName: String
    let logoSystemName: String
    let logoColor: Color
    let logoBackground: Color
    /// Total amount the user has invested in this stock.
    let investedAmount: Double
    let currencySymbol: String
    /// Masked brokerage reference shown at the bottom of the card (e.g. "·· 3421").
    let accountRef: String

    // MARK: - Mock Data

    static let mock: [StockInvestmentEntry] = [
        StockInvestmentEntry(
            id: UUID(), ticker: "AAPL", companyName: "Apple",
            logoSystemName: "apple.logo", logoColor: .white,
            logoBackground: .black,
            investedAmount: 4_820.50, currencySymbol: "$",
            accountRef: "·· 1842"
        ),
        StockInvestmentEntry(
            id: UUID(), ticker: "NVDA", companyName: "NVIDIA",
            logoSystemName: "cpu.fill", logoColor: .white,
            logoBackground: Color(red: 0.12, green: 0.78, blue: 0.40),
            investedAmount: 12_340.00, currencySymbol: "$",
            accountRef: "·· 7295"
        ),
        StockInvestmentEntry(
            id: UUID(), ticker: "TSLA", companyName: "Tesla",
            logoSystemName: "bolt.car.fill", logoColor: .white,
            logoBackground: Color(red: 0.90, green: 0.15, blue: 0.15),
            investedAmount: 2_198.75, currencySymbol: "$",
            accountRef: "·· 5530"
        ),
        StockInvestmentEntry(
            id: UUID(), ticker: "MSFT", companyName: "Microsoft",
            logoSystemName: "square.grid.2x2.fill", logoColor: .white,
            logoBackground: Color(red: 0.0, green: 0.47, blue: 0.84),
            investedAmount: 7_654.30, currencySymbol: "$",
            accountRef: "·· 3106"
        ),
        StockInvestmentEntry(
            id: UUID(), ticker: "AMZN", companyName: "Amazon",
            logoSystemName: "cart.fill", logoColor: .white,
            logoBackground: Color(red: 1.0, green: 0.60, blue: 0.0),
            investedAmount: 3_410.00, currencySymbol: "$",
            accountRef: "·· 9883"
        ),
    ]
}

// MARK: - Single Card

private struct StockInvestmentCard: View {
    let entry: StockInvestmentEntry
    @State private var isPressed = false

    private let cardWidth: CGFloat  = 165
    private let cardHeight: CGFloat = 200
    private let logoSize: CGFloat   = 48

    var body: some View {
        Button {
            Haptics.light()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // ── Top: logo ───────────────────────────────
                ZStack {
                    Circle()
                        .fill(entry.logoBackground)
                        .frame(width: logoSize, height: logoSize)
                    
                    Image(systemName: entry.logoSystemName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(entry.logoColor)
                }
                .accessibilityHidden(true)
                .padding(.bottom, Spacing.md)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.ticker)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(entry.companyName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // ── Center: invested amount ──────────────────────────
                VStack(alignment: .leading, spacing: 3) {
                    Text("Invested")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.3)

                    Text("\(entry.currencySymbol)\(formattedAmount)")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                Spacer()

                // ── Bottom: account ref ──────────────────────────────
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                    Text(entry.accountRef)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Spacing.lg)
            .frame(width: cardWidth, height: cardHeight)
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(InvestmentCardButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.companyName), \(entry.ticker), \(entry.currencySymbol)\(formattedAmount) invested")
    }

    private var formattedAmount: String {
        let formatted = String(format: "%.2f", entry.investedAmount)
        // Insert thousand separators manually
        let parts = formatted.split(separator: ".")
        guard let intPart = parts.first else { return formatted }
        let decPart = parts.count > 1 ? ".\(parts[1])" : ""
        let digits = String(intPart)
        var result = ""
        for (index, char) in digits.reversed().enumerated() {
            if index > 0 && index % 3 == 0 { result.insert(",", at: result.startIndex) }
            result.insert(char, at: result.startIndex)
        }
        return result + decPart
    }
}

// MARK: - Custom Button Style for Cards

private struct InvestmentCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Carousel

/// Horizontal scrolling strip of compact stock investment cards.
///
/// Drop in anywhere; pass `entries` to populate or use the built-in mock:
/// ```swift
/// StockInvestmentCarousel()                        // uses mock data
/// StockInvestmentCarousel(entries: myEntries)      // live data
/// ```
struct StockInvestmentCarousel: View {
    var entries: [StockInvestmentEntry] = StockInvestmentEntry.mock

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(entries) { entry in
                    StockInvestmentCard(entry: entry)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.vertical, 8)      // allow shadow and glass to breathe
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollClipDisabled()                    // let the next card peek through
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("My Investments")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(.label))
                .padding(.horizontal, Spacing.pageMargin)

            StockInvestmentCarousel()
        }
        .padding(.top, Spacing.xl)
    }
}

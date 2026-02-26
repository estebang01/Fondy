//
//  TopMoversAllView.swift
//  Fondy
//
//  Full-screen "Top movers" list pushed from StocksView "See all".
//  Matches the Revolut-style top movers detail screen exactly.
//

import SwiftUI

// MARK: - Filter Enums

private enum MoverFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case topGainers = "Top gainers"
    case topLosers = "Top losers"
    var id: String { rawValue }
}

private enum TimeFilter: String, CaseIterable, Identifiable {
    case oneDay = "1 Day"
    case oneWeek = "1 week"
    case oneMonth = "1 month"
    case oneYear = "1 year"
    case fiveYears = "5 years"
    var id: String { rawValue }
}

// MARK: - Top Movers All View

/// Full-screen list of all top-moving stocks.
///
/// Features: large title + subtitle, "All" and "1 Day" filter pills,
/// a white card with list rows (logo + name/ticker·sector + price/change%),
/// "Discover all stocks" link, and a legal disclaimer footer.
struct TopMoversAllView: View {
    let movers: [TopMover]
    var onSelectMover: ((TopMover) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var selectedMoverFilter: MoverFilter = .all
    @State private var selectedTimeFilter: TimeFilter = .oneDay
    @State private var isLoaded = false
    @State private var selectedStockDetail: StockDetail? = nil
    @State private var showFilterSheet = false
    @State private var showTimeSheet = false
    @State private var showAllStocks = false

    // MARK: - Filtered movers

    private var filteredMovers: [TopMover] {
        switch selectedMoverFilter {
        case .all:       return movers
        case .topGainers: return movers.filter { $0.changePercent > 0 }.sorted { $0.changePercent > $1.changePercent }
        case .topLosers:  return movers.filter { $0.changePercent < 0 }.sorted { $0.changePercent < $1.changePercent }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.top, Spacing.xl)
                        .padding(.bottom, Spacing.xl)

                    filterPills
                        .padding(.bottom, Spacing.xl)

                    moversList
                        .padding(.bottom, Spacing.sectionGap)

                    discoverButton
                        .padding(.bottom, Spacing.xl)

                    footerText
                        .padding(.bottom, Spacing.xxxl + Spacing.lg)
                }
                .padding(.horizontal, Spacing.pageMargin)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedStockDetail) { detail in
            StockDetailView(stock: detail)
        }
        .navigationDestination(isPresented: $showAllStocks) {
            AllStocksView()
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterPickerSheet(
                title: "Filter",
                options: MoverFilter.allCases.map { $0.rawValue },
                selected: selectedMoverFilter.rawValue
            ) { chosen in
                if let filter = MoverFilter(rawValue: chosen) {
                    selectedMoverFilter = filter
                }
            }
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTimeSheet) {
            FilterPickerSheet(
                title: "Time frame",
                options: TimeFilter.allCases.map { $0.rawValue },
                selected: selectedTimeFilter.rawValue
            ) { chosen in
                if let filter = TimeFilter(rawValue: chosen) {
                    selectedTimeFilter = filter
                }
            }
            .presentationDetents([.height(380)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.05)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Navigation Bar

private extension TopMoversAllView {

    var navBar: some View {
        HStack {
            Button {
                Haptics.light()
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()

            Text("Top movers")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer()

            // Invisible placeholder to balance the back button
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, Spacing.pageMargin - Spacing.sm)
        .frame(height: 52)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Header

private extension TopMoversAllView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Top movers")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Discover the best and worst performing Stocks. Past performance is not a reliable indicator of future performance")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 8)
    }
}

// MARK: - Filter Pills

private extension TopMoversAllView {

    var filterPills: some View {
        HStack(spacing: Spacing.sm) {
            filterPill(
                iconName: "line.3.horizontal.decrease",
                label: selectedMoverFilter.rawValue
            ) { showFilterSheet = true }

            filterPill(
                iconName: "calendar",
                label: selectedTimeFilter.rawValue
            ) { showTimeSheet = true }

            Spacer()
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 8)
    }

    func filterPill(iconName: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(FondyColors.labelPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm + Spacing.xxs)
            .background(
                FondyColors.fillTertiary,
                in: Capsule()
            )
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("\(label) filter")
    }
}

// MARK: - Movers List

private extension TopMoversAllView {

    var moversList: some View {
        let list = filteredMovers
        return VStack(spacing: 0) {
            ForEach(Array(list.enumerated()), id: \.element.id) { index, mover in
                TopMoverListRow(mover: mover, onTap: {
                    selectedStockDetail = StockDetail(
                        id: mover.id,
                        companyName: mover.companyName,
                        ticker: mover.ticker,
                        sector: mover.sector,
                        logoSystemName: mover.logoSystemName,
                        logoColor: mover.logoColor,
                        logoBackground: mover.logoBackground,
                        price: mover.price,
                        priceChange: mover.price * mover.changePercent / 100,
                        priceChangePercent: mover.changePercent,
                        currencySymbol: mover.currencySymbol,
                        marketStatus: "The market is currently closed\nIt will open again at Oct 30 at 9:30 PM",
                        chartPoints: StockDetail.apple.chartPoints,
                        marketCap: "N/A", peRatio: "N/A", eps: "N/A",
                        dividendYield: "N/A", beta: "N/A",
                        priceAlertValue: mover.price * 0.95,
                        analystCount: 0,
                        strongBuyPercent: 0, buyPercent: 0, holdPercent: 0,
                        aboutText: "No description available.",
                        financials: .apple
                    )
                })
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)

                if index < list.count - 1 {
                    Divider()
                        .padding(.leading, Spacing.iconDividerInset + Spacing.lg)
                }
            }
        }
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 12)
    }
}

// MARK: - Discover Button

private extension TopMoversAllView {

    var discoverButton: some View {
        Button {
            Haptics.light()
            showAllStocks = true
        } label: {
            Text("Discover all stocks")
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Discover all stocks")
        .opacity(isLoaded ? 1 : 0)
    }
}

// MARK: - Footer

private extension TopMoversAllView {

    var footerText: some View {
        VStack(spacing: Spacing.lg) {
            Text("Past performance is not a reliable indicator of future results.")
                .multilineTextAlignment(.center)

            Text("Services are provided by Fondy Securities, a Capital Markets Services License holder authorized by the Monetary Authority (License no. CMS101155).")
                .multilineTextAlignment(.center)

            HStack(spacing: 0) {
                Text("View ")
                Button("Terms of business") { Haptics.light() }
                    .foregroundStyle(.blue)
                Text(" and ")
                Button("Trading Disclosures") { Haptics.light() }
                    .foregroundStyle(.blue)
                Text(".")
            }
        }
        .font(.caption)
        .foregroundStyle(FondyColors.labelTertiary)
        .frame(maxWidth: .infinity)
        .opacity(isLoaded ? 1 : 0)
    }
}

// MARK: - Top Mover List Row

/// A full-width list row used in `TopMoversAllView`.
///
/// Logo circle | Company name (bold) / Ticker · Sector (secondary) || Price (bold) / ▼ % (pink/green)
struct TopMoverListRow: View {
    let mover: TopMover
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            HStack(spacing: Spacing.md) {
                logoView
                nameColumn
                Spacer(minLength: Spacing.sm)
                priceColumn
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mover.companyName), \(mover.ticker), \(mover.formattedPrice), \(mover.formattedChange)")
    }

    private var logoView: some View {
        Image(systemName: mover.logoSystemName)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(mover.logoColor)
            .frame(width: 44, height: 44)
            .background(mover.logoBackground, in: Circle())
            .accessibilityHidden(true)
    }

    private var nameColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(mover.companyName)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(mover.ticker) · \(mover.sector)")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineLimit(1)
        }
    }

    private var priceColumn: some View {
        VStack(alignment: .trailing, spacing: Spacing.xxs) {
            Text(mover.formattedPrice)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)

            Text(mover.formattedChange)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(mover.isPositive ? .blue : Color(red: 0.85, green: 0.1, blue: 0.35))
        }
    }
}

// MARK: - Preview

#Preview {
    TopMoversAllView(movers: StocksViewModel.mockTopMovers)
}

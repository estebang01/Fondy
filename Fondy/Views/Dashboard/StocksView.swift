//
//  StocksView.swift
//  Fondy
//
//  Stocks tab content view matching the Revolut-style stocks dashboard.
//  Sections: Orders → Watchlist → Today's Top movers.
//

import SwiftUI

/// The Stocks tab content showing orders, watchlist, and top movers.
///
/// Uses the same grey `systemGroupedBackground` with white rounded container
/// cards as the rest of the Home screen. Layout:
/// "Orders" section → "Watchlist" section → "Today's Top movers" section.
struct StocksView: View {
    @State private var viewModel = StocksViewModel.createMock()
    @State private var isLoaded = false
    @State private var showTopMoversAll = false
    @State private var showWatchlist = false
    @State private var showWatchlistIntro = false
    @State private var introGotItTapped = false
    @State private var selectedStockDetail: StockDetail? = nil
    @State private var showPaperPortfolio = false
    @State private var paperStore = PaperPortfolioStore()

    var actionItems: [HomeActionItem] = []
    var onRemoveActionItem: (UUID) -> Void = { _ in }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            investmentsCarouselSection
                .padding(.bottom, Spacing.sectionGap)

            paperPortfolioSummarySection
                .padding(.bottom, Spacing.sectionGap)

            actionsSection
                .padding(.bottom, actionItems.isEmpty ? 0 : Spacing.sectionGap)

            paperTradingSection
                .padding(.bottom, Spacing.sectionGap)

            ordersSection
                .padding(.bottom, Spacing.sectionGap)
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : 10)

            watchlistSection
                .padding(.bottom, Spacing.sectionGap)
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : 14)

            topMoversSection
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : 18)
        }
        .navigationDestination(isPresented: $showTopMoversAll) {
            TopMoversAllView(movers: viewModel.topMovers, onSelectMover: { mover in
                selectedStockDetail = moverToDetail(mover)
            })
        }
        .navigationDestination(isPresented: $showWatchlist) {
            WatchlistView(viewModel: viewModel)
        }
        .navigationDestination(item: $selectedStockDetail) { detail in
            StockDetailView(stock: detail)
        }
        .navigationDestination(isPresented: $showPaperPortfolio) {
            PaperPortfolioView()
        }
        .sheet(isPresented: $showWatchlistIntro, onDismiss: {
            if introGotItTapped {
                introGotItTapped = false
                showWatchlist = true
            }
        }) {
            WatchlistIntroSheet(didTapGotIt: $introGotItTapped)
        }
        .onChange(of: introGotItTapped) { _, gotIt in
            if gotIt {
                // Reset flag, dismiss intro, then navigate to Watchlist
                introGotItTapped = false
                showWatchlistIntro = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showWatchlist = true
                }
            }
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.05)) {
                isLoaded = true
            }
        }
    }

    // MARK: - Helpers

    private func watchlistToDetail(_ stock: WatchlistStock) -> StockDetail {
        StockDetail(
            id: stock.id,
            companyName: stock.name,
            ticker: stock.ticker,
            sector: "Stocks",
            logoSystemName: stock.logoSystemName,
            logoColor: stock.logoColor,
            logoBackground: Color(.systemGray5),
            price: stock.price,
            priceChange: stock.price * stock.changePercent / 100,
            priceChangePercent: stock.changePercent,
            currencySymbol: stock.currencySymbol,
            marketStatus: "The market is currently closed\nIt will open again at Oct 30 at 9:30 PM",
            chartPoints: StockDetail.apple.chartPoints,
            marketCap: "N/A", peRatio: "N/A", eps: "N/A",
            dividendYield: "N/A", beta: "N/A",
            priceAlertValue: stock.price * 0.95,
            analystCount: 0,
            strongBuyPercent: 0, buyPercent: 0, holdPercent: 0,
            aboutText: "No description available.",
            financials: .apple
        )
    }

    private func moverToDetail(_ mover: TopMover) -> StockDetail {
        StockDetail(
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
            marketCap: "N/A",
            peRatio: "N/A",
            eps: "N/A",
            dividendYield: "N/A",
            beta: "N/A",
            priceAlertValue: mover.price * 0.95,
            analystCount: 0,
            strongBuyPercent: 0,
            buyPercent: 0,
            holdPercent: 0,
            aboutText: "No description available.",
            financials: .apple
        )
    }
}

// MARK: - Investments Carousel Section

private extension StocksView {

    var investmentsCarouselSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Investments")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            // Negative horizontal inset so the carousel bleeds full-width
            // while its cards are still inset to the page margin internally.
            StockInvestmentCarousel()
                .padding(.horizontal, -Spacing.pageMargin)
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 8)
    }
}

// MARK: - Paper Portfolio Summary Section

private extension StocksView {

    var paperPortfolioSummarySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Paper portfolio")
            cardContainer {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(FondyColors.labelTertiary)
                        .frame(width: 44, height: 44)
                        .background(FondyColors.fillQuaternary, in: Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        if paperStore.positions.isEmpty {
                            Text("No positions yet")
                                .font(.body)
                                .foregroundStyle(FondyColors.labelSecondary)
                        } else {
                            Text("Total invested")
                                .font(.caption)
                                .foregroundStyle(FondyColors.labelTertiary)
                            Text(totalInvested, format: .currency(code: "USD"))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(FondyColors.labelPrimary)
                            tickersRow
                        }
                    }

                    Spacer()

                    Button {
                        Haptics.light()
                        showPaperPortfolio = true
                    } label: {
                        Text("Open")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.blue.opacity(0.1), in: Capsule())
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                    .accessibilityLabel("Open paper portfolio")
                }
                .padding(Spacing.lg)
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 12)
    }

    private var totalInvested: Double {
        paperStore.positions.reduce(0) { $0 + $1.totalCost }
    }

    private var tickersRow: some View {
        let uniqueTickers = Array(Set(paperStore.positions.map { $0.ticker }))
        let display = Array(uniqueTickers.prefix(3))
        return HStack(spacing: Spacing.xs) {
            ForEach(display, id: \.self) { t in
                Text(t)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(FondyColors.fillQuaternary, in: Capsule())
            }
        }
    }
}

// MARK: - Card Container

private extension StocksView {

    func cardContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
    }
}

// MARK: - Section Header with "See all"

private extension StocksView {

    func sectionHeader(title: String, showSeeAll: Bool = false, onSeeAll: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if showSeeAll, let onSeeAll {
                Button {
                    Haptics.light()
                    onSeeAll()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See all \(title)")
            }
        }
        .padding(.bottom, Spacing.md)
    }
}

// MARK: - Paper Trading Section

private extension StocksView {

    var paperTradingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Paper trading")
            cardContainer {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "pencil.and.list.clipboard")
                        .font(.system(size: 22))
                        .foregroundStyle(FondyColors.labelTertiary)
                        .frame(width: 44, height: 44)
                        .background(FondyColors.fillQuaternary, in: Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Practice portfolio")
                            .font(.body.weight(.medium))
                            .foregroundStyle(FondyColors.labelPrimary)
                        Text("Add positions to simulate trades — no broker required")
                            .font(.caption)
                            .foregroundStyle(FondyColors.labelSecondary)
                    }

                    Spacer()

                    Button {
                        Haptics.light()
                        showPaperPortfolio = true
                    } label: {
                        Text("Open")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.blue.opacity(0.1), in: Capsule())
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                    .accessibilityLabel("Open paper portfolio")
                }
                .padding(Spacing.lg)
            }
        }
    }
}

// MARK: - Orders Section

private extension StocksView {

    var ordersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Orders")

            if viewModel.orders.isEmpty {
                emptyCard(message: "No pending orders")
            } else {
                cardContainer {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.orders.enumerated()), id: \.element.id) { index, order in
                            StockOrderRow(order: order)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)

                            if index < viewModel.orders.count - 1 {
                                Divider()
                                    .padding(.leading, Spacing.iconDividerInset + Spacing.lg)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Watchlist Section

private extension StocksView {

    var watchlistSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Watchlist", showSeeAll: true, onSeeAll: {
                if viewModel.watchlist.isEmpty {
                    showWatchlistIntro = true
                } else {
                    showWatchlist = true
                }
            })

            if viewModel.watchlist.isEmpty {
                watchlistEmptyCard
            } else {
                VStack(spacing: Spacing.md) {
                    ForEach(Array(viewModel.watchlist.enumerated()), id: \.element.id) { index, stock in
                        SwipeToDeleteCard(onDelete: {
                            viewModel.removeFromWatchlist(id: stock.id)
                        }) {
                            WatchlistStockRow(stock: stock, onTap: {
                                selectedStockDetail = watchlistToDetail(stock)
                            })
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                        }
                    }
                }
            }
        }
    }

    var watchlistEmptyCard: some View {
        cardContainer {
            HStack(spacing: Spacing.md) {
                Image(systemName: "chart.bar.xaxis.ascending")
                    .font(.system(size: 28))
                    .foregroundStyle(FondyColors.labelTertiary)
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)

                Text("Keep track of stocks")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelSecondary)

                Spacer()

                Button {
                    Haptics.light()
                    showWatchlistIntro = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Add")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.blue.opacity(0.1), in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .accessibilityLabel("Add stocks to watchlist")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Top Movers Section

private extension StocksView {

    var topMoversSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Today's Top movers", showSeeAll: true, onSeeAll: {
                showTopMoversAll = true
            })

            cardContainer {
                TopMoversGrid(movers: viewModel.topMovers, onTap: { mover in
                    selectedStockDetail = moverToDetail(mover)
                })
                .padding(Spacing.lg)
            }
        }
    }
}

// MARK: - Empty State Card

private extension StocksView {

    func emptyCard(message: String) -> some View {
        cardContainer {
            HStack(spacing: Spacing.md) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .frame(width: 40, height: 40)
                    .background(FondyColors.fillQuaternary, in: Circle())
                    .accessibilityHidden(true)

                Text(message)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel(message)
    }
}

// MARK: - Actions Section

private extension StocksView {

    var actionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if !actionItems.isEmpty {
                Text("Pending")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .accessibilityAddTraits(.isHeader)

                ForEach(actionItems) { item in
                    SwipeToDeleteCard(onDelete: {
                        onRemoveActionItem(item.id)
                    }) {
                        ActionItemRow(
                            iconName: item.iconName,
                            iconColor: item.iconColor,
                            title: item.title,
                            subtitle: item.subtitle,
                            subtitleColor: item.subtitleColor,
                            trailingAmount: item.trailingAmount,
                            trailingStatus: item.trailingStatus,
                            trailingStatusColor: item.trailingStatusColor
                        )
                        .padding(Spacing.lg)
                    }
                }
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 16)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        StocksView()
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xxxl)
    }
    .background(Color(.systemGroupedBackground))
}


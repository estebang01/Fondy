//
//  AllStocksView.swift
//  Fondy
//
//  Full-screen "All stocks" list with search and advanced filter.
//  Navigated from the "Discover all stocks" button in TopMoversAllView.
//

import SwiftUI

struct AllStocksView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showAdvancedSearch = false
    @State private var isLoaded = false
    @State private var selectedStockDetail: StockDetail? = nil

    // Screener filter state
    @State private var selectedSectors: Set<StockSector> = []
    @State private var selectedMarketCaps: Set<MarketCapCategory> = []
    @State private var peRatioRange: ClosedRange<Double> = 0...100
    @State private var dividendYieldRange: ClosedRange<Double> = 0...10
    @State private var yearlyChangeRange: ClosedRange<Double> = -100...300

    private let allStocks = StocksViewModel.mockAllStocks

    // MARK: - Filtered Stocks

    private var filteredStocks: [AllStock] {
        var result = allStocks

        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.companyName.localizedCaseInsensitiveContains(searchText) ||
                $0.ticker.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sector filter
        if !selectedSectors.isEmpty {
            result = result.filter { selectedSectors.contains($0.sector) }
        }

        // Market cap filter
        if !selectedMarketCaps.isEmpty {
            result = result.filter { selectedMarketCaps.contains($0.marketCap) }
        }

        // P/E ratio filter (only apply if range was changed from default)
        if peRatioRange != 0...100 {
            result = result.filter { $0.peRatio >= peRatioRange.lowerBound && $0.peRatio <= peRatioRange.upperBound }
        }

        // Dividend yield filter
        if dividendYieldRange != 0...10 {
            result = result.filter { $0.dividendYield >= dividendYieldRange.lowerBound && $0.dividendYield <= dividendYieldRange.upperBound }
        }

        // Yearly change filter
        if yearlyChangeRange != -100...300 {
            result = result.filter { $0.yearlyChange >= yearlyChangeRange.lowerBound && $0.yearlyChange <= yearlyChangeRange.upperBound }
        }

        return result
    }

    private var hasActiveFilters: Bool {
        !selectedSectors.isEmpty ||
        !selectedMarketCaps.isEmpty ||
        peRatioRange != 0...100 ||
        dividendYieldRange != 0...10 ||
        yearlyChangeRange != -100...300
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text("All stocks")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                        .opacity(isLoaded ? 1 : 0)
                        .offset(y: isLoaded ? 0 : 8)

                    // Search bar
                    SearchBarField(text: $searchText, placeholder: "Search stocks")
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.bottom, Spacing.xl)
                        .opacity(isLoaded ? 1 : 0)
                        .offset(y: isLoaded ? 0 : 8)

                    // Stock list
                    stocksList
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.bottom, Spacing.xxxl)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedStockDetail) { detail in
            StockDetailView(stock: detail)
        }
        .sheet(isPresented: $showAdvancedSearch) {
            AdvancedSearchView(
                selectedSectors: $selectedSectors,
                selectedMarketCaps: $selectedMarketCaps,
                peRatioRange: $peRatioRange,
                dividendYieldRange: $dividendYieldRange,
                yearlyChangeRange: $yearlyChangeRange
            )
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.05)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Navigation Bar

private extension AllStocksView {

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
            .accessibilityLabel("Back")

            Spacer()

            Button {
                Haptics.light()
                showAdvancedSearch = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                        .contentShape(Rectangle())

                    if hasActiveFilters {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                            .offset(x: -8, y: 10)
                    }
                }
            }
            .accessibilityLabel("Filter stocks")
        }
        .padding(.horizontal, Spacing.pageMargin - Spacing.sm)
        .frame(height: 52)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Stocks List

private extension AllStocksView {

    var stocksList: some View {
        let stocks = filteredStocks
        return VStack(spacing: 0) {
            if stocks.isEmpty {
                emptyState
            } else {
                ForEach(Array(stocks.enumerated()), id: \.element.id) { index, stock in
                    AllStockRow(stock: stock) {
                        selectedStockDetail = StockDetail(
                            id: stock.id,
                            companyName: stock.companyName,
                            ticker: stock.ticker,
                            sector: stock.sectorDetail,
                            logoSystemName: stock.logoSystemName,
                            logoColor: stock.logoColor,
                            logoBackground: stock.logoBackground,
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
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)

                    if index < stocks.count - 1 {
                        Divider()
                            .padding(.leading, Spacing.iconDividerInset + Spacing.lg)
                    }
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

    var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(FondyColors.labelTertiary)
            Text("No stocks found")
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxxl + Spacing.xl)
    }
}

// MARK: - All Stock Row

struct AllStockRow: View {
    let stock: AllStock
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
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stock.companyName), \(stock.ticker), \(stock.formattedPrice), \(stock.formattedChange)")
    }

    private var logoView: some View {
        CompanyLogoView(
            domain: stock.domain,
            systemName: stock.logoSystemName,
            symbolColor: stock.logoColor,
            background: stock.logoBackground,
            size: Spacing.iconSize
        )
    }

    private var nameColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(stock.companyName)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(1)

            Text("\(stock.ticker) \u{00B7} \(stock.sectorDetail)")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineLimit(1)
        }
    }

    private var priceColumn: some View {
        VStack(alignment: .trailing, spacing: Spacing.xxs) {
            Text(stock.formattedPrice)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)

            Text(stock.formattedChange)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(stock.isPositive ? .blue : Color(red: 0.85, green: 0.1, blue: 0.35))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AllStocksView()
    }
}

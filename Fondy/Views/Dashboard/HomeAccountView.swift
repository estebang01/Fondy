//
//  HomeAccountView.swift
//  Fondy
//
//  Main Home screen matching the Revolut-style account dashboard.
//  Grey grouped background with white rounded container cards.
//

import SwiftUI

/// The primary Home Account dashboard screen.
///
/// Uses a grey `systemGroupedBackground` with white rounded container cards
/// grouping related content. Layout: Top bar → Search → Segment tabs →
/// Tab-driven content (Accounts / Cards / Stocks).
struct HomeAccountView: View {
    @State private var isSearchPresented = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @FocusState private var searchFocused: Bool
    
    @Bindable var viewModel: HomeAccountViewModel

    @State private var isLoaded = false

    @State private var aiQuery: String = ""
    @State private var isAnalysisPresented: Bool = false
    @State private var isAIBarExpanded: Bool = false
    @State private var isAISending: Bool = false
    
    @Namespace private var glassNS
    
    // Scroll tracking state
    @State private var scrollOffset: CGFloat = 0
    @State private var showNavigationTitle: Bool = false
    
    // Watchlist-specific state
    @State private var stocksViewModel = StocksViewModel.createMock()
    @State private var selectedStockDetail: StockDetail? = nil
    @State private var priceAlertDetail: StockDetail? = nil
    @State private var showAddStocks = false
    @State private var showWatchlist = false
    
    // Navigation state
    @State private var showSettings = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation title bar
                    if showNavigationTitle && !isSearchPresented {
                        navigationTitleBar
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // Geometry reader to track scroll position
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: geometry.frame(in: .named("scroll")).minY
                                        )
                                }
                                .frame(height: 0)
                                
                                topBar
                                    .padding(.bottom, Spacing.md)
                                    .opacity(showNavigationTitle ? 0 : 1)
                                    .offset(y: showNavigationTitle ? -20 : 0)
                                    .animation(.easeInOut(duration: 0.25), value: showNavigationTitle)
                                
                                if isSearchPresented {
                                    searchContent
                                        .transition(.opacity)
                                } else {
                                    tabContent
                                        .transition(.opacity)
                                }
                            }
                            .padding(.horizontal, Spacing.pageMargin)
                            .padding(.top, Spacing.sm)
                            .padding(.bottom, Spacing.xxxl + Spacing.lg)
                            .animation(.springGentle, value: isSearchPresented)
                        }
                        .coordinateSpace(name: "scroll")
                        .scrollIndicators(.hidden)
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            // Show title when scrolled down (negative values mean scrolling down)
                            let shouldShow = value < -80
                            
                            if shouldShow != showNavigationTitle {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showNavigationTitle = shouldShow
                                }
                            }
                        }

                        GlassEffectContainer(spacing: 20) {
                            Group {
                        if isAIBarExpanded {
                            AIQueryBar(
                                text: $aiQuery,
                                isLoading: $isAISending,
                                onAnalyze: {
                                    let trimmed = aiQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { Haptics.selection(); return }
                                    Haptics.medium()
                                    isAISending = true
                                    Task {
                                        try? await Task.sleep(for: .milliseconds(600))
                                        isAnalysisPresented = true
                                        isAISending = false
                                    }
                                },
                                autoFocus: true,
                                onClose: {
                                    withAnimation(.springGentle) {
                                        isAIBarExpanded = false
                                    }
                                }
                            )
                            .padding(.horizontal, Spacing.pageMargin)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.9, anchor: .trailing)),
                                removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.9, anchor: .trailing))
                            ))
                            .glassEffectID("aiBubble", in: glassNS)
                            .accessibilityAddTraits(.isSearchField)
                        } else {
                            Button {
                                Haptics.light()
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.75, blendDuration: 0)) { 
                                    isAIBarExpanded = true 
                                }
                            } label: {
                                LiquidOrb()
                                    .frame(width: 56, height: 56)
                                    .glassEffect(.regular.interactive(), in: .circle)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Ask AI Assistant")
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.7).combined(with: .opacity),
                                removal: .scale(scale: 0.7).combined(with: .opacity)
                            ))
                            .glassEffectID("aiBubble", in: glassNS)
                        }
                    }
                }
                .padding(.bottom, Spacing.xxxl)
                .padding(.trailing, Spacing.pageMargin)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : 12)
                    }
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                guard !isSearchPresented else { return }
                Haptics.medium()
                try? await Task.sleep(for: .seconds(1))
                Haptics.success()
            }
            .onAppear {
                withAnimation(.springGentle) {
                    isLoaded = true
                }
            }
            .sheet(isPresented: $isAnalysisPresented) {
                AIAnalysisSheet(question: aiQuery, isPresented: $isAnalysisPresented)
                    .presentationDetents([.medium, .large])
                    .presentationBackground(.ultraThinMaterial)
            }
            .sheet(isPresented: $showAddStocks) {
                AddStocksSheet(viewModel: stocksViewModel)
            }
            .navigationDestination(item: $selectedStockDetail) { detail in
                StockDetailView(stock: detail)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(item: $priceAlertDetail) { detail in
                PriceAlertView(stock: detail)
            }
            .navigationDestination(isPresented: $showWatchlist) {
                WatchlistView(viewModel: stocksViewModel)
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsRootView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    Haptics.light()
                                    showSettings = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.secondary)
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .accessibilityLabel("Close settings")
                            }
                        }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
// MARK: - Tab Content Switch

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .stocks:
            StocksView(
                actionItems: viewModel.actionItems,
                onRemoveActionItem: { viewModel.removeActionItem(id: $0) }
            ) {
                watchlistSection
            }
            .transition(.opacity)
        case .accounts, .cards:
            StocksView(
                actionItems: viewModel.actionItems,
                onRemoveActionItem: { viewModel.removeActionItem(id: $0) }
            ) {
                EmptyView()
            }
        }
    }
}

// MARK: - Reusable Card Container

private extension HomeAccountView {

    /// A white rounded rectangle container for grouping content.
    func cardContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }
}

// MARK: - Navigation Title Bar

private extension HomeAccountView {
    
    var navigationTitleBar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Home")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                
                Spacer()
                
                // Settings button in the title bar
                Button {
                    Haptics.light()
                    showSettings = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            Divider()
        }
        .background(
            .ultraThinMaterial,
            in: Rectangle()
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Top Bar

private extension HomeAccountView {

    var topBar: some View {
        HStack(spacing: Spacing.md) {
            // Leading: back arrow (search only)
            if isSearchPresented {
                backButton
                    .transition(.scale.combined(with: .opacity))
            }

            // Search bar — tap-to-activate when idle, live input when searching
            if isSearchPresented {
                activeSearchBar
                    .transition(.opacity)
            } else {
                SearchBarField(placeholder: "Search") {
                    Haptics.light()
                    withAnimation(.springGentle) {
                        isSearchPresented = true
                    }
                }
                .transition(.opacity)
            }

            // Trailing: hidden when searching, settings menu when idle
            if !isSearchPresented {
                settingsButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 6)
    }

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                isSearchPresented = false
                searchText = ""
                isSearchFocused = false
                searchFocused = false
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }

    var activeSearchBar: some View {
        HStack(spacing: Spacing.sm) {
            // Search field with glass effect
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                TextField("Search", text: $searchText)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityLabel("Search stocks")

                if !searchText.isEmpty {
                    Button {
                        Haptics.light()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal: .scale(scale: 0.5).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.clear)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
            
            // Glass cancel button with X icon that appears when focused
            if searchFocused || !searchText.isEmpty {
                Button {
                    Haptics.light()
                    withAnimation(.springGentle) {
                        isSearchPresented = false
                        searchText = ""
                        searchFocused = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityLabel("Cancel search")
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .move(edge: .trailing)).combined(with: .opacity),
                    removal: .scale(scale: 0.5).combined(with: .move(edge: .trailing)).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: searchFocused)
        .animation(.easeInOut(duration: 0.25), value: searchText.isEmpty)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                searchFocused = true
            }
        }
    }

    var settingsButton: some View {
        Button {
            Haptics.light()
            showSettings = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel("Settings")
    }

    func topBarIcon(
        _ name: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Content

private extension HomeAccountView {

    /// Inline search results — rendered in the same scroll view as the rest of the dashboard.
    var searchContent: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionGap) {
            if searchText.isEmpty {
                recentSearchesSection
                quickLinksSection
            } else {
                searchResultsSection
            }
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: Recent Searches

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                ForEach(["AAPL", "EUR/USD", "Tesla", "Bitcoin"], id: \.self) { term in
                    Button {
                        Haptics.light()
                        searchText = term
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "clock")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(FondyColors.labelTertiary)
                                .frame(width: 28)

                            Text(term)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.left")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FondyColors.labelTertiary)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if term != "Bitcoin" {
                        Divider()
                            .padding(.leading, 28 + Spacing.md + Spacing.lg)
                    }
                }
            }
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        }
    }

    // MARK: Quick Links

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Browse")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            let links: [(icon: String, color: Color, label: String)] = [
                ("chart.bar.fill", .blue, "Stocks"),
                ("dollarsign.arrow.circlepath", .green, "Crypto"),
                ("globe", .orange, "Forex"),
                ("sparkles", .purple, "Top movers"),
            ]

            VStack(spacing: 0) {
                ForEach(links, id: \.label) { link in
                    Button {
                        Haptics.light()
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: link.icon)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(link.color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                            Text(link.label)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(FondyColors.labelTertiary)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if link.label != "Top movers" {
                        Divider()
                            .padding(.leading, 32 + Spacing.md + Spacing.lg)
                    }
                }
            }
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        }
    }

    // MARK: Search Results

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Results")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                ForEach(["AAPL · Apple Inc.", "AMZN · Amazon.com", "MSFT · Microsoft"].filter {
                    $0.localizedCaseInsensitiveContains(searchText)
                }, id: \.self) { result in
                    Button {
                        Haptics.light()
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(FondyColors.labelSecondary)
                                .frame(width: 28)

                            Text(result)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)

                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if result != "MSFT · Microsoft" {
                        Divider()
                            .padding(.leading, 28 + Spacing.md + Spacing.lg)
                    }
                }

                if ["AAPL · Apple Inc.", "AMZN · Amazon.com", "MSFT · Microsoft"].filter({
                    $0.localizedCaseInsensitiveContains(searchText)
                }).isEmpty {
                    Text("No results for \(searchText)")
                        .font(.body)
                        .foregroundStyle(FondyColors.labelSecondary)
                        .padding(Spacing.lg)
                }
            }
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        }
    }
}



// MARK: - Segment Tabs

private extension HomeAccountView {
    
    var segmentTabs: some View {
        FlatTabBar(selected: $viewModel.selectedTab)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 8)
    }
}

// MARK: - Watchlist Section

private extension HomeAccountView {

    var watchlistSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Watchlist", showSeeAll: !stocksViewModel.watchlist.isEmpty, onSeeAll: {
                Haptics.light()
                showWatchlist = true
            })

            if stocksViewModel.watchlist.isEmpty {
                watchlistEmptyCard
            } else {
                stocksCard
            }
        }
    }

    var stocksCard: some View {
        VStack(spacing: 0) {
            // Add stocks row (always shown at top)
            addStocksRow
            
            // Divider after Add stocks
            if !stocksViewModel.watchlist.isEmpty {
                Divider()
                    .padding(.leading, Spacing.lg)
            }
            
            // Show max 3 watchlist rows in the same card
            ForEach(Array(stocksViewModel.watchlist.prefix(3).enumerated()), id: \.element.id) { index, stock in
                StockRowWrapper(
                    stock: stock,
                    detail: watchlistToDetail(stock),
                    viewModel: stocksViewModel,
                    priceAlertDetail: $priceAlertDetail
                )
                
                // Divider between rows (except last shown)
                if index < min(2, stocksViewModel.watchlist.count - 1) {
                    Divider()
                        .padding(.leading, Spacing.lg)
                }
            }
        }
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    var addStocksRow: some View {
        Button {
            Haptics.light()
            showAddStocks = true
        } label: {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .accessibilityHidden(true)

                Text("Add stocks")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.blue)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add stocks to watchlist")
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
                    showAddStocks = true
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

    func sectionHeader(title: String, showSeeAll: Bool = false, onSeeAll: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if showSeeAll, let onSeeAll {
                Button {
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

    func watchlistToDetail(_ stock: WatchlistStock) -> StockDetail {
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
}

// MARK: - Stock Row Wrapper

/// Wrapper view that handles the interactive row behavior with navigation and context menu
private struct StockRowWrapper: View {
    let stock: WatchlistStock
    let detail: StockDetail
    let viewModel: StocksViewModel
    @Binding var priceAlertDetail: StockDetail?
    
    var body: some View {
        Button {
            Haptics.light()
        } label: {
            NavigationLink(value: detail) {
                HStack(spacing: Spacing.md) {
                    // Logo
                    CompanyLogoView(
                        domain: stock.domain,
                        systemName: stock.logoSystemName,
                        symbolColor: stock.logoColor,
                        background: Color(.systemGray5),
                        size: Spacing.iconSize
                    )
                    
                    // Name and ticker
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(stock.name)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(FondyColors.labelPrimary)
                            .lineLimit(1)
                        
                        Text(stock.ticker)
                            .font(.subheadline)
                            .foregroundStyle(FondyColors.labelSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer(minLength: Spacing.sm)
                    
                    // Price and change
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        Text(stock.formattedPrice)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(FondyColors.labelPrimary)
                        
                        Text(stock.formattedChange)
                            .font(.subheadline)
                            .foregroundStyle(stock.isPositive ? FondyColors.positive : FondyColors.negative)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .buttonStyle(.plain)
        .contextMenu {
            NavigationLink(value: detail) {
                Label("View Details", systemImage: "info.circle")
            }
            
            Button {
                Haptics.light()
                priceAlertDetail = detail
            } label: {
                Label("Set Price Alert", systemImage: "bell")
            }
            
            Divider()
            
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.removeFromWatchlist(id: stock.id)
                }
            } label: {
                Label("Remove from Watchlist", systemImage: "trash")
            }
        } preview: {
            StockRowPreview(stock: stock, detail: detail)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.removeFromWatchlist(id: stock.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                Haptics.light()
                priceAlertDetail = detail
            } label: {
                Label("Remind", systemImage: "bell")
            }
            .tint(Color.blue)
        }
    }
}

/// Preview view shown when long-pressing a stock row
private struct StockRowPreview: View {
    let stock: WatchlistStock
    let detail: StockDetail
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Header with logo and name
            HStack(spacing: Spacing.md) {
                CompanyLogoView(
                    domain: stock.domain,
                    systemName: stock.logoSystemName,
                    symbolColor: stock.logoColor,
                    background: Color(.systemGray5),
                    size: 56
                )
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(stock.name)
                        .font(.title2.bold())
                        .foregroundStyle(FondyColors.labelPrimary)
                    
                    Text(stock.ticker)
                        .font(.body)
                        .foregroundStyle(FondyColors.labelSecondary)
                }
                
                Spacer()
            }
            
            // Price information
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(stock.formattedPrice)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(FondyColors.labelPrimary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(stock.formattedChange)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(stock.isPositive ? FondyColors.positive : FondyColors.negative)
                    }
                }
            }
            
            Divider()
            
            // Quick stats
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sector")
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                    Text(detail.sector)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Market Status")
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                    Text("Closed")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                }
            }
        }
        .padding(Spacing.xl)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(FondyColors.background)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
    }
}

// MARK: - Liquid Orb View

private struct LiquidOrb: View {
    @State private var breathe = false
    @State private var rotateGradient = false
    
    // Gradient colors for subtle, sophisticated glow
    private let gradientColors: [Color] = [
        Color.blue.opacity(0.6),
        Color.purple.opacity(0.5),
        Color.pink.opacity(0.4),
        Color.orange.opacity(0.5),
        Color.blue.opacity(0.6)
    ]

    var body: some View {
        ZStack {
            // Subtle animated gradient background
            Circle()
                .fill(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    )
                )
                .blur(radius: 12)
                .opacity(0.25)
                .rotationEffect(.degrees(rotateGradient ? 360 : 0))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotateGradient)
            
            // Glass material circle
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                .shadow(color: Color.blue.opacity(0.15), radius: 16, x: 0, y: 6)

            // Sparkles icon with gradient
            Image(systemName: "sparkles")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.purple,
                            Color.pink
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(breathe ? 1.08 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: breathe
                )
                // Subtle glow on the icon
                .shadow(color: Color.blue.opacity(0.4), radius: 4, x: 0, y: 0)
        }
        .onAppear { 
            breathe = true
            rotateGradient = true
        }
    }
}

// MARK: - Scroll Offset Preference Key

/// Preference key to track scroll offset for navigation title animation
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    HomeAccountView(viewModel: HomeAccountViewModel.createMock())
}

#Preview("With Transactions") {
    let vm = HomeAccountViewModel.createMock()
    let _ = vm.transactions = PortfolioService.mockTransactions
    HomeAccountView(viewModel: vm)
}



//
//  WatchlistView.swift
//  Fondy
//
//  Full-screen "Stocks watchlist" view pushed from the Watchlist "See all" button.
//  Shows the user's watchlist with sort pill, Add stocks row, and legal footer.
//

import SwiftUI

/// Full-screen stocks watchlist view.
///
/// Layout: custom nav bar (← back, + New) → large title → sort pill
/// → white card (Add stocks row + watchlist rows) → legal footer.
struct WatchlistView: View {
    @Bindable var viewModel: StocksViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showAddStocks = false
    @State private var isLoaded = false
    @State private var showTerms = false
    @State private var showDisclosures = false
    @State private var showAddedToast = false
    @State private var watchlistCountSnapshot = 0
    /// Stock whose price-alert sheet was triggered via swipe Remind action.
    @State private var priceAlertDetail: StockDetail? = nil
    @State private var showSortOptions = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerTitle
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.xs)

                    sortPill
                        .padding(.bottom, Spacing.lg)
                    stocksCard

                    footerText
                        .padding(.top, Spacing.xl)
                        .padding(.bottom, Spacing.xxxl)
                }
                .padding(.horizontal, Spacing.pageMargin)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Haptics.light()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : -6)
            }
            ToolbarItem(placement: .principal) {
                Text("Stocks watchlist")
                    .font(.headline)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : -6)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Haptics.light()
                    showAddStocks = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .symbolEffect(.bounce, value: isLoaded)
                    }
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .accessibilityLabel("New watchlist")
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : -6)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showAddedToast {
                addedToastBanner
                    .padding(.bottom, Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showAddedToast)
        .sheet(isPresented: $showAddStocks) {
            AddStocksSheet(viewModel: viewModel)
        }
        .onChange(of: showAddStocks) { _, isShowing in
            if isShowing {
                watchlistCountSnapshot = viewModel.watchlist.count
            } else if viewModel.watchlist.count > watchlistCountSnapshot {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showAddedToast = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(7))
                    await MainActor.run {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showAddedToast = false
                        }
                    }
                }
            }
        }
        .navigationDestination(for: StockDetail.self) { detail in
            StockDetailView(stock: detail)
                .navigationBarBackButtonHidden(true)
        }
        
        .navigationDestination(item: $priceAlertDetail) { detail in
            PriceAlertView(stock: detail)
        }
        .navigationDestination(isPresented: $showTerms) {
            TermsConditionsView()
        }
        .navigationDestination(isPresented: $showDisclosures) {
            TermsConditionsView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Helpers

private extension WatchlistView {

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

// MARK: - Header

private extension WatchlistView {

    var headerTitle: some View {
        Text("Stock Watchlist")
            .font(.largeTitle.bold())
            .foregroundStyle(FondyColors.labelPrimary)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 6)
    }

    var sortPill: some View {
        Menu {
            Button {
                // TODO: Implement last added sorting
                Haptics.light()
            } label: {
                Label("Last added", systemImage: "clock")
            }
            
            Button {
                // TODO: Implement alphabetical sorting
                Haptics.light()
            } label: {
                Label("Alphabetical", systemImage: "textformat")
            }
            
            Button {
                // TODO: Implement price sorting
                Haptics.light()
            } label: {
                Label("Price", systemImage: "dollarsign")
            }
            
            Button {
                // TODO: Implement change percentage sorting
                Haptics.light()
            } label: {
                Label("% Change", systemImage: "percent")
            }
        } label: {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12, weight: .medium))
                Text("Last added")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(FondyColors.labelPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .liquidGlass(cornerRadius: 50)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Sort watchlist")
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 6)
    }
}

// MARK: - Stocks Card

private extension WatchlistView {

    var stocksCard: some View {
        VStack(spacing: 0) {
            // Add stocks row (always shown at top)
            addStocksRow
            
            // Divider after Add stocks
            if !viewModel.watchlist.isEmpty {
                Divider()
                    .padding(.leading, Spacing.lg)
            }
            
            // All watchlist rows in the same card
            ForEach(Array(viewModel.watchlist.enumerated()), id: \.element.id) { index, stock in
                StockRowWrapper(
                    stock: stock,
                    detail: watchlistToDetail(stock),
                    viewModel: viewModel,
                    priceAlertDetail: $priceAlertDetail
                )
                
                // Divider between rows (except last)
                if index < viewModel.watchlist.count - 1 {
                    Divider()
                        .padding(.leading, Spacing.lg)
                }
            }
        }
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 10)
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

// MARK: - Footer

private extension WatchlistView {

    var footerText: some View {
        VStack(spacing: Spacing.md) {
            Text("Past performance is not a reliable indicator of future results.")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)

            Text("Services are provided by Fondy Securities, a Capital Markets Services License holder authorized by the Monetary Authority of Singapore (License no. CMS101155).")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Text("View")
                    .font(.footnote)
                    .foregroundStyle(FondyColors.labelTertiary)
                Button("Terms of business") {
                    Haptics.light()
                    showTerms = true
                }
                .font(.footnote)
                .foregroundStyle(.blue)
                .buttonStyle(.plain)
                Text("and")
                    .font(.footnote)
                    .foregroundStyle(FondyColors.labelTertiary)
                Button("Trading Disclosures") {
                    Haptics.light()
                    showDisclosures = true
                }
                .font(.footnote)
                .foregroundStyle(.blue)
                .buttonStyle(.plain)
                Text(".")
                    .font(.footnote)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .opacity(isLoaded ? 1 : 0)
    }
}

// MARK: - Toast Banner

private extension WatchlistView {

    var addedToastBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(FondyColors.labelPrimary)

            Text("Added to Watchlist")
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.md)
        .background(FondyColors.background, in: Capsule())
        .shadow(color: .black.opacity(0.10), radius: 16, y: 4)
        .accessibilityLabel("Added to Watchlist")
    }
}

// MARK: - Styles

private struct BlueCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.95), Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .overlay(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.6)
            )
            .shadow(
                color: Color.blue.opacity(configuration.isPressed ? 0.15 : 0.30),
                radius: configuration.isPressed ? 6 : 12,
                y: configuration.isPressed ? 3 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WatchlistView(viewModel: StocksViewModel.createMock())
    }
}


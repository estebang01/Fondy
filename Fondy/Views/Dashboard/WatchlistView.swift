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
    @State private var selectedStockDetail: StockDetail? = nil
    @State private var showTerms = false
    @State private var showDisclosures = false
    @State private var showAddedToast = false
    @State private var watchlistCountSnapshot = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.md)

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
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            if showAddedToast {
                addedToastBanner
                    .padding(.bottom, Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.springGentle, value: showAddedToast)
        .sheet(isPresented: $showAddStocks) {
            AddStocksSheet(viewModel: viewModel)
        }
        .onChange(of: showAddStocks) { _, isShowing in
            if isShowing {
                watchlistCountSnapshot = viewModel.watchlist.count
            } else if viewModel.watchlist.count > watchlistCountSnapshot {
                withAnimation(.springGentle) {
                    showAddedToast = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(7))
                    await MainActor.run {
                        withAnimation(.springGentle) {
                            showAddedToast = false
                        }
                    }
                }
            }
        }
        .navigationDestination(item: $selectedStockDetail) { detail in
            StockDetailView(stock: detail)
        }
        .navigationDestination(isPresented: $showTerms) {
            TermsConditionsView()
        }
        .navigationDestination(isPresented: $showDisclosures) {
            TermsConditionsView()
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.05)) {
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

// MARK: - Nav Bar

private extension WatchlistView {

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
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()

            Button {
                Haptics.light()
                showAddStocks = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("New")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .liquidGlass(tint: .blue, cornerRadius: 50)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .accessibilityLabel("New watchlist")
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Header

private extension WatchlistView {

    var headerSection: some View {
        Text("Stocks watchlist")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(FondyColors.labelPrimary)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 8)
    }

    var sortPill: some View {
        Button {
            Haptics.light()
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
        .accessibilityLabel("Sort by last added")
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 6)
    }
}

// MARK: - Stocks Card

private extension WatchlistView {

    var stocksCard: some View {
        VStack(spacing: Spacing.md) {
            // Add stocks row (always shown) — keep as its own card
            addStocksRow
                .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))

            // Watchlist rows (each as its own card)
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
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Add stocks to watchlist")
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

// MARK: - Preview

#Preview {
    WatchlistView(viewModel: StocksViewModel.createMock())
}

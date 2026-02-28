//
//  StockDetailView.swift
//  Fondy
//
//  Full-screen stock detail view matching the Revolut-style stock page.
//  Sections: header → price chart → stats → price alert → analyst ratings
//            → about → help → legal footer.
//  Sticky Buy/Sell bar pinned at the bottom.
//

import SwiftUI

// MARK: - Stock Detail Tab

enum StockDetailTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case financials = "Statistics"
    case news = "Portfolio"
    var id: String { rawValue }
}

// MARK: - Main View

struct StockDetailView: View {
    let stock: StockDetail
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: StockDetailTab = .overview
    @State private var selectedPeriod: ChartPeriod = .sixMonths
    @State var isAboutExpanded = false
    @State private var isLoaded = false
    @State var showPriceAlert = false
    @State private var showBuySheet = false
    @State private var showSellSheet = false
    @State var showHelp = false
    @State var showTerms = false
    @State var showDisclosures = false
    @Namespace private var periodSelectionNS
    @State var showPDF = false
    @State private var isReturnsExpanded = false
    @State var pdfURL: URL?

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header: title + buy/sell (top of scroll)
                        headerSection
                            .padding(.horizontal, Spacing.pageMargin)
                            .padding(.top, Spacing.sm)
                            .padding(.bottom, Spacing.sm)
                        tabBar                    .padding(.top, Spacing.sm)
                            .padding(.bottom, Spacing.xl)


                        // Chart card — only shown on Overview tab
                        if selectedTab == .overview {
                            chartCard
                                .padding(.horizontal, Spacing.pageMargin)
                                .padding(.bottom, Spacing.sectionGap)
                        }

                        // Tab content
                        tabContent
                            .padding(.bottom, Spacing.xxxl + 80) // room for sticky bar
                    }
                }
                .scrollIndicators(.hidden)
            }
            .background(Color(.systemGroupedBackground))

            
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showPriceAlert) {
            PriceAlertView(stock: stock)
        }
        .navigationDestination(isPresented: $showHelp) {
            HelpCenterView()
        }
        .navigationDestination(isPresented: $showTerms) {
            TermsConditionsView()
        }
        .navigationDestination(isPresented: $showDisclosures) {
            TermsConditionsView()
        }
        .fullScreenCover(isPresented: $showBuySheet) {
            TradeOrderSheet(stock: stock, orderType: .buy)
        }
        .fullScreenCover(isPresented: $showSellSheet) {
            TradeOrderSheet(stock: stock, orderType: .sell)
        }
        .sheet(isPresented: $showPDF) {
            if let url = pdfURL {
                PDFKitView(url: url)
                    .ignoresSafeArea()
            } else {
                Text("Document could not be loaded.")
                    .padding()
            }
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.05)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Nav Bar

private extension StockDetailView {

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

            Text(stock.companyName)
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer()

            HStack(spacing: Spacing.sm) {
                Button {
                    Haptics.light()
                    showPriceAlert = true
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Price alerts")

                Button {
                    Haptics.light()
                } label: {
                    Image(systemName: "star")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add to watchlist")
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.sm)
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : -6)
    }
}

// MARK: - Header Section

private extension StockDetailView {

    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(stock.companyName)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                HStack(spacing: 4) {
                    Text(stock.ticker)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FondyColors.labelSecondary)
                    Text("·")
                        .foregroundStyle(FondyColors.labelTertiary)
                    Text(stock.sector)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }

                Text("Collective Investment Fund")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .padding(.top, Spacing.xxs)

                // Buy / Sell buttons
                HStack(spacing: Spacing.md) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Buy")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm + 2)
                        .liquidGlass(tint: .blue, cornerRadius: 50, disabled: true)
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                    .disabled(true)
                    .accessibilityLabel("Buy \(stock.ticker)")
                    .accessibilityHint("Disabled for now")

                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Sell")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundStyle(FondyColors.labelTertiary.opacity(0.6))
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm + 2)
                        .liquidGlass(cornerRadius: 50, disabled: true)
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                    .disabled(true)
                    .accessibilityLabel("Sell \(stock.ticker)")
                    .accessibilityHint("Disabled for now")
                }
                .padding(.top, Spacing.sm)
            }

            Spacer()

            // Logo
            CompanyLogoView(
                domain: stock.domain,
                systemName: stock.logoSystemName,
                symbolColor: stock.logoColor,
                background: stock.logoBackground,
                size: 64
            )
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 8)
    }
}

// MARK: - Horizontal Tab Bar

private extension StockDetailView {

    var tabBar: some View {
        FlatTabBar(selected: $selectedTab)
            .padding(.horizontal, Spacing.pageMargin)
            .opacity(isLoaded ? 1 : 0)
    }
}

// MARK: - Chart Card

private extension StockDetailView {

    var chartCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Price header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(stock.formattedPrice)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(FondyColors.labelPrimary)

                    HStack(spacing: 6) {
                        Text(stock.formattedChange)
                            .font(.subheadline)
                            .foregroundStyle(FondyColors.labelSecondary)

                        Image(systemName: stock.isPositive ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(stock.isPositive ? FondyColors.positive : Color(red: 0.85, green: 0.1, blue: 0.35))

                        Text(stock.formattedChangePercent)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(stock.isPositive ? FondyColors.positive : Color(red: 0.85, green: 0.1, blue: 0.35))
                    }
                }

                Spacer()

                // Tuning icon button
                Button {
                    Haptics.light()
                } label: {
                    Image(systemName: "slider.vertical.3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.12), in: Circle())
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .accessibilityLabel("Chart settings")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)

            // Market status
            HStack(spacing: Spacing.xs) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundStyle(FondyColors.labelTertiary)
                    .accessibilityHidden(true)
                Text("01/01/2026")
                    .font(.caption2)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)

            // Chart — interactive NAV tooltip enabled when chartData is present
            StockLineChart(
                points: stock.chartPoints,
                isPositive: stock.isPositive,
                minPrice: stock.chartPoints.min() ?? 0,
                maxPrice: stock.chartPoints.max() ?? 0,
                chartData: stock.chartData,
                currencySymbol: stock.currencySymbol,
                periodStartValue: stock.chartData.first?.value ?? stock.chartPoints.first
            )
            .frame(height: 200)
            .padding(.top, Spacing.lg)

            // Period selector
            periodSelector
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 10)
    }

    var periodSelector: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(ChartPeriod.allCases, id: \.self) { period in
                let isSelected = selectedPeriod == period
                Button {
                    Haptics.selection()
                    withAnimation(.springInteractive) {
                        selectedPeriod = period
                    }
                } label: {
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: Spacing.md, style: .continuous)
                                .fill(FondyColors.fillTertiary)
                                .matchedGeometryEffect(id: "period_selection", in: periodSelectionNS)
                        }
                        Text(period.rawValue)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? FondyColors.labelPrimary : FondyColors.labelTertiary)
                            .padding(.vertical, Spacing.sm)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("\(period.rawValue) period")
                .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
            }
        }
    }
}

// MARK: - Tab Content Router

extension StockDetailView {

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .overview:
            overviewContent
        case .financials:
            StockFinancialsView(financials: stock.financials)
        case .news:
            newsContent
        }
    }

    @ViewBuilder
    var newsContent: some View {
        if let analysis = stock.fundAnalysis {
            FundAnalysisView(analysis: analysis)
        } else {
            emptyTabCard(icon: "newspaper", message: "No hay análisis disponible")
        }
    }

    func emptyTabCard(icon: String, message: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(FondyColors.labelTertiary)
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)
            Text(message)
                .font(.body)
                .foregroundStyle(FondyColors.labelTertiary)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .padding(.horizontal, Spacing.pageMargin)
    }
}


// MARK: - Preview

#Preview {
    StockDetailView(stock: .apple)
}



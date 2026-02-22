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
import PDFKit

// MARK: - Stock Detail Tab

enum StockDetailTab: String, CaseIterable, Identifiable {
    case overview = "Resumen"
    case financials = "Estadísticas"
    case news = "Portafolio"
    var id: String { rawValue }
}

// MARK: - Main View

struct StockDetailView: View {
    let stock: StockDetail
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: StockDetailTab = .overview
    @State private var selectedPeriod: ChartPeriod = .sixMonths
    @State private var isAboutExpanded = false
    @State private var isLoaded = false
    @State private var showPriceAlert = false
    @State private var showBuySheet = false
    @State private var showSellSheet = false
    @State private var showHelp = false
    @State private var showTerms = false
    @State private var showDisclosures = false
    @Namespace private var periodSelectionNS
    @State private var showPDF = false
    @State private var isReturnsExpanded = false
    @State private var pdfURL: URL?

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
                Text("No se pudo cargar el documento.")
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

                Text("Fondo de Inversión Colectiva")
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
                        .background(Color.blue.opacity(0.4), in: Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
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
                        .background(FondyColors.fillTertiary.opacity(0.6), in: Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(true)
                    .accessibilityLabel("Sell \(stock.ticker)")
                    .accessibilityHint("Disabled for now")
                }
                .padding(.top, Spacing.sm)
            }

            Spacer()

            // Logo
            Image(systemName: stock.logoSystemName)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(stock.logoColor)
                .frame(width: 64, height: 64)
                .background(stock.logoBackground, in: Circle())
                .accessibilityHidden(true)
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
                .buttonStyle(ScaleButtonStyle())
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

private extension StockDetailView {

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

    var ordersPlaceholder: some View {
        emptyTabCard(icon: "list.bullet.rectangle", message: "No orders yet")
    }

    var transactionsPlaceholder: some View {
        emptyTabCard(icon: "clock", message: "No transactions yet")
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

// MARK: - Overview Content

private extension StockDetailView {

    @ViewBuilder
    var overviewContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Stats
            sectionHeader("Estadísticas")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)
            statsCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // Price alerts
            sectionHeader("Price alerts")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)
            priceAlertCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // Stock research
            stockResearchCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // Period returns
            sectionHeader("Rentabilidad")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)
            analystRatingsCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // About
            sectionHeader("Política de Inversión")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)
            aboutCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)
            
            additonalInfoCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)
            
            // Help
            helpCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.xl)

            // Footer
            footerText
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            Text("Capital at risk")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.pageMargin)
        }
    }

    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button("See all") { Haptics.light() }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.blue)
                .buttonStyle(.plain)
        }
    }
}

// MARK: - Stats Card

private extension StockDetailView {

    var statsCard: some View {
        VStack(spacing: 0) {
            statRow(label: "Valor Unidad", value: stock.marketCap)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Inversionistas", value: stock.peRatio)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Inversión Mínima", value: stock.eps)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Saldo Mínimo", value: stock.dividendYield)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(FondyColors.labelTertiary)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }
}

// MARK: - Price Alert Card

private extension StockDetailView {

    var priceAlertCard: some View {
        Button {
            Haptics.light()
            showPriceAlert = true
        } label: {
            HStack(spacing: Spacing.md) {
                // Logo with bell badge
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: stock.logoSystemName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(stock.logoColor)
                        .frame(width: 48, height: 48)
                        .background(stock.logoBackground, in: Circle())

                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 18, height: 18)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 2, y: 2)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("1 \(stock.ticker) = \(Int(stock.priceAlertValue)) \(stock.currencySymbol == "$" ? "USD" : "EUR")")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text("Current: \(stock.formattedPrice)")
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .accessibilityLabel("Price alert: 1 \(stock.ticker) = \(Int(stock.priceAlertValue)) USD")
    }
}

// MARK: - Stock Research Card

private extension StockDetailView {

    var stockResearchCard: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "clock")
                .font(.system(size: 22))
                .foregroundStyle(FondyColors.labelTertiary)
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)

            Text("Stock research returning soon")
                .font(.body)
                .foregroundStyle(FondyColors.labelTertiary)

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }
}

// MARK: - Analyst Ratings Card

private extension StockDetailView {

    var analystRatingsCard: some View {
        let all = stock.periodReturns
        let latestDate = all.map(\.updatedAt).max()
        // Max absolute percent across ALL rows — used to scale bars consistently
        let maxAbs = (all.map { abs($0.percent) }.max() ?? 1.0)

        return VStack(alignment: .leading, spacing: 0) {
            // ── Header ──────────────────────────────────────────────
            HStack {
                Text("Rentabilidad histórica")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                Spacer()
                Text("Efectiva anual")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.md)

            // ── Bar rows (no dividers) ───────────────────────────────
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(all, id: \.label) { item in
                    returnRow(item: item, maxAbs: maxAbs)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xs)


            // ── Footer — cut-off date ───────────────────────────────
            if let date = latestDate {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundStyle(FondyColors.labelTertiary)
                        .accessibilityHidden(true)
                    Text("\(monthYear(date))")
                        .font(.caption2)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
            }
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    /// One bar row: label | bar that grows to fill available width | percent value
    /// The rank badge sits at the tip of the bar.
    private func returnRow(item: PeriodReturn, maxAbs: Double) -> some View {
        {
            let fraction = maxAbs > 0 ? min(1, abs(item.percent) / maxAbs) : 0

            return HStack(spacing: Spacing.md) {
                // Period label — fixed width for alignment
                Text(item.label)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .frame(width: 56, alignment: .leading)

                // Centered bar with dotted midline; blue bars extend left/right from center
                GeometryReader { geo in
                    let half = geo.size.width / 2
                    let barLength = max(6, half * fraction)
                    ZStack {
                        // Dotted midline
                        Path { path in
                            path.move(to: CGPoint(x: half, y: 0))
                            path.addLine(to: CGPoint(x: half, y: geo.size.height))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .foregroundStyle(FondyColors.fillQuaternary)

                        // Filled bar (always blue)
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: barLength, height: 8)
                            .position(
                                x: item.percent >= 0 ? (half + barLength / 2) : (half - barLength / 2),
                                y: geo.size.height / 2
                            )
                    }
                }
                .frame(height: 24)

                // Rank badge column (separate from bar and value)
                rankBadge(rank: item.rank, outOf: item.rankOutOf)
                    .frame(width: 32, alignment: .center)

                // Percent value — single line and scales down if needed
                Text(item.formattedPercent)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 64, alignment: .trailing)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.label): \(item.formattedPercent), puesto \(item.rank) de \(item.rankOutOf)")
        }()
    }

    /// Circular badge at bar tip.
    /// Rank 1 → gold trophy, 2 → silver, 3 → bronze. Rank 4+ → plain number.
    private func rankBadge(rank: Int, outOf: Int) -> some View {
        let size: CGFloat = 22

        let content: AnyView
        let bgColor: Color

        switch rank {
        case 1:
            bgColor = Color(red: 1.0, green: 0.78, blue: 0.0).opacity(0.20)
            content = AnyView(
                Image(systemName: "trophy.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.75, green: 0.52, blue: 0.0))
            )
        case 2:
            bgColor = Color(red: 0.70, green: 0.70, blue: 0.73).opacity(0.25)
            content = AnyView(
                Image(systemName: "trophy.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.48, green: 0.48, blue: 0.52))
            )
        case 3:
            bgColor = Color(red: 0.72, green: 0.44, blue: 0.18).opacity(0.20)
            content = AnyView(
                Image(systemName: "trophy.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.60, green: 0.35, blue: 0.08))
            )
        default:
            bgColor = FondyColors.fillTertiary
            content = AnyView(
                Text("\(rank)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(FondyColors.labelSecondary)
            )
        }

        return ZStack { content }
            .frame(width: size, height: size)
            .background(bgColor, in: Circle())
            .accessibilityHidden(true) // parent row handles accessibility
    }

    /// Formats a Date as "Mar 2025".
    private func monthYear(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt.string(from: date)
    }
}

// MARK: - About Card

private extension StockDetailView {

    var aboutCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            let lines = stock.aboutText.components(separatedBy: "\n\n")
            let displayText = isAboutExpanded ? stock.aboutText : (lines.first ?? stock.aboutText)

            Text(displayText)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(isAboutExpanded ? nil : 6)

            Button(isAboutExpanded ? "See less" : "See more") {
                Haptics.light()
                withAnimation(.springGentle) {
                    isAboutExpanded.toggle()
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.blue)
            .buttonStyle(.plain)
        }
        .padding(Spacing.lg)
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }
}

// MARK: - Help Card

private extension StockDetailView {

    var helpCard: some View {
        Button {
            Haptics.light()
            showHelp = true
        } label: {
            HStack {
                Text("Something wrong? Get help!")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .accessibilityLabel("Something wrong? Get help")
    }
}

// MARK: - Additional Information

private extension StockDetailView {

    var additonalInfoCard: some View {
        VStack(spacing: 0) {
            Button {
                Haptics.light()
                openPDF(resourceName: "Reglamento")
            } label: {
                HStack {
                    Text("Reglamento")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md + 2)
                .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())

            Divider()
                .padding(.leading, Spacing.lg)

            Button {
                Haptics.light()
                openPDF(resourceName: "Prospecto")
            } label: {
                HStack {
                    Text("Prospecto")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md + 2)
                .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    func openPDF(resourceName: String) {
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "pdf") {
            pdfURL = url
            showPDF = true
        }
    }
}
// MARK: - Footer

private extension StockDetailView {

    var footerText: some View {
        VStack(spacing: Spacing.md) {
            Text("Rendimiento histórico no implica rendimientos futuros iguales o semejantes")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)

            Text("Este material es para información de los inversionistas y no está concebido como una oferta o una solicitud para vender o comprar activos.")
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
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - PDF Viewer

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // No-op
    }
}



// MARK: - Preview

#Preview {
    StockDetailView(stock: .apple)
}


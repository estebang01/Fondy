//
//  StockOverviewContent.swift
//  Fondy
//
//  Overview tab extensions for StockDetailView.
//  Sections: overview content, stats card, price alert card, stock research card,
//            analyst ratings card, about card, help card, additional info card, footer.
//

import SwiftUI

// MARK: - Overview Content

extension StockDetailView {

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

extension StockDetailView {

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

extension StockDetailView {

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

extension StockDetailView {

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

extension StockDetailView {

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
    func returnRow(item: PeriodReturn, maxAbs: Double) -> some View {
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
    func rankBadge(rank: Int, outOf: Int) -> some View {
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
    func monthYear(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt.string(from: date)
    }
}

// MARK: - About Card

extension StockDetailView {

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

extension StockDetailView {

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

extension StockDetailView {

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

extension StockDetailView {

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

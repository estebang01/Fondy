//
//  GeneratingPortfolioView.swift
//  Fondy
//
//  AI portfolio generation animation + result display.
//  Phase 1: Loading animation with cycling messages.
//  Phase 2: Generated portfolio with donut chart and asset list.
//

import SwiftUI

/// Shows the AI generation animation, then the resulting portfolio.
struct GeneratingPortfolioView: View {
    let state: PortfolioGeneratorState
    var onDismiss: () -> Void

    @State private var isAppeared = false

    // MARK: - Body

    var body: some View {
        Group {
            if state.step == .generating {
                generatingPhase
            } else {
                resultPhase
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            guard state.step == .generating else { return }
            state.isGenerating = true
            await PortfolioGeneratorService.generate(state: state)
            withAnimation(.springGentle) {
                state.next()
            }
        }
    }
}

// MARK: - Generating Phase

private extension GeneratingPortfolioView {

    var generatingPhase: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            generatingIllustration
            generatingText
            progressBar

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Spacing.pageMargin)
    }

    // MARK: Generating Illustration

    var generatingIllustration: some View {
        ZStack {
            // Rotating dots ring
            RotatingDotsView()

            // Pulsing sparkle icon
            Image(systemName: "sparkles")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, options: .repeating)
        }
        .frame(width: 120, height: 120)
    }

    // MARK: Generating Text

    var generatingText: some View {
        VStack(spacing: Spacing.sm) {
            Text("Creating Your Portfolio")
                .font(.title3.bold())
                .foregroundStyle(FondyColors.labelPrimary)

            Text(state.currentGenerationMessage)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: state.currentGenerationMessage)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: Progress Bar

    var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(FondyColors.fillTertiary)
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * state.generationProgress, height: 6)
                    .animation(.springGentle, value: state.generationProgress)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, Spacing.xxxl)
    }
}

// MARK: - Result Phase

private extension GeneratingPortfolioView {

    var resultPhase: some View {
        VStack(spacing: 0) {
            // Close / Done header
            HStack {
                Spacer()
                closeButton
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    resultHeader
                        .padding(.top, Spacing.lg)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 16)

                    if let portfolio = state.generatedPortfolio {
                        portfolioNameCard(portfolio)
                            .padding(.top, Spacing.xxl)
                            .opacity(isAppeared ? 1 : 0)
                            .offset(y: isAppeared ? 0 : 20)

                        allocationChart(portfolio)
                            .padding(.top, Spacing.xxl)
                            .opacity(isAppeared ? 1 : 0)
                            .offset(y: isAppeared ? 0 : 22)

                        assetList(portfolio)
                            .padding(.top, Spacing.xxl)
                            .opacity(isAppeared ? 1 : 0)
                            .offset(y: isAppeared ? 0 : 24)

                        projectedReturnsCard(portfolio)
                            .padding(.top, Spacing.xxl)
                            .opacity(isAppeared ? 1 : 0)
                            .offset(y: isAppeared ? 0 : 26)
                    }

                    // Bottom padding
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, Spacing.pageMargin)
            }
            .scrollIndicators(.hidden)

            createButton
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.xxxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
        }
        .onAppear {
            Haptics.success()
            withAnimation(.springGentle.delay(0.15)) {
                isAppeared = true
            }
        }
    }

    // MARK: Close Button

    var closeButton: some View {
        Button {
            Haptics.light()
            onDismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .frame(width: 36, height: 36)
                .background(FondyColors.fillTertiary, in: Circle())
        }
        .accessibilityLabel("Close")
    }

    // MARK: Result Header

    var resultHeader: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.blue)

            Text("Your AI Portfolio")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: Portfolio Name Card

    func portfolioNameCard(_ portfolio: GeneratedPortfolio) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(portfolio.name)
                .font(.title.bold())
                .foregroundStyle(FondyColors.labelPrimary)

            HStack(spacing: Spacing.md) {
                // Risk badge
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "shield.fill")
                        .font(.caption)
                    Text("Risk \(portfolio.riskScore)/10")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(riskColor(for: portfolio.riskScore))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(
                    riskColor(for: portfolio.riskScore).opacity(0.12),
                    in: Capsule()
                )

                // Risk label
                Text(portfolio.riskLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Text(String(format: "Expected annual return: %.1f%%", portfolio.expectedReturn))
                .font(.subheadline)
                .foregroundStyle(FondyColors.positive)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.xl)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    func riskColor(for score: Int) -> Color {
        if score <= 3 { return .green }
        if score <= 6 { return .orange }
        return .red
    }

    // MARK: Allocation Chart

    func allocationChart(_ portfolio: GeneratedPortfolio) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Allocation")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)

            // Simple donut chart
            SimpleDonutChart(allocations: portfolio.allocations)
                .frame(height: 200)
                .frame(maxWidth: .infinity)

            // Legend
            allocationLegend(portfolio.allocations)
        }
        .padding(Spacing.xl)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    func allocationLegend(_ allocations: [PortfolioAllocation]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: Spacing.sm
        ) {
            ForEach(allocations) { alloc in
                HStack(spacing: Spacing.sm) {
                    Circle()
                        .fill(alloc.color)
                        .frame(width: 10, height: 10)

                    Text(alloc.ticker)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)

                    Spacer()

                    Text(String(format: "%.0f%%", alloc.percentage))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(FondyColors.labelSecondary)
                }
            }
        }
    }

    // MARK: Asset List

    func assetList(_ portfolio: GeneratedPortfolio) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Assets")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                ForEach(Array(portfolio.allocations.enumerated()), id: \.element.id) { index, alloc in
                    assetRow(alloc)

                    if index < portfolio.allocations.count - 1 {
                        Divider()
                            .padding(.leading, Spacing.iconDividerInset)
                    }
                }
            }
        }
        .padding(Spacing.xl)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    func assetRow(_ alloc: PortfolioAllocation) -> some View {
        HStack(spacing: Spacing.md) {
            // Icon
            Text(alloc.ticker.prefix(2))
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(alloc.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Name + sector
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(alloc.assetName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .lineLimit(1)

                Text(alloc.sector)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer()

            // Percentage
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text(String(format: "%.0f%%", alloc.percentage))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Text(alloc.ticker)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
        }
        .padding(.vertical, Spacing.md)
    }

    // MARK: Projected Returns

    func projectedReturnsCard(_ portfolio: GeneratedPortfolio) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Projected Value")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)

            HStack(spacing: Spacing.xl) {
                projectedItem(
                    title: "1 Year",
                    value: portfolio.projectedValueOneYear,
                    subtitle: "$\(Int(portfolio.monthlyInvestment))/mo"
                )

                Divider()
                    .frame(height: 50)

                projectedItem(
                    title: "5 Years",
                    value: portfolio.projectedValueFiveYear,
                    subtitle: "$\(Int(portfolio.monthlyInvestment))/mo"
                )
            }

            Text("Projections are estimates based on historical data and are not guaranteed.")
                .font(.caption2)
                .foregroundStyle(FondyColors.labelTertiary)
                .lineSpacing(2)
        }
        .padding(Spacing.xl)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    func projectedItem(title: String, value: Double, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(FondyColors.labelSecondary)

            Text(formatCurrency(value))
                .font(.title3.bold())
                .foregroundStyle(FondyColors.positive)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    // MARK: Create Button

    var createButton: some View {
        Button {
            Haptics.success()
            onDismiss()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                Text("Create Portfolio")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg + Spacing.xs)
            .background(
                .blue,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Rotating Dots View

private struct RotatingDotsView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(.blue.opacity(0.2 + Double(index) * 0.1))
                    .frame(width: 8, height: 8)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Simple Donut Chart

private struct SimpleDonutChart: View {
    let allocations: [PortfolioAllocation]

    @State private var animationProgress: CGFloat = 0

    private var segments: [(PortfolioAllocation, Double, Double)] {
        let total = allocations.reduce(0) { $0 + $1.percentage }
        guard total > 0 else { return [] }
        var cursor = 0.0
        return allocations.map { alloc in
            let sweep = (alloc.percentage / total) * 360.0
            let start = cursor
            cursor += sweep
            return (alloc, start, sweep)
        }
    }

    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.element.0.id) { _, segment in
                let (alloc, start, sweep) = segment
                DonutArc(
                    startAngle: .degrees(start - 90),
                    endAngle: .degrees(start + sweep * animationProgress - 90),
                    lineWidth: 28
                )
                .stroke(alloc.color, style: StrokeStyle(lineWidth: 28, lineCap: .butt))
            }

            // Center label
            if let top = allocations.max(by: { $0.percentage < $1.percentage }) {
                VStack(spacing: 2) {
                    Text(String(format: "%.0f%%", top.percentage))
                        .font(.title2.bold())
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text(top.ticker)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animationProgress = 1
            }
        }
    }
}

private struct DonutArc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

// MARK: - Preview

#Preview("Generating") {
    let state = PortfolioGeneratorState()
    let _ = { state.step = .generating }()
    GeneratingPortfolioView(state: state, onDismiss: {})
}

#Preview("Result") {
    let state = PortfolioGeneratorState()
    let _ = {
        state.selectedGoal = .wealthGrowth
        state.selectedRisk = .moderate
        state.selectedHorizon = .mediumTerm
        state.monthlyAmount = 250
        state.selectedSectors = [.technology, .healthcare, .aiML]
        state.step = .result
        state.generatedPortfolio = GeneratedPortfolio(
            name: "Growth Navigator",
            riskScore: 6,
            riskLabel: "Moderate",
            allocations: [
                .init(assetName: "S&P 500 Index", ticker: "VOO", sector: "Equities", percentage: 30, color: .blue),
                .init(assetName: "Nasdaq 100 ETF", ticker: "QQQ", sector: "Technology", percentage: 20, color: .purple),
                .init(assetName: "International Developed", ticker: "VEA", sector: "Equities", percentage: 15, color: .green),
                .init(assetName: "Aggregate Bond ETF", ticker: "AGG", sector: "Bonds", percentage: 15, color: .orange),
                .init(assetName: "Real Estate Trust", ticker: "VNQ", sector: "Real Estate", percentage: 10, color: .cyan),
                .init(assetName: "ESG Leaders ETF", ticker: "ESGU", sector: "Sustainability", percentage: 10, color: .pink),
            ],
            expectedReturn: 7.5,
            monthlyInvestment: 250,
            projectedValueOneYear: 3115,
            projectedValueFiveYear: 18530
        )
    }()
    GeneratingPortfolioView(state: state, onDismiss: {})
}

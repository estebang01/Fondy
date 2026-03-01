//
//  AdvancedSearchView.swift
//  Fondy
//
//  Advanced stock screener sheet with sectors, market cap, P/E ratio,
//  dividend yield, and 1y price change filters.
//

import SwiftUI

struct AdvancedSearchView: View {
    @Binding var selectedSectors: Set<StockSector>
    @Binding var selectedMarketCaps: Set<MarketCapCategory>
    @Binding var peRatioRange: ClosedRange<Double>
    @Binding var dividendYieldRange: ClosedRange<Double>
    @Binding var yearlyChangeRange: ClosedRange<Double>

    @Environment(\.dismiss) private var dismiss
    @State private var showSectorsPicker = false

    // Local copies for the top-3 sectors display
    private var displayedSectors: [StockSector] {
        let ordered: [StockSector] = selectedSectors.isEmpty
            ? [.technology, .financial, .consumerStaples]
            : Array(StockSector.allCases.filter { selectedSectors.contains($0) }.prefix(3))
        return ordered.isEmpty ? [.technology, .financial, .consumerStaples] : ordered
    }

    private var sectorsSubtitle: String {
        if selectedSectors.isEmpty {
            return "\(StockSector.allCases.count)"
        }
        return "\(selectedSectors.count) of \(StockSector.allCases.count)"
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    sectorsSection
                    marketCapSection
                    peRatioSection
                    dividendYieldSection
                    yearlyChangeSection
                    disclaimerSection
                }
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                viewStocksButton
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Haptics.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(FondyColors.labelPrimary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Advanced search")
            .navigationDestination(isPresented: $showSectorsPicker) {
                SectorsPickerView(selectedSectors: $selectedSectors)
            }
        }
    }
}

// MARK: - Header

private extension AdvancedSearchView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Advanced search")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            Text("Use the screener to filter stocks")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.xl)
        .padding(.bottom, Spacing.sectionGap)
    }
}

// MARK: - Sectors

private extension AdvancedSearchView {

    var sectorsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack(spacing: Spacing.sm) {
                Text("Sectors")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Text("\u{00B7} \(sectorsSubtitle)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelSecondary)

                Button {
                    Haptics.light()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .buttonStyle(.plain)
            }

            // Sector rows card
            VStack(spacing: 0) {
                ForEach(Array(displayedSectors.enumerated()), id: \.element.id) { index, sector in
                    sectorRow(sector)

                    if index < displayedSectors.count - 1 {
                        Divider()
                            .padding(.leading, 44 + Spacing.md + Spacing.lg)
                    }
                }

                // "See all sectors" link
                Divider()
                    .padding(.leading, Spacing.lg)

                Button {
                    Haptics.light()
                    showSectorsPicker = true
                } label: {
                    Text("See all sectors")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md + 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.bottom, Spacing.sectionGap)
    }

    func sectorRow(_ sector: StockSector) -> some View {
        Button {
            Haptics.selection()
            if selectedSectors.contains(sector) {
                selectedSectors.remove(sector)
            } else {
                selectedSectors.insert(sector)
            }
        } label: {
            HStack(spacing: Spacing.md) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(selectedSectors.contains(sector) ? Color.blue : FondyColors.labelTertiary, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                        .background(
                            selectedSectors.contains(sector)
                                ? RoundedRectangle(cornerRadius: 6, style: .continuous).fill(.blue)
                                : nil
                        )

                    if selectedSectors.contains(sector) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                // Sector icon
                Image(systemName: sector.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .liquidGlass(tint: .blue, cornerRadius: 50)

                Text(sector.rawValue)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Market Cap

private extension AdvancedSearchView {

    var marketCapSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack(spacing: Spacing.sm) {
                Text("Market cap")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Button {
                    Haptics.light()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: Spacing.sm) {
                ForEach(MarketCapCategory.allCases) { cap in
                    marketCapPill(cap)
                }
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.bottom, Spacing.sectionGap)
    }

    func marketCapPill(_ cap: MarketCapCategory) -> some View {
        Button {
            Haptics.selection()
            if selectedMarketCaps.contains(cap) {
                selectedMarketCaps.remove(cap)
            } else {
                selectedMarketCaps.insert(cap)
            }
        } label: {
            Text(cap.rawValue)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selectedMarketCaps.contains(cap) ? .white : FondyColors.labelPrimary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm + 2)
                .liquidGlass(tint: selectedMarketCaps.contains(cap) ? .blue : .clear, cornerRadius: 50)
        }
        .buttonStyle(LiquidGlassButtonStyle())
    }
}

// MARK: - P/E Ratio

private extension AdvancedSearchView {

    var peRatioSection: some View {
        rangeSliderSection(
            title: "P/E Ratio",
            range: $peRatioRange,
            bounds: 0...100,
            minLabel: "0",
            maxLabel: "100+",
            formatValue: { value in
                if value >= 100 { return "100+" }
                return String(format: "%.0f", value)
            }
        )
    }
}

// MARK: - Dividend Yield

private extension AdvancedSearchView {

    var dividendYieldSection: some View {
        rangeSliderSection(
            title: "Dividend Yield",
            range: $dividendYieldRange,
            bounds: 0...10,
            minLabel: "0%",
            maxLabel: "10%+",
            formatValue: { value in
                if value >= 10 { return "10%+" }
                return String(format: "%.0f%%", value)
            }
        )
    }
}

// MARK: - 1y Stock Price Change

private extension AdvancedSearchView {

    var yearlyChangeSection: some View {
        rangeSliderSection(
            title: "1y Stock Price Change",
            range: $yearlyChangeRange,
            bounds: -100...300,
            minLabel: "-100%",
            maxLabel: "300%+",
            formatValue: { value in
                if value >= 300 { return "300%+" }
                if value <= -100 { return "-100%" }
                return String(format: "%.0f%%", value)
            }
        )
    }
}

// MARK: - Range Slider

private extension AdvancedSearchView {

    func rangeSliderSection(
        title: String,
        range: Binding<ClosedRange<Double>>,
        bounds: ClosedRange<Double>,
        minLabel: String,
        maxLabel: String,
        formatValue: @escaping (Double) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Button {
                    Haptics.light()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: Spacing.sm) {
                Text("\(formatValue(range.wrappedValue.lowerBound)) - \(formatValue(range.wrappedValue.upperBound))")
                    .font(.body.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(maxWidth: .infinity)

                RangeSliderView(
                    range: range,
                    bounds: bounds
                )

                HStack {
                    Text(minLabel)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                    Spacer()
                    Text(maxLabel)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
            }
            .padding(Spacing.lg)
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.bottom, Spacing.sectionGap)
    }
}

// MARK: - Disclaimer

private extension AdvancedSearchView {

    var disclaimerSection: some View {
        Text("Past performance is not a reliable indicator of future results.")
            .font(.caption)
            .foregroundStyle(FondyColors.labelTertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.lg)
    }
}

// MARK: - View Stocks Button

private extension AdvancedSearchView {

    var viewStocksButton: some View {
        Button {
            Haptics.medium()
            dismiss()
        } label: {
            Text("View stocks")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
        }
        .buttonStyle(PositiveButtonStyle(cornerRadius: 14))
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.bottom, Spacing.xl)
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .center
            )
        )
    }
}

// MARK: - Range Slider View

/// A custom dual-thumb range slider.
struct RangeSliderView: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - thumbSize

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(FondyColors.fillTertiary)
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)

                // Active track
                let lowerX = offsetFor(value: range.lowerBound, in: width)
                let upperX = offsetFor(value: range.upperBound, in: width)

                Capsule()
                    .fill(.blue)
                    .frame(width: upperX - lowerX + thumbSize, height: trackHeight)
                    .offset(x: lowerX)

                // Lower thumb
                Circle()
                    .fill(.blue)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    .offset(x: lowerX)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = valueFor(offset: value.location.x - thumbSize / 2, in: width)
                                let clamped = min(newValue, range.upperBound - stepSize)
                                range = max(bounds.lowerBound, clamped)...range.upperBound
                            }
                    )

                // Upper thumb
                Circle()
                    .fill(.blue)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    .offset(x: upperX)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = valueFor(offset: value.location.x - thumbSize / 2, in: width)
                                let clamped = max(newValue, range.lowerBound + stepSize)
                                range = range.lowerBound...min(bounds.upperBound, clamped)
                            }
                    )
            }
        }
        .frame(height: thumbSize)
    }

    private var stepSize: Double {
        (bounds.upperBound - bounds.lowerBound) * 0.01
    }

    private func offsetFor(value: Double, in width: CGFloat) -> CGFloat {
        let fraction = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return CGFloat(fraction) * width
    }

    private func valueFor(offset: CGFloat, in width: CGFloat) -> Double {
        let fraction = Double(offset / width)
        return bounds.lowerBound + fraction * (bounds.upperBound - bounds.lowerBound)
    }
}

// MARK: - Preview

#Preview {
    AdvancedSearchView(
        selectedSectors: .constant([]),
        selectedMarketCaps: .constant([]),
        peRatioRange: .constant(0...100),
        dividendYieldRange: .constant(0...10),
        yearlyChangeRange: .constant(-100...300)
    )
}

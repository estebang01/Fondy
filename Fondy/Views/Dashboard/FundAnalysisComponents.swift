//
//  FundAnalysisComponents.swift
//  Fondy
//

import SwiftUI

// MARK: - Interactive Donut Card (full-width: donut left, legend right)

struct InteractiveDonutCard: View {
    let title: String
    let slices: [AnalysisSlice]
    let updatedAt: Date

    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                Spacer()
                Text(FondyDateFormatters.monthYear.string(from: updatedAt))
                    .font(.caption2)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.md)

            HStack(alignment: .center, spacing: Spacing.lg) {
                DonutChart(slices: slices, selectedIndex: $selectedIndex, size: 150)
                    .frame(width: 150, height: 150)

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(slices.enumerated()), id: \.element.id) { idx, slice in
                        LegendRow(slice: slice, isSelected: selectedIndex == idx) {
                            withAnimation(.springInteractive) {
                                selectedIndex = selectedIndex == idx ? nil : idx
                            }
                            Haptics.selection()
                        }
                        if idx < slices.count - 1 { Divider() }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }
}

// MARK: - Interactive Donut Panel (compact, inside double-card)

struct InteractiveDonutPanel: View {
    let title: String
    let slices: [AnalysisSlice]

    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xs)

            DonutChart(slices: slices, selectedIndex: $selectedIndex, size: 110)
                .frame(width: 110, height: 110)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.xs)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(slices.enumerated()), id: \.element.id) { idx, slice in
                    LegendRow(slice: slice, isSelected: selectedIndex == idx, compact: true) {
                        withAnimation(.springInteractive) {
                            selectedIndex = selectedIndex == idx ? nil : idx
                        }
                        Haptics.selection()
                    }
                    if idx < slices.count - 1 { Divider() }
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.bottom, Spacing.md)
        }
    }
}

// MARK: - Legend Row

struct LegendRow: View {
    let slice: AnalysisSlice
    let isSelected: Bool
    var compact: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: compact ? 5 : Spacing.sm) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(slice.color)
                    .frame(width: isSelected ? 10 : 8, height: isSelected ? 10 : 8)
                    .animation(.springGentle, value: isSelected)
                    .accessibilityHidden(true)

                Text(slice.label)
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(isSelected ? FondyColors.labelPrimary : FondyColors.labelSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(String(format: "%.1f%%", slice.percent))
                    .font(compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                    .foregroundStyle(isSelected ? slice.color : FondyColors.labelTertiary)
                    .monospacedDigit()
            }
            .padding(.vertical, compact ? 4 : 6)
            .padding(.horizontal, compact ? 2 : 0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected ? slice.color.opacity(0.08) : Color.clear)
                .animation(.springGentle, value: isSelected)
        )
    }
}

// MARK: - Issuers Card

struct IssuersCard: View {
    let issuers: [FundIssuer]
    let updatedAt: Date

    @State private var selectedIndex: Int? = nil

    /// Derive donut slices from issuers
    private var slices: [AnalysisSlice] {
        issuers.map { AnalysisSlice(label: $0.ticker, percent: $0.percent, color: $0.color) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Top 10 issuers")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                Spacer()
                Text(FondyDateFormatters.monthYear.string(from: updatedAt))
                    .font(.caption2)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.md)

            // Interactive donut centred
            DonutChart(slices: slices, selectedIndex: $selectedIndex, size: 160)
                .frame(width: 160, height: 160)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.lg)

            Divider().padding(.horizontal, Spacing.lg)

            // Issuer list rows
            ForEach(Array(issuers.enumerated()), id: \.element.id) { idx, issuer in
                IssuerRow(issuer: issuer, isSelected: selectedIndex == idx) {
                    withAnimation(.springInteractive) {
                        selectedIndex = selectedIndex == idx ? nil : idx
                    }
                    Haptics.selection()
                }
                if idx < issuers.count - 1 {
                    Divider().padding(.leading, Spacing.lg + 48)
                }
            }

            // Footer
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundStyle(FondyColors.labelTertiary)
                    .accessibilityHidden(true)
                Text(" \(FondyDateFormatters.monthYear.string(from: updatedAt))")
                    .font(.caption2)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }
}

// MARK: - Issuer Row

struct IssuerRow: View {
    let issuer: FundIssuer
    let isSelected: Bool
    let onTap: () -> Void

    /// Scale bar width: max issuer is ~14%, so normalise to 14 as 100%
    private var barFraction: CGFloat { CGFloat(min(issuer.percent / 15.0, 1.0)) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Logo circle with colour ring when selected
                ZStack {
                    Circle().fill(issuer.logoBackground)
                    Image(systemName: issuer.logoSymbol)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(issuer.logoColor)
                }
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .strokeBorder(issuer.color, lineWidth: isSelected ? 2.5 : 0)
                        .animation(.springGentle, value: isSelected)
                )
                .accessibilityHidden(true)

                // Name + bar
                VStack(alignment: .leading, spacing: 4) {
                    Text(issuer.name)
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .lineLimit(1)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(FondyColors.fillTertiary)
                                .frame(height: 4)
                            Capsule()
                                .fill(issuer.color.opacity(isSelected ? 1.0 : 0.65))
                                .frame(width: geo.size.width * barFraction, height: 4)
                                .animation(.springGentle, value: isSelected)
                        }
                    }
                    .frame(height: 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Percent
                Text(String(format: "%.1f%%", issuer.percent))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? issuer.color : FondyColors.labelPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .frame(width: 44, alignment: .trailing)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                Rectangle()
                    .fill(isSelected ? issuer.color.opacity(0.06) : Color.clear)
                    .animation(.springGentle, value: isSelected)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(issuer.name): \(String(format: "%.1f%%", issuer.percent))")
    }
}

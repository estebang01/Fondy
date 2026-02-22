//
//  FundAnalysisView.swift
//  Fondy
//
//  Portfolio analysis tab:
//    1. Plazos y Duración  — full-width donut + duration card
//    2. Composición        — 2×2 donuts in two stacked cards (no sub-header)
//    3. Emisores           — donut + 10 issuers with logo circles
//

import SwiftUI

// MARK: - Main View

struct FundAnalysisView: View {
    let analysis: FundAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── 1. Plazos y Duración ──────────────────────────────────
            sectionHeader("Plazos y Duración")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            InteractiveDonutCard(
                title: "Por plazo",
                slices: analysis.plazoSlices,
                updatedAt: analysis.updatedAt
            )
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.sm)

            durationCard
                .padding(.bottom, Spacing.sectionGap)

            // ── 2. Composición — 2 cards apiladas, 2 donuts c/u ───────
            sectionHeader("Composición")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            // Card A: Sector + Moneda
            doubleDonutCard(
                leftTitle: "Sector",
                leftSlices: analysis.sectorSlices,
                rightTitle: "Moneda",
                rightSlices: analysis.monedaSlices
            )
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.sm)

            // Card B: País + Tipo de Activo (sin sección separada)
            doubleDonutCard(
                leftTitle: "País",
                leftSlices: analysis.paisSlices,
                rightTitle: "Tipo de Activo",
                rightSlices: analysis.tipoActivoSlices
            )
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.sectionGap)

            // ── 3. Emisores ───────────────────────────────────────────
            sectionHeader("Emisores")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            IssuersCard(issuers: analysis.issuers, updatedAt: analysis.updatedAt)
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // ── Footer ────────────────────────────────────────────────
            footerView
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.xl)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(FondyColors.labelPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Double Donut Card

    private func doubleDonutCard(
        leftTitle: String,
        leftSlices: [AnalysisSlice],
        rightTitle: String,
        rightSlices: [AnalysisSlice]
    ) -> some View {
        HStack(alignment: .top, spacing: 0) {
            InteractiveDonutPanel(title: leftTitle, slices: leftSlices)
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(FondyColors.fillTertiary)
                .frame(width: 0.5)
                .padding(.vertical, Spacing.lg)

            InteractiveDonutPanel(title: rightTitle, slices: rightSlices)
                .frame(maxWidth: .infinity)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }
}

// MARK: - Duration Card

private extension FundAnalysisView {

    var durationCard: some View {
        VStack(spacing: 0) {
            durationRow(label: "Duración del portafolio", value: analysis.duration.duracion,        icon: "calendar")
            Divider().padding(.horizontal, Spacing.lg)
            durationRow(label: "Duración sin cash",       value: analysis.duration.duracionSinCash, icon: "minus.circle")
            Divider().padding(.horizontal, Spacing.lg)
            durationRow(label: "Duración final",          value: analysis.duration.duracionFinal,   icon: "checkmark.circle.fill", highlight: true)

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundStyle(FondyColors.labelTertiary)
                    .accessibilityHidden(true)
                Text("Datos a \(monthYear(analysis.duration.updatedAt))")
                    .font(.caption2)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        .padding(.horizontal, Spacing.pageMargin)
    }

    private func durationRow(label: String, value: String, icon: String, highlight: Bool = false) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(highlight ? .blue : FondyColors.labelTertiary)
                .frame(width: 22)
                .accessibilityHidden(true)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelTertiary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(highlight ? .blue : FondyColors.labelPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }

    private func monthYear(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "MMM yyyy"; return fmt.string(from: date)
    }

    var footerView: some View {
        Text("La composición del portafolio puede variar. Los datos presentados corresponden al último corte disponible y son de carácter informativo.")
            .font(.footnote)
            .foregroundStyle(FondyColors.labelTertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        FundAnalysisView(analysis: .sample)
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

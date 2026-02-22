//
//  StockFinancialsView.swift
//  Fondy
//
//  Estadísticas tab for StockDetailView — fund-centric layout.
//  Shows: Fund Classes → Detailed Stats → Commissions → Investment Policy (if available)
//

import SwiftUI

// MARK: - Main View

struct StockFinancialsView: View {
    let financials: StockFinancials

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── 1. Fund Classes ────────────────────────────────────────
            if !financials.fundClasses.isEmpty {
                sectionHeader("Clases del Fondo")
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, Spacing.md)

                fundClassesCard
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, Spacing.sectionGap)
            }

            // ── 2. Detailed Statistics ─────────────────────────────────
            if let stats = financials.fundStats {
                sectionHeader("Estadísticas")
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, Spacing.md)

                fundStatsCard(stats: stats)
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, Spacing.sectionGap)
            }

            // ── 3. Commissions ─────────────────────────────────────────
            if let commissions = financials.fundCommissions {
                sectionHeader("Comisiones")
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, Spacing.md)

                fundCommissionsCard(commissions: commissions)
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, Spacing.sectionGap)
            }

            // ── 4. Investment Policy (optional) ────────────────────────
            if let policy = financials.investmentPolicy {
                InvestmentPolicyView(policy: policy)
            }

            // ── Footer ─────────────────────────────────────────────────
            footerText
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xl)
        }
    }
}

// MARK: - Section Header

private extension StockFinancialsView {

    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(FondyColors.labelPrimary)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Fund Classes Card

private extension StockFinancialsView {

    var fundClassesCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(financials.fundClasses.enumerated()), id: \.element.id) { idx, fundClass in
                fundClassRow(fundClass)
                if idx < financials.fundClasses.count - 1 {
                    Divider().padding(.leading, Spacing.lg + 44)
                }
            }
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    func fundClassRow(_ fundClass: FundClass) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Icon
            Image(systemName: fundClass.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.10), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Class name + fee badge
                HStack(alignment: .firstTextBaseline) {
                    Text(fundClass.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                    Spacer()
                    Text(fundClass.managementFee)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.10), in: Capsule())
                }

                // Description
                Text(fundClass.description)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Minimum investment pill
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(FondyColors.labelTertiary)
                        .accessibilityHidden(true)
                    Text("Mínimo \(fundClass.minimumInvestment)")
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .padding(.top, Spacing.xxs)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }
}

// MARK: - Fund Stats Card

private extension StockFinancialsView {

    func fundStatsCard(stats: FundStats) -> some View {
        VStack(spacing: 0) {
            statRow(label: "Valor Unidad",                        value: stats.valorUnidad)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Número de Inversionistas",            value: stats.numeroInversionistas)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Inversión Mínima",                    value: stats.inversionMinima)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Saldo Mínimo",                        value: stats.saldoMinimo)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Preaviso de retiro",                  value: stats.preaviso)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Pacto de permanencia",                value: stats.pacto)
            Divider().padding(.horizontal, Spacing.lg)
            statRow(label: "Sanción por retiro anticipado",       value: stats.sancion)

            // Updated date footer
            updatedFooter(stats.updatedAt)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    func statRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelTertiary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.md)
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }
}

// MARK: - Fund Commissions Card

private extension StockFinancialsView {

    func fundCommissionsCard(commissions: FundCommissions) -> some View {
        VStack(spacing: 0) {
            commissionRow(label: "Administración",  value: commissions.administracion)
            Divider().padding(.horizontal, Spacing.lg)
            commissionRow(label: "Gestión",         value: commissions.gestion)
            Divider().padding(.horizontal, Spacing.lg)
            commissionRow(label: "Éxito",           value: commissions.exito, multiline: true)
            Divider().padding(.horizontal, Spacing.lg)
            commissionRow(label: "Entrada",         value: commissions.entrada)
            Divider().padding(.horizontal, Spacing.lg)
            commissionRow(label: "Salida",          value: commissions.salida)

            // Highlight row — effective charged last month
            Divider().padding(.horizontal, Spacing.lg)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Efectivos cobrados")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                    Text("Último mes")
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                Spacer(minLength: Spacing.md)
                Text(commissions.efectivoCobrado)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + 2)

            // Updated date footer
            updatedFooter(commissions.updatedAt)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    func commissionRow(label: String, value: String, multiline: Bool = false) -> some View {
        HStack(alignment: multiline ? .top : .center) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelTertiary)
            Spacer(minLength: Spacing.md)
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }
}

// MARK: - Shared Helpers

private extension StockFinancialsView {

    func updatedFooter(_ date: Date) -> some View {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        let label = fmt.string(from: date)
        return HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 10))
                .foregroundStyle(FondyColors.labelTertiary)
                .accessibilityHidden(true)
            Text("Datos a \(label)")
                .font(.caption2)
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    var footerText: some View {
        VStack(spacing: Spacing.md) {
            Text("Rendimiento histórico no implica rendimientos futuros iguales o semejantes.")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)

            Text("La información presentada es de carácter informativo y no constituye asesoría de inversión. Los datos del fondo están sujetos a cambios.")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Investment Policy View

private struct InvestmentPolicyView: View {
    let policy: FundInvestmentPolicy

    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Objective & Strategy
            policySectionHeader("Objetivo y Estrategia")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            objectiveStrategyCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // Fund Details
            policySectionHeader("Detalles del Fondo")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            fundDetailsCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // Risk & Costs
            policySectionHeader("Riesgo y Costos")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            riskCostsCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)

            // Benchmark & Constraints
            policySectionHeader("Benchmark y Restricciones")
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.md)

            benchmarkCard
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.sectionGap)
        }
    }

    // MARK: - Section Header

    private func policySectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.bold))
            .foregroundStyle(FondyColors.labelPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Cards

    private var objectiveStrategyCard: some View {
        VStack(spacing: 0) {
            policyTextRow(label: "Objetivo de Inversión",  dataPoint: policy.investmentObjective)
            Divider().padding(.horizontal, Spacing.lg)
            policyTextRow(label: "Estrategia de Inversión", dataPoint: policy.investmentStrategy)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    private var fundDetailsCard: some View {
        VStack(spacing: 0) {
            policyInlineRow(label: "Tipo de Fondo",         dataPoint: policy.fundType)
            Divider().padding(.horizontal, Spacing.lg)
            policyInlineRow(label: "Fecha de Inicio",       dataPoint: policy.inceptionDate)
            Divider().padding(.horizontal, Spacing.lg)
            policyInlineRow(label: "Domicilio",             dataPoint: policy.domicile)
            Divider().padding(.horizontal, Spacing.lg)
            policyInlineRow(label: "Moneda",                dataPoint: policy.currency)
            Divider().padding(.horizontal, Spacing.lg)
            policyTextRow(label: "Método de Replicación",   dataPoint: policy.replicationMethod)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    private var riskCostsCard: some View {
        VStack(spacing: 0) {
            policyTextRow(label: "Perfil de Riesgo",        dataPoint: policy.riskProfile)
            Divider().padding(.horizontal, Spacing.lg)
            policyInlineRow(label: "TER",                   dataPoint: policy.totalExpenseRatio)
            Divider().padding(.horizontal, Spacing.lg)
            policyInlineRow(label: "Comisión de Gestión",   dataPoint: policy.managementFee)
            Divider().padding(.horizontal, Spacing.lg)
            policyTextRow(label: "Política de Distribución", dataPoint: policy.distributionPolicy)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    private var benchmarkCard: some View {
        VStack(spacing: 0) {
            policyInlineRow(label: "Benchmark",             dataPoint: policy.benchmark)
            Divider().padding(.horizontal, Spacing.lg)
            policyTextRow(label: "Enfoque Geográfico",      dataPoint: policy.geographicFocus)
            Divider().padding(.horizontal, Spacing.lg)
            policyTextRow(label: "Enfoque Sectorial",       dataPoint: policy.sectorFocus)
            Divider().padding(.horizontal, Spacing.lg)
            policyTextRow(label: "Liquidez",                dataPoint: policy.liquidityRequirements)
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
    }

    // MARK: - Row Builders

    private func policyTextRow(label: String, dataPoint: PolicyDataPoint) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
            Text(dataPoint.value)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .fixedSize(horizontal: false, vertical: true)
            updatedLabel(dataPoint.lastUpdated)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func policyInlineRow(label: String, dataPoint: PolicyDataPoint) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .top) {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelTertiary)
                Spacer()
                Text(dataPoint.value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .multilineTextAlignment(.trailing)
            }
            updatedLabel(dataPoint.lastUpdated)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
    }

    private func updatedLabel(_ date: Date) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "clock")
                .font(.system(size: 10))
                .foregroundStyle(FondyColors.labelTertiary)
                .accessibilityHidden(true)
            Text("Actualizado \(Self.dateFormatter.string(from: date))")
                .font(.caption2)
                .foregroundStyle(FondyColors.labelTertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        StockFinancialsView(financials: .apple)
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}


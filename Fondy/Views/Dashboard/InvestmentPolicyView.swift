//
//  InvestmentPolicyView.swift
//  Fondy
//
//  Investment policy detail view with 4 sections:
//  Objective/Strategy, Fund Details, Risk/Costs, Benchmark/Constraints.
//

import SwiftUI

struct InvestmentPolicyView: View {
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

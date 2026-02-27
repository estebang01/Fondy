//
//  RiskStepView.swift
//  Fondy
//
//  Risk tolerance selection step with animated gauge and color-coded cards.
//

import SwiftUI

/// Asks the user to select their risk tolerance level.
struct RiskStepView: View {
    let state: PortfolioGeneratorState

    @State private var isAppeared = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm + Spacing.md)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.top, Spacing.lg)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 16)

                    riskGauge
                        .padding(.top, Spacing.xxl)
                        .padding(.horizontal, Spacing.xs)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 18)

                    riskCards
                        .padding(.top, Spacing.xxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 22)
                }
            }
            .scrollIndicators(.hidden)

            Spacer(minLength: Spacing.lg)

            continueButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension RiskStepView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                state.back()
            }
        } label: {
            Image(systemName: "arrow.left")
                .font(.title3.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Go back")
    }

    // MARK: Header

    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("How much risk are you comfortable with?")
                    .font(.title2.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Higher risk can mean higher returns")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.lg)

            Image(systemName: "gauge.with.dots.needle.50percent")
                .font(.system(size: 36))
                .foregroundStyle(.blue.opacity(0.5))
                .accessibilityHidden(true)
        }
    }

    // MARK: Risk Gauge

    var riskGauge: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let indicatorPosition: CGFloat = if let risk = state.selectedRisk {
                width * risk.gaugePosition
            } else {
                width * 0.5
            }

            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 8)

                // Indicator
                if state.selectedRisk != nil {
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .fill(state.selectedRisk?.color ?? .clear)
                                .frame(width: 12, height: 12)
                        )
                        .offset(x: indicatorPosition - 12)
                        .animation(.springInteractive, value: state.selectedRisk)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            // Labels
            HStack {
                Text("Low")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(FondyColors.labelTertiary)
                Spacer()
                Text("High")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .offset(y: 20)
        }
        .frame(height: 44)
    }

    // MARK: Risk Cards

    var riskCards: some View {
        VStack(spacing: Spacing.md) {
            ForEach(PG.RiskTolerance.allCases) { risk in
                riskCard(for: risk)
            }
        }
    }

    func riskCard(for risk: PG.RiskTolerance) -> some View {
        let isSelected = state.selectedRisk == risk

        return Button {
            Haptics.selection()
            withAnimation(.springInteractive) {
                state.selectedRisk = risk
            }
        } label: {
            HStack(spacing: Spacing.lg) {
                // Color-coded icon circle
                Image(systemName: risk.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .liquidGlass(tint: risk.color, cornerRadius: 50)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(risk.title)
                        .font(.headline)
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text(risk.description)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(risk.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Spacing.lg)
            .background(
                isSelected ? risk.color.opacity(0.08) : FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? risk.color : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .animation(.springInteractive, value: isSelected)
    }

    // MARK: Continue Button

    var continueButton: some View {
        Button {
            Haptics.medium()
            withAnimation(.springGentle) {
                state.next()
            }
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .liquidGlass(tint: .blue, cornerRadius: 16, disabled: !state.canProceedFromRisk)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .disabled(!state.canProceedFromRisk)
        .animation(.springInteractive, value: state.canProceedFromRisk)
    }
}

// MARK: - Preview

#Preview {
    RiskStepView(state: PortfolioGeneratorState())
}

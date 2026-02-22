//
//  HorizonStepView.swift
//  Fondy
//
//  Investment horizon selection step with timeline visualization.
//

import SwiftUI

/// Asks the user to select their investment time horizon.
struct HorizonStepView: View {
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

                    timelineVisualization
                        .padding(.top, Spacing.xxxl)
                        .padding(.horizontal, Spacing.xxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 18)

                    horizonCards
                        .padding(.top, Spacing.xxxl)
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

private extension HorizonStepView {

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
                Text("How long do you plan to invest?")
                    .font(.title2.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Longer horizons allow for more growth")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.lg)

            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.system(size: 36))
                .foregroundStyle(.blue.opacity(0.5))
                .accessibilityHidden(true)
        }
    }

    // MARK: Timeline Visualization

    var timelineVisualization: some View {
        HStack(spacing: 0) {
            ForEach(Array(InvestmentHorizon.allCases.enumerated()), id: \.element.id) { index, horizon in
                let isAtOrBefore = isSelectedOrBefore(horizon)
                let isCurrent = state.selectedHorizon == horizon

                VStack(spacing: Spacing.sm) {
                    // Dot
                    ZStack {
                        Circle()
                            .fill(isAtOrBefore ? .blue : FondyColors.fillTertiary)
                            .frame(width: isCurrent ? 20 : 14, height: isCurrent ? 20 : 14)

                        if isCurrent {
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .animation(.springInteractive, value: state.selectedHorizon)

                    // Label
                    Text(horizon.title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(isCurrent ? .blue : FondyColors.labelSecondary)
                }
                .frame(maxWidth: .infinity)

                // Connecting line
                if index < InvestmentHorizon.allCases.count - 1 {
                    let nextHorizon = InvestmentHorizon.allCases[index + 1]
                    let lineFilled = isSelectedOrBefore(nextHorizon)

                    Rectangle()
                        .fill(lineFilled ? .blue : FondyColors.fillTertiary)
                        .frame(height: 3)
                        .offset(y: -10)
                        .animation(.springInteractive, value: state.selectedHorizon)
                }
            }
        }
    }

    func isSelectedOrBefore(_ horizon: InvestmentHorizon) -> Bool {
        guard let selected = state.selectedHorizon else { return false }
        let allCases = InvestmentHorizon.allCases
        guard let selectedIdx = allCases.firstIndex(of: selected),
              let horizonIdx = allCases.firstIndex(of: horizon) else { return false }
        return horizonIdx <= selectedIdx
    }

    // MARK: Horizon Cards

    var horizonCards: some View {
        VStack(spacing: Spacing.md) {
            ForEach(InvestmentHorizon.allCases) { horizon in
                horizonCard(for: horizon)
            }
        }
    }

    func horizonCard(for horizon: InvestmentHorizon) -> some View {
        let isSelected = state.selectedHorizon == horizon

        return Button {
            Haptics.selection()
            withAnimation(.springInteractive) {
                state.selectedHorizon = horizon
            }
        } label: {
            HStack(spacing: Spacing.lg) {
                Image(systemName: horizon.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.blue, in: Circle())

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(horizon.title)
                        .font(.headline)
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text(horizon.subtitle)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Spacing.lg)
            .background(
                isSelected ? Color.blue.opacity(0.08) : FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? Color.blue : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
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
                .background(
                    state.canProceedFromHorizon ? .blue : .blue.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!state.canProceedFromHorizon)
        .animation(.springInteractive, value: state.canProceedFromHorizon)
    }
}

// MARK: - Preview

#Preview {
    HorizonStepView(state: PortfolioGeneratorState())
}

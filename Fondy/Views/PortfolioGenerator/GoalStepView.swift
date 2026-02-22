//
//  GoalStepView.swift
//  Fondy
//
//  Investment goal selection step with 4 single-select cards.
//

import SwiftUI

/// Asks the user to select their primary investment goal.
struct GoalStepView: View {
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

                    goalCards
                        .padding(.top, Spacing.xxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 20)
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

private extension GoalStepView {

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
                Text("What's your primary investment goal?")
                    .font(.title2.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("This helps us tailor your portfolio")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.lg)

            Image(systemName: "target")
                .font(.system(size: 36))
                .foregroundStyle(.blue.opacity(0.5))
                .symbolEffect(.pulse, options: .repeat(1), value: isAppeared)
                .accessibilityHidden(true)
        }
    }

    // MARK: Goal Cards

    var goalCards: some View {
        VStack(spacing: Spacing.md) {
            ForEach(InvestmentGoal.allCases) { goal in
                selectionCard(for: goal)
            }
        }
    }

    func selectionCard(for goal: InvestmentGoal) -> some View {
        let isSelected = state.selectedGoal == goal

        return Button {
            Haptics.selection()
            withAnimation(.springInteractive) {
                state.selectedGoal = goal
            }
        } label: {
            HStack(spacing: Spacing.lg) {
                // Icon circle
                Image(systemName: goal.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.blue, in: Circle())

                // Text
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .symbolEffect(.bounce, value: isSelected)
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
                    state.canProceedFromGoal ? .blue : .blue.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!state.canProceedFromGoal)
        .animation(.springInteractive, value: state.canProceedFromGoal)
    }
}

// MARK: - Preview

#Preview {
    GoalStepView(state: PortfolioGeneratorState())
}

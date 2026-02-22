//
//  PortfolioGeneratorContainerView.swift
//  Fondy
//
//  Top-level router for the AI portfolio generation questionnaire flow.
//  Switches between steps with slide transitions.
//

import SwiftUI

/// Routes between portfolio generator steps with animated transitions.
struct PortfolioGeneratorContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var generatorState = PortfolioGeneratorState()

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            // Step content
            Group {
                switch generatorState.step {
                case .welcome:
                    WelcomeStepView(state: generatorState, onDismiss: { dismiss() })
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .goal:
                    GoalStepView(state: generatorState)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .risk:
                    RiskStepView(state: generatorState)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .horizon:
                    HorizonStepView(state: generatorState)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .amount:
                    AmountStepView(state: generatorState)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .sectors:
                    SectorsStepView(state: generatorState)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .generating, .result:
                    GeneratingPortfolioView(state: generatorState, onDismiss: { dismiss() })
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }

            // Progress bar overlay
            if generatorState.showsProgressBar {
                StepProgressBar(
                    totalSteps: generatorState.totalSteps,
                    currentStep: generatorState.currentStepIndex
                )
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.xs)
                .transition(.opacity)
            }
        }
        .animation(.springGentle, value: generatorState.step)
    }
}

// MARK: - Preview

#Preview {
    PortfolioGeneratorContainerView()
}

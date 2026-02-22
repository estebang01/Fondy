//
//  StepProgressBar.swift
//  Fondy
//
//  Segmented capsule progress bar for multi-step flows.
//

import SwiftUI

/// Horizontal segmented progress bar showing current step in a multi-step flow.
struct StepProgressBar: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.blue : FondyColors.fillTertiary)
                    .frame(height: 4)
            }
        }
        .animation(.springGentle, value: currentStep)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xxl) {
        StepProgressBar(totalSteps: 5, currentStep: 0)
        StepProgressBar(totalSteps: 5, currentStep: 2)
        StepProgressBar(totalSteps: 5, currentStep: 4)
    }
    .padding(.horizontal, Spacing.pageMargin)
}

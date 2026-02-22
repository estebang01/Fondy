//
//  TransactionEmptyState.swift
//  Fondy
//
//  Reusable empty state view for transaction lists.
//

import SwiftUI

struct TransactionEmptyState: View {
    var iconName: String = "arrow.down.circle"
    var message: String = "No transactions yet"
    var subMessage: String? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: iconName)
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(FondyColors.labelTertiary)
                .frame(width: 64, height: 64)
                .background(FondyColors.fillQuaternary, in: Circle())
                .accessibilityHidden(true)

            VStack(spacing: Spacing.xs) {
                Text(message)
                    .font(.body.weight(.medium))
                    .foregroundStyle(FondyColors.labelSecondary)
                    .multilineTextAlignment(.center)

                if let subMessage {
                    Text(subMessage)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.vertical, Spacing.xxl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel([message, subMessage].compactMap { $0 }.joined(separator: ". "))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xxl) {
        TransactionEmptyState()
        TransactionEmptyState(
            iconName: "magnifyingglass",
            message: "No results found",
            subMessage: "Try adjusting your search or filters."
        )
    }
    .padding(.horizontal, Spacing.pageMargin)
    .background(Color(.systemGroupedBackground))
}

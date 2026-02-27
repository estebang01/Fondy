//
//  SimpleActionSheet.swift
//  Fondy
//
//  A lightweight "coming soon" bottom sheet used as a placeholder
//  for dashboard action flows (Add money, Send, More options).
//

import SwiftUI

struct SimpleActionSheet: View {
    let title: String
    let iconName: String
    let description: String
    let accentColor: Color

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xl)

            // Icon
            Image(systemName: iconName)
                .font(.system(size: 52))
                .foregroundStyle(accentColor)
                .padding(.bottom, Spacing.lg)
                .accessibilityHidden(true)

            // Title
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .padding(.bottom, Spacing.sm)

            // Description
            Text(description)
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxxl)

            // Coming soon pill
            Text("Coming soon")
                .font(.footnote.weight(.medium))
                .foregroundStyle(accentColor)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(accentColor.opacity(0.12), in: Capsule())
                .padding(.bottom, Spacing.xl)

            // Close button
            Button {
                Haptics.light()
                dismiss()
            } label: {
                Text("Close")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md + 2)
                    .liquidGlass(cornerRadius: 50)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(FondyColors.background)
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
    }
}

// MARK: - Preview

#Preview {
    SimpleActionSheet(
        title: "Add money",
        iconName: "plus.circle.fill",
        description: "Top up your Fondy account via bank transfer, card, or crypto.",
        accentColor: .blue
    )
}

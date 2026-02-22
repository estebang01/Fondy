//
//  DismissableBanner.swift
//  Fondy
//
//  Reusable dismissable info banner with icon, title, description, and close button.
//

import SwiftUI

struct DismissableBanner: View {
    let iconName: String
    var iconColor: Color = .blue
    let title: String
    let description: String
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(alignment: .top, spacing: Spacing.md) {
                iconView
                textColumn
                Spacer(minLength: Spacing.sm)
                dismissButton
            }
            .padding(Spacing.md)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            // Slide down from top + fade — cleaner than sliding from trailing
            .transition(.move(edge: .top).combined(with: .opacity))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(description)")
            .accessibilityAction(named: "Dismiss") { dismiss() }
        }
    }

    private func dismiss() {
        Haptics.light()
        withAnimation(.springGentle) { isVisible = false }
    }
}

private extension DismissableBanner {

    var iconView: some View {
        Image(systemName: iconName)
            .font(.body.weight(.semibold))
            .foregroundStyle(iconColor)
            .frame(width: 36, height: 36)
            .background(iconColor.opacity(0.12), in: Circle())
            .accessibilityHidden(true)
    }

    var textColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .lineLimit(2)
            Text(description)
                .font(.caption)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var dismissButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(FondyColors.labelTertiary)
                // 28×28 tappable area — large enough without being intrusive
                .frame(width: 28, height: 28)
                .background(FondyColors.fillQuaternary, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var visible = true
    VStack {
        DismissableBanner(
            iconName: "exclamationmark.triangle.fill",
            iconColor: .orange,
            title: "Action required",
            description: "Complete identity verification to unlock higher limits.",
            isVisible: $visible
        )
        Spacer()
    }
    .padding(.horizontal, Spacing.pageMargin)
    .padding(.top, Spacing.lg)
}

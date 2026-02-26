//
//  WatchlistIntroSheet.swift
//  Fondy
//
//  Introductory modal sheet explaining the watchlist feature.
//  Shown the first time the user taps "+ Add" or "See all" on an empty watchlist.
//

import SwiftUI

/// Intro sheet explaining what a watchlist is.
/// After tapping "Got it", the parent navigates to WatchlistView.
struct WatchlistIntroSheet: View {
    @Environment(\.dismiss) private var dismiss
    /// Set to `true` when the user taps "Got it" (vs. dismissing with ×).
    @Binding var didTapGotIt: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            closeButton
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)

            Text("Create a watchlist")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .padding(.bottom, Spacing.md)

            Text("The purpose of the watchlist is to provide you with the functionality to select specific stocks from the full list of our offering for easy access.")
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, Spacing.md)

            Text("Capital at risk")
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer()

            WatchlistChartIllustration()
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .accessibilityHidden(true)

            Spacer()

            gotItButton
                .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Subviews

private extension WatchlistIntroSheet {

    var closeButton: some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .frame(width: 30, height: 30)
                .liquidGlass(cornerRadius: 12)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Dismiss")
    }

    var gotItButton: some View {
        Button {
            Haptics.medium()
            didTapGotIt = true
            dismiss()
        } label: {
            Text("Got it")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md + 2)
                .liquidGlass(tint: .blue, cornerRadius: 50)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Got it, proceed to create watchlist")
    }
}

// MARK: - Bar Chart Illustration

private struct WatchlistChartIllustration: View {

    var body: some View {
        ZStack(alignment: .bottom) {
            // Bar chart — lifted above coin stack
            HStack(alignment: .bottom, spacing: 14) {
                bar(height: 68,  color: Color(.systemGray5))
                bar(height: 96,  color: Color(.systemGray4))
                bar(height: 166, color: .blue)
                bar(height: 132, color: Color(red: 0.42, green: 0.62, blue: 1.0))
            }
            .offset(y: -32)

            // Coin stack
            coinStack
        }
    }

    // MARK: - Helpers

    private func bar(height: CGFloat, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(color)
            .frame(width: 48, height: height)
    }

    private var coinStack: some View {
        ZStack {
            Ellipse()
                .fill(Color(.systemGray3))
                .frame(width: 162, height: 20)
                .offset(y: 10)

            Ellipse()
                .fill(Color(.systemGray4))
                .frame(width: 154, height: 18)

            Ellipse()
                .fill(Color(.systemGray5))
                .frame(width: 148, height: 16)
                .offset(y: -10)
        }
        .frame(height: 40)
    }
}

// MARK: - Preview

#Preview {
    WatchlistIntroSheet(didTapGotIt: .constant(false))
}

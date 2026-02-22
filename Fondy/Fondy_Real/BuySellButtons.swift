import SwiftUI

//
//  BuySellButtons.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 21/02/26.
//

/// A reusable Buy/Sell bar. If you already have this as an extension on a parent view,
/// you can move the `buySellBar` computed property back there and remove this struct.
struct BuySellButtons: View {
    // Placeholder dependencies to make this file compile.
    // Replace these with your actual bindings/values from the parent view.
    var stockTicker: String
    @Binding var showBuySheet: Bool
    @Binding var showSellSheet: Bool

    var body: some View {
        buySellBar
    }

    private var buySellBar: some View {
        HStack(spacing: Spacing.md) {
            Button {
                Haptics.medium()
                showBuySheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Buy")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md + 2)
                .background(.blue, in: Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("Buy \(stockTicker)")

            Button {
                Haptics.light()
                showSellSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Sell")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(FondyColors.labelTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md + 2)
                .background(FondyColors.fillTertiary, in: Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel("Sell \(stockTicker)")
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.vertical, Spacing.md)
        .background(
            Color(.systemGroupedBackground)
                .overlay(alignment: .top) { Divider() }
        )
    }
}
#Preview {
    @Previewable @State var showBuy = false
    @Previewable @State var showSell = false
    return BuySellButtons(stockTicker: "AAPL", showBuySheet: $showBuy, showSellSheet: $showSell)
}


//
//  SwipeToDeleteCard.swift
//  Fondy
//
//  Rounded card with swipe-left-to-reveal three circular action buttons:
//  Info (gray)  ·  Remind (blue)  ·  Delete (red)
//
//  Drag past deleteThreshold or flick fast → auto-commits delete.
//  Drag to snap zone → holds open showing all three actions.
//  Tap any revealed action → executes that action and snaps closed.
//

import SwiftUI

struct SwipeToDeleteCard<Content: View>: View {

    // MARK: - Callbacks

    var onInfo: (() -> Void)? = nil
    var onRemind: (() -> Void)? = nil
    let onDelete: () -> Void

    @ViewBuilder let content: () -> Content

    // MARK: - Swipe State

    @State private var dragOffset: CGFloat = 0
    @State private var isDeleting = false

    // MARK: - Layout Constants

    private let buttonSize: CGFloat   = 54
    private let buttonSpacing: CGFloat = 10
    private let trailingPad: CGFloat  = 14

    /// Width of the full revealed action panel.
    private var panelWidth: CGFloat {
        let count = CGFloat(visibleButtonCount)
        return count * buttonSize + max(0, count - 1) * buttonSpacing + trailingPad
    }

    private var visibleButtonCount: Int {
        (onInfo != nil ? 1 : 0) + (onRemind != nil ? 1 : 0) + 1
    }

    /// Threshold past which a release auto-commits delete.
    private var deleteThreshold: CGFloat { panelWidth + 80 }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .trailing) {
            actionButtons
            cardForeground
        }
        .frame(height: isDeleting ? 0 : nil)
        .clipped()
        .animation(.spring(response: 0.3, dampingFraction: 0.88), value: isDeleting)
    }

    // MARK: - Action Buttons

    /// Three circular buttons that sit in the trailing zone revealed by the sliding card.
    private var actionButtons: some View {
        HStack(spacing: buttonSpacing) {
            if let onInfo {
                circleButton(
                    icon: "info.circle.fill",
                    color: Color(.systemGray3),
                    revealIndex: 2    // last to appear
                ) {
                    snapClosed()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onInfo() }
                }
            }

            if let onRemind {
                circleButton(
                    icon: "bell.fill",
                    color: .blue,
                    revealIndex: 1
                ) {
                    snapClosed()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onRemind() }
                }
            }

            circleButton(
                icon: "trash.fill",
                color: .red,
                revealIndex: 0    // first to appear
            ) {
                commitDelete()
            }
        }
        .padding(.trailing, trailingPad)
    }

    private func circleButton(
        icon: String,
        color: Color,
        revealIndex: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: buttonSize, height: buttonSize)
                    // Pulse up when dragged past delete threshold
                    .scaleEffect(dragOffset < -deleteThreshold ? 1.12 : 1.0)
                    .animation(.springInteractive, value: dragOffset < -deleteThreshold)

                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        // Staggered cascade reveal — rightmost (revealIndex 0) appears first
        .scaleEffect(cascadeScale(revealIndex: revealIndex))
        .opacity(cascadeOpacity(revealIndex: revealIndex))
        .animation(.springInteractive, value: dragOffset)
        .accessibilityLabel(icon == "info.circle.fill" ? "Info" : icon == "bell.fill" ? "Set reminder" : "Delete")
    }

    // MARK: - Cascade Animation

    /// Each button starts appearing `30pt` of drag apart, creating a left-to-right cascade.
    private func cascadeScale(revealIndex: Int) -> CGFloat {
        let dragStart = CGFloat(revealIndex) * 28
        let progress  = max(0, min(1, (-dragOffset - dragStart) / 52))
        return 0.45 + 0.55 * progress
    }

    private func cascadeOpacity(revealIndex: Int) -> Double {
        let dragStart = CGFloat(revealIndex) * 28
        let progress  = max(0, min(1, (-dragOffset - dragStart) / 42))
        return Double(progress)
    }

    // MARK: - Card Foreground

    private var cardForeground: some View {
        content()
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .offset(x: dragOffset)
            .contentShape(Rectangle())
            .highPriorityGesture(swipeGesture)
    }

    // MARK: - Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                guard value.translation.width < 0 else {
                    dragOffset = 0
                    return
                }
                let raw = value.translation.width
                if raw < -panelWidth {
                    // Rubber-band past the panel edge
                    let overshoot = (-raw - panelWidth)
                    dragOffset = -(panelWidth + overshoot * 0.28)
                } else {
                    dragOffset = raw
                }
            }
            .onEnded { value in
                let velocity   = value.predictedEndTranslation.width - value.translation.width
                let pastDelete = dragOffset < -deleteThreshold
                let fastFlick  = velocity < -240

                if pastDelete || fastFlick {
                    commitDelete()
                } else if dragOffset < -(panelWidth / 2) {
                    // Snap open — show all buttons
                    withAnimation(.springInteractive) { dragOffset = -panelWidth }
                } else {
                    snapClosed()
                }
            }
    }

    // MARK: - Actions

    private func snapClosed() {
        withAnimation(.springInteractive) { dragOffset = 0 }
    }

    private func commitDelete() {
        Haptics.medium()
        withAnimation(.spring(response: 0.24, dampingFraction: 0.9)) {
            isDeleting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            onDelete()
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var stocks = [
        WatchlistStock(id: UUID(), name: "Apple",    ticker: "AAPL", logoSystemName: "apple.logo",  logoColor: .white,  price: 213.49, changePercent:  1.23, currencySymbol: "$"),
        WatchlistStock(id: UUID(), name: "Tesla",    ticker: "TSLA", logoSystemName: "car.fill",    logoColor: .red,    price: 247.10, changePercent: -0.87, currencySymbol: "$"),
        WatchlistStock(id: UUID(), name: "Alphabet", ticker: "GOOGL", logoSystemName: "g.circle",   logoColor: .blue,   price: 171.58, changePercent:  0.42, currencySymbol: "$"),
    ]

    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(stocks) { stock in
                SwipeToDeleteCard(
                    onInfo: {
                        print("Info: \(stock.name)")
                    },
                    onRemind: {
                        print("Remind: \(stock.name)")
                    },
                    onDelete: {
                        withAnimation(.springGentle) {
                            stocks.removeAll { $0.id == stock.id }
                        }
                    }
                ) {
                    WatchlistStockRow(stock: stock)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                }
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.lg)
    }
    .background(Color(.systemGroupedBackground))
}

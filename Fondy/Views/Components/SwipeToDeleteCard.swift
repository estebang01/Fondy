//
//  SwipeToDeleteCard.swift
//  Fondy
//
//  White rounded card with Apple-style swipe-to-delete:
//  drag left → red trash reveal → release past threshold → delete.
//

import SwiftUI

/// A white rounded card wrapper that supports swipe-left-to-delete,
/// matching the system List swipe action behaviour.
///
/// Usage:
/// ```swift
/// SwipeToDeleteCard(onDelete: { viewModel.remove(item) }) {
///     MyRowView(item: item)
/// }
/// ```
struct SwipeToDeleteCard<Content: View>: View {

    // MARK: - Configuration

    /// Called after the delete animation completes.
    let onDelete: () -> Void
    /// The card content.
    @ViewBuilder let content: () -> Content

    // MARK: - Swipe State

    /// Current horizontal drag translation (clamped to leading direction only).
    @State private var dragOffset: CGFloat = 0
    /// Whether the card has been committed to deletion (plays collapse animation).
    @State private var isDeleting = false

    // MARK: - Constants

    /// Width of the revealed trash action area.
    private let actionWidth: CGFloat = 80
    /// How far the user must drag to trigger auto-complete.
    private let deleteThreshold: CGFloat = 100

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteBackground
            cardForeground
        }
        .frame(height: isDeleting ? 0 : nil)
        .opacity(isDeleting ? 0 : 1)
    }

    // MARK: - Delete Background

    /// Red background with trash icon — revealed as the card slides left.
    private var deleteBackground: some View {
        Button {
            commitDelete()
        } label: {
            HStack {
                Spacer()
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    // Scale up slightly once threshold is crossed
                    .scaleEffect(dragOffset < -deleteThreshold ? 1.15 : 1.0)
                    .animation(.springInteractive, value: dragOffset < -deleteThreshold)
                    .frame(width: actionWidth)
            }
        }
        .buttonStyle(.plain)
        .frame(maxHeight: .infinity)
        .background(Color.red, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        // Reveal only as wide as the drag allows
        .frame(width: max(0, -dragOffset))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel("Delete")
    }

    // MARK: - Card Foreground

    /// The actual white rounded card that slides left.
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
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                // Only allow leftward drags
                guard value.translation.width < 0 else {
                    dragOffset = 0
                    return
                }
                // Apply rubber-banding past the action width
                let raw = value.translation.width
                if raw < -actionWidth {
                    let overshoot = (-raw - actionWidth)
                    dragOffset = -(actionWidth + overshoot * 0.3)
                } else {
                    dragOffset = raw
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.width - value.translation.width
                let pastThreshold = dragOffset < -deleteThreshold
                let fastSwipe = velocity < -200

                if pastThreshold || fastSwipe {
                    commitDelete()
                } else if dragOffset < -(actionWidth / 2) {
                    // Snap open to show action button
                    withAnimation(.springInteractive) { dragOffset = -actionWidth }
                } else {
                    // Snap closed
                    withAnimation(.springInteractive) { dragOffset = 0 }
                }
            }
    }

    // MARK: - Delete Action

    private func commitDelete() {
        Haptics.medium()
        // Fade out the card content first to minimize layout shifts
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            dragOffset = -actionWidth
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            isDeleting = true
        }
        // Perform model mutation without implicit animations to avoid parent relayout animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            onDelete()
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var items = HomeAccountViewModel.mockActionItems

    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(items) { item in
                SwipeToDeleteCard(onDelete: {
                    withAnimation(.springGentle) {
                        items.removeAll { $0.id == item.id }
                    }
                }) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: item.iconName)
                            .foregroundStyle(item.iconColor)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            if let subtitle = item.subtitle {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(item.subtitleColor ?? .secondary)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            if let amount = item.trailingAmount {
                                Text(amount)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }
                            if let status = item.trailingStatus {
                                Text(status)
                                    .font(.caption)
                                    .foregroundStyle(item.trailingStatusColor ?? .secondary)
                            }
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.lg)
    }
    .background(Color(.systemGroupedBackground))
}

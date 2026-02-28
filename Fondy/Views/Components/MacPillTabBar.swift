//
//  MacPillTabBar.swift
//  Fondy
//
//  macOS-style floating pill tab bar with an AI chat launcher.
//
//  Layout:
//  ┌──────────────────────────────────────────┐   ╭────╮
//  │  ╭──────╮  ─────  ─────  ─────  ─────   │   │ ✦  │
//  │  │  ⌂   │   ⇄     ⊞     ≡    👤        │   ╰────╯
//  │  │ Home │  Pay   Hub  Charts Profile     │  Fondy AI
//  │  ╰──────╯                                │
//  └──────────────────────────────────────────┘
//
//  • Selected tab:    white capsule bg + blue icon & label.
//  • Unselected tabs: no background, secondary-label tint.
//  • Trailing AI button: aurora-glow circle → opens ChatView as a full-screen sheet.
//

import SwiftUI

// MARK: - MacPillTabBar

struct MacPillTabBar: View {
    @Binding var selected: AppTab

    @State private var showAIChat = false
    @State private var chatViewModel = ChatViewModel()
    @Namespace private var selectionNS

    var body: some View {
        HStack(spacing: Spacing.sm) {
            pillContainer
            aiButton
        }
        .padding(.horizontal, Spacing.pageMargin)
        .sheet(isPresented: $showAIChat) {
            AIChatSheet(viewModel: chatViewModel)
        }
    }

    // MARK: - Pill container

    private var pillContainer: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabItem(tab)
            }
        }
        .padding(Spacing.xs)
        .background(FondyColors.fillQuaternary, in: Capsule())
    }

    // MARK: - Tab item

    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = selected == tab

        return Button {
            guard selected != tab else { return }
            Haptics.selection()
            withAnimation(.springInteractive) { selected = tab }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                    .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isSelected)

                Text(tab.shortTitle)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.blue : FondyColors.labelSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm + 2)
            .padding(.horizontal, Spacing.xs)
            .background {
                if isSelected {
                    Capsule()
                        .fill(FondyColors.background)
                        .shadow(color: .black.opacity(0.10), radius: 8, y: 3)
                        .matchedGeometryEffect(id: "mac_pill_selection", in: selectionNS)
                }
            }
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    // MARK: - AI button

    private var aiButton: some View {
        Button {
            Haptics.medium()
            showAIChat = true
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.35, blue: 1.0),
                                Color(red: 0.25, green: 0.60, blue: 1.0),
                                Color(red: 0.65, green: 0.30, blue: 0.90)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color(red: 0.45, green: 0.35, blue: 1.0).opacity(0.45),
                        radius: 10,
                        y: 4
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .frame(width: 56, height: 56)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Fondy AI — ask anything about your portfolio")
    }
}

// MARK: - AppTab extensions for MacPillTabBar

extension AppTab {
    /// Compact label shown under each icon in the pill bar.
    var shortTitle: String {
        switch self {
        case .home:      "Home"
        case .transfers: "Pay"
        case .hub:       "Hub"
        case .analytics: "Charts"
        case .profile:   "Profile"
        }
    }

    /// Filled (selected-state) icon variant for visual weight.
    var selectedIconName: String {
        switch self {
        case .home:      "house.fill"
        case .transfers: "arrow.left.arrow.right.circle.fill"
        case .hub:       "square.grid.2x2.fill"
        case .analytics: "chart.bar.fill"
        case .profile:   "person.fill"
        }
    }
}

// MARK: - AI Chat Sheet

/// Full-screen sheet wrapper around ChatView, adding navigation chrome:
/// a branded title + close button. ChatView itself stays self-contained.
private struct AIChatSheet: View {
    @Bindable var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ChatView(viewModel: viewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) { navTitle }
                    ToolbarItem(placement: .topBarTrailing) { closeButton }
                }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    // MARK: Branded nav title

    private var navTitle: some View {
        HStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.35, blue: 1.0),
                                Color(red: 0.25, green: 0.60, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 26, height: 26)

                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            Text("Fondy AI")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)
        }
    }

    // MARK: Close button

    private var closeButton: some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .frame(width: 32, height: 32)
                .liquidGlass(cornerRadius: 10)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Close AI chat")
    }
}

// MARK: - Previews

#Preview("Tab bar") {
    @Previewable @State var tab: AppTab = .home

    VStack {
        Spacer()
        MacPillTabBar(selected: $tab)
            .padding(.bottom, Spacing.xxxl)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}

#Preview("AI sheet") {
    AIChatSheet(viewModel: ChatViewModel())
}

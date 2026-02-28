//
//  ContentView.swift
//  Fondy
//
//  Root view shown to authenticated users.
//  Houses the bottom tab bar and routes to top-level screens.
//

import SwiftUI

/// Root authenticated view with a custom bottom tab bar.
///
/// Owns the shared `HomeAccountViewModel` and switches between
/// top-level tabs (Home, Transfers, Hub, Analytics, Profile).
struct ContentView: View {
    let authState: AuthState

    @State private var homeViewModel = HomeAccountViewModel.createMock()
    @State private var selectedTab: AppTab = .home

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .animation(.springGentle, value: selectedTab)

            bottomTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeAccountView(viewModel: homeViewModel)
        case .transfers:
            transfersPlaceholder
        case .hub:
            hubPlaceholder
        case .analytics:
            analyticsPlaceholder
        case .profile:
            ProfileView(authState: authState)
        }
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        MacPillTabBar(selected: $selectedTab)
            .padding(.bottom, Spacing.xl)
    }

    // MARK: - Placeholder Tabs

    private var transfersPlaceholder: some View {
        placeholderScreen(icon: "arrow.left.arrow.right", title: "Transfers")
    }

    private var hubPlaceholder: some View {
        placeholderScreen(icon: "square.grid.2x2", title: "Hub")
    }

    private var analyticsPlaceholder: some View {
        placeholderScreen(icon: "chart.bar.fill", title: "Analytics")
    }

    private func placeholderScreen(icon: String, title: String) -> some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(FondyColors.labelTertiary)
                .accessibilityHidden(true)
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Preview

#Preview {
    ContentView(authState: {
        let state = AuthState()
        state.isAuthenticated = true
        return state
    }())
}

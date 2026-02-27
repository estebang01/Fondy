//
//  SettingsRootView.swift
//  Fondy — Settings Module
//
//  Drop-in settings root. Embed anywhere:
//
//      SettingsRootView()
//
//  Or inject real services:
//
//      SettingsRootView(
//          store: MySettingsStore(),
//          auth: MyAuthService(),
//          telemetry: MyTelemetryService()
//      )
//
//  Apply the selected theme at the app root:
//
//      .preferredColorScheme(store.appTheme.colorScheme)
//

import SwiftUI

struct SettingsRootView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    init(
        store: any SettingsStoreProtocol = MockSettingsStore(),
        auth: any SettingsAuthServiceProtocol = MockSettingsAuthService(),
        telemetry: any TelemetryServiceProtocol = MockTelemetryService()
    ) {
        _viewModel = State(initialValue: SettingsViewModel(store: store, auth: auth, telemetry: telemetry))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                if viewModel.isSearchActive {
                    searchResultsList
                        .transition(.opacity)
                } else {
                    mainList
                        .transition(.opacity)
                }
            }
            .animation(.springGentle, value: viewModel.isSearchActive)
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search settings"
            )
            .navigationDestination(for: SettingsDestination.self) { destination in
                destinationView(destination)
            }
            .confirmationDialog(
                "Sign out of Fondy?",
                isPresented: $viewModel.showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) { viewModel.signOut() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need to sign back in to access your account.")
            }
        }
    }

    // MARK: - Main Scrollable List

    private var mainList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                accountHeaderCard
                accountCard
                preferencesCard
                privacyCard
                aboutCard
                Spacer(minLength: Spacing.xxxl)
                signOutButton
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.searchResults.isEmpty {
                    emptySearchState
                } else {
                    SettingsCard {
                        ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, item in
                            if index > 0 { SettingsDivider() }
                            SettingsNavRow(
                                icon: item.icon,
                                iconColor: .blue,
                                title: item.title,
                                value: item.section
                            ) {
                                viewModel.navigate(to: item.destination)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.top, Spacing.md)
                }
            }
            .padding(.bottom, Spacing.xxxl)
        }
        .scrollIndicators(.hidden)
    }

    private var emptySearchState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(FondyColors.labelTertiary)
                .accessibilityHidden(true)
            Text("No results for "\(viewModel.searchText)"")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxl + Spacing.xxl)
    }

    // MARK: - Account Header (non-navigable identity pill)

    private var accountHeaderCard: some View {
        HStack(spacing: Spacing.md) {
            // Initials avatar
            Text(initials(from: viewModel.auth.displayName))
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color(.systemGray), in: Circle())
                .accessibilityLabel("Profile photo")

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(viewModel.auth.displayName)
                    .font(.headline)
                    .foregroundStyle(FondyColors.labelPrimary)
                Text(viewModel.auth.email)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer()
        }
        .padding(Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Signed in as \(viewModel.auth.displayName), \(viewModel.auth.email)")
    }

    // MARK: - Account Card

    private var accountCard: some View {
        SettingsCard(title: "Account") {
            SettingsNavRow(icon: "person.crop.circle", iconColor: .blue, title: "Edit Profile") {
                viewModel.navigate(to: .editProfile)
            }

            SettingsDivider()

            SettingsNavRow(icon: "lock", iconColor: .blue, title: "Change Password") {
                viewModel.navigate(to: .changePassword)
            }

            SettingsDivider()

            SettingsNavRow(
                icon: "iphone",
                iconColor: .blue,
                title: "Active Sessions",
                value: "\(viewModel.auth.activeSessions.count)"
            ) {
                viewModel.navigate(to: .activeSessions)
            }
        }
    }

    // MARK: - Preferences Card

    private var preferencesCard: some View {
        SettingsCard(title: "Preferences") {
            SettingsNavRow(
                icon: "circle.lefthalf.filled",
                iconColor: .blue,
                title: "Appearance",
                value: viewModel.store.appTheme.rawValue
            ) {
                viewModel.navigate(to: .appearance)
            }

            SettingsDivider()

            SettingsNavRow(
                icon: "bell",
                iconColor: .blue,
                title: "Notifications",
                value: viewModel.store.notificationCategories.filter { $0.isEnabled }.count == 0
                    ? "All off"
                    : "\(viewModel.store.notificationCategories.filter { $0.isEnabled }.count) on"
            ) {
                viewModel.navigate(to: .notifications)
            }
        }
    }

    // MARK: - Privacy Card

    private var privacyCard: some View {
        SettingsCard(title: "Privacy & Security") {
            SettingsNavRow(icon: "faceid", iconColor: .blue, title: "Biometrics & Screen Lock") {
                viewModel.navigate(to: .privacy)
            }

            SettingsDivider()

            SettingsNavRow(icon: "chart.bar", iconColor: .blue, title: "Analytics & Diagnostics") {
                viewModel.navigate(to: .privacy)
            }

            SettingsDivider()

            SettingsNavRow(icon: "square.and.arrow.up", iconColor: .blue, title: "Export My Data") {
                viewModel.navigate(to: .privacy)
            }
        }
    }

    // MARK: - About Card

    private var aboutCard: some View {
        SettingsCard(title: "About") {
            SettingsNavRow(
                icon: "info.circle",
                iconColor: .blue,
                title: "About Fondy",
                value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
            ) {
                viewModel.navigate(to: .about)
            }

            SettingsDivider()

            SettingsNavRow(icon: "doc.text", iconColor: .blue, title: "Open-Source Licenses") {
                viewModel.navigate(to: .licenses)
            }
        }
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        SettingsDestructiveButton(
            title: "Sign Out",
            isLoading: viewModel.isSigningOut
        ) {
            viewModel.showSignOutConfirmation = true
        }
    }

    // MARK: - Navigation Destinations

    @ViewBuilder
    private func destinationView(_ destination: SettingsDestination) -> some View {
        switch destination {
        case .account, .editProfile, .changePassword, .activeSessions:
            AccountSettingsView(auth: viewModel.auth)

        case .appearance:
            AppearanceSettingsView(store: viewModel.store)

        case .notifications:
            NotificationsSettingsView(store: viewModel.store)

        case .privacy:
            PrivacySettingsView(store: viewModel.store, telemetry: viewModel.telemetry)

        case .about:
            AboutSettingsView()

        case .licenses:
            LicensesView()
        }
    }

    // MARK: - Toolbar

    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Text("Settings")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.compactMap { $0.first }.prefix(2)
        return String(letters).uppercased()
    }
}

// MARK: - Preview

#Preview("Default") {
    SettingsRootView()
}

#Preview("With Navigation") {
    let vm = SettingsViewModel()
    SettingsRootView(
        store: vm.store,
        auth: vm.auth,
        telemetry: vm.telemetry
    )
}

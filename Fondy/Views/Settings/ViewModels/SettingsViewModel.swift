//
//  SettingsViewModel.swift
//  Fondy — Settings Module
//
//  Root ViewModel for the settings module. Owns dependencies and drives
//  navigation + search. All sub-VMs receive dependencies from here.
//

import SwiftUI

@Observable
final class SettingsViewModel {

    // MARK: - Dependencies (injected, shared with sub-VMs)

    let store: any SettingsStoreProtocol
    let auth: any SettingsAuthServiceProtocol
    let telemetry: any TelemetryServiceProtocol

    // MARK: - Navigation

    var navigationPath = NavigationPath()

    // MARK: - Search

    var searchText: String = ""

    // MARK: - Sign Out

    var isSigningOut: Bool = false
    var showSignOutConfirmation: Bool = false

    // MARK: - Init

    init(
        store: any SettingsStoreProtocol = MockSettingsStore(),
        auth: any SettingsAuthServiceProtocol = MockSettingsAuthService(),
        telemetry: any TelemetryServiceProtocol = MockTelemetryService()
    ) {
        self.store = store
        self.auth = auth
        self.telemetry = telemetry
    }

    // MARK: - Computed

    var isSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var searchResults: [SettingsSearchItem] {
        guard isSearchActive else { return [] }
        let query = searchText.lowercased()
        return SettingsSearchItem.all.filter {
            $0.title.lowercased().contains(query) || $0.section.lowercased().contains(query)
        }
    }

    // MARK: - Actions

    func navigate(to destination: SettingsDestination) {
        navigationPath.append(destination)
    }

    func signOut() {
        isSigningOut = true
        Task {
            await auth.signOut()
            await MainActor.run { isSigningOut = false }
        }
    }
}

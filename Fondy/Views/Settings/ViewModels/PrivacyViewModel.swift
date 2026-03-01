//
//  PrivacyViewModel.swift
//  Fondy — Settings Module
//

import SwiftUI

@Observable
final class PrivacyViewModel {

    private let store: any SettingsStoreProtocol
    private let telemetry: any TelemetryServiceProtocol

    var isExporting: Bool = false
    var exportComplete: Bool = false

    init(store: any SettingsStoreProtocol, telemetry: any TelemetryServiceProtocol) {
        self.store = store
        self.telemetry = telemetry
    }

    // MARK: - Pass-through Bindings

    var biometricsEnabled: Bool {
        get { store.biometricsEnabled }
        set { store.biometricsEnabled = newValue }
    }

    var screenLockEnabled: Bool {
        get { store.screenLockEnabled }
        set { store.screenLockEnabled = newValue }
    }

    var analyticsEnabled: Bool {
        get { store.analyticsEnabled }
        set {
            store.analyticsEnabled = newValue
            telemetry.setEnabled(newValue)
        }
    }

    var crashReportingEnabled: Bool {
        get { store.crashReportingEnabled }
        set { store.crashReportingEnabled = newValue }
    }

    // MARK: - Actions

    func exportData() {
        guard !isExporting else { return }
        isExporting = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                isExporting = false
                exportComplete = true
                Haptics.success()
            }
        }
    }
}

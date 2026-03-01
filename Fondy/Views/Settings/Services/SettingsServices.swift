//
//  SettingsServices.swift
//  Fondy — Settings Module
//
//  Protocol definitions and mock implementations for all settings services.
//  Swap mocks for real implementations via dependency injection at the call site.
//

import SwiftUI

// MARK: - Settings Store Protocol

/// Persists user preferences (theme, toggles, notifications).
protocol SettingsStoreProtocol: AnyObject {
    var appTheme: AppTheme { get set }
    var biometricsEnabled: Bool { get set }
    var screenLockEnabled: Bool { get set }
    var analyticsEnabled: Bool { get set }
    var crashReportingEnabled: Bool { get set }
    var notificationCategories: [NotificationCategory] { get set }
    func resetToDefaults()
}

// MARK: - Mock Settings Store

@Observable
final class MockSettingsStore: SettingsStoreProtocol {
    var appTheme: AppTheme = .system
    var biometricsEnabled: Bool = true
    var screenLockEnabled: Bool = true
    var analyticsEnabled: Bool = true
    var crashReportingEnabled: Bool = true
    var notificationCategories: [NotificationCategory] = [
        .init(id: "price_alerts",  title: "Price Alerts",       description: "Notify when assets hit your price targets",      isEnabled: true),
        .init(id: "portfolio",     title: "Portfolio Updates",   description: "Weekly performance summary and highlights",       isEnabled: true),
        .init(id: "market_news",   title: "Market News",         description: "Breaking news about your holdings",              isEnabled: false),
        .init(id: "transactions",  title: "Transactions",        description: "Confirmation for every trade you execute",        isEnabled: true),
        .init(id: "promotions",    title: "Promotions",          description: "Offers, tips, and new feature announcements",     isEnabled: false),
    ]

    func resetToDefaults() {
        appTheme = .system
        biometricsEnabled = false
        screenLockEnabled = false
        analyticsEnabled = false
        crashReportingEnabled = false
        notificationCategories = notificationCategories.map {
            var c = $0; c.isEnabled = false; return c
        }
    }
}

// MARK: - Settings Auth Service Protocol

/// Handles profile and session operations inside the settings module.
/// Intentionally separate from the app-level `AuthState` which manages login flow.
protocol SettingsAuthServiceProtocol: AnyObject {
    var displayName: String { get }
    var email: String { get }
    var activeSessions: [ActiveSession] { get }

    func updateProfile(name: String, email: String) async throws
    func changePassword(current: String, newPassword: String) async throws
    func revokeSession(_ session: ActiveSession) async throws
    func revokeAllOtherSessions() async throws
    func deleteAccount() async throws
    func signOut() async
}

// MARK: - Mock Settings Auth Service

@Observable
final class MockSettingsAuthService: SettingsAuthServiceProtocol {
    var displayName: String = "Alex Rivera"
    var email: String = "alex.rivera@example.com"
    var activeSessions: [ActiveSession] = [
        .init(id: UUID(), deviceName: "iPhone 16 Pro", location: "New York, US",  lastActive: Date(),                              isCurrent: true),
        .init(id: UUID(), deviceName: "MacBook Pro",   location: "New York, US",  lastActive: Date(timeIntervalSinceNow: -3600),  isCurrent: false),
        .init(id: UUID(), deviceName: "iPad Air",      location: "Brooklyn, US",  lastActive: Date(timeIntervalSinceNow: -86400 * 3), isCurrent: false),
    ]

    func updateProfile(name: String, email: String) async throws {
        try await Task.sleep(for: .seconds(1))
        displayName = name
        self.email = email
    }

    func changePassword(current: String, newPassword: String) async throws {
        try await Task.sleep(for: .seconds(1))
        guard current == "password" else {
            throw SettingsError.incorrectPassword
        }
    }

    func revokeSession(_ session: ActiveSession) async throws {
        try await Task.sleep(for: .milliseconds(600))
        activeSessions.removeAll { $0.id == session.id }
    }

    func revokeAllOtherSessions() async throws {
        try await Task.sleep(for: .seconds(1))
        activeSessions = activeSessions.filter { $0.isCurrent }
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(2))
    }

    func signOut() async {
        try? await Task.sleep(for: .milliseconds(500))
    }
}

// MARK: - Telemetry Service Protocol

protocol TelemetryServiceProtocol: AnyObject {
    func track(event: String, properties: [String: String])
    func setEnabled(_ enabled: Bool)
}

// MARK: - Mock Telemetry Service

final class MockTelemetryService: TelemetryServiceProtocol {
    func track(event: String, properties: [String: String]) {}
    func setEnabled(_ enabled: Bool) {}
}

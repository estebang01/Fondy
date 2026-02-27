//
//  SettingsModels.swift
//  Fondy — Settings Module
//
//  Pure data models for the settings module.
//  No SwiftUI dependencies so models remain testable in isolation.
//

import SwiftUI

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"

    var id: String { rawValue }

    /// Maps to SwiftUI's ColorScheme for `.preferredColorScheme()`.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon.stars"
        }
    }
}

// MARK: - Notification Category

struct NotificationCategory: Identifiable {
    let id: String
    let title: String
    let description: String
    var isEnabled: Bool
}

// MARK: - Active Session

struct ActiveSession: Identifiable {
    let id: UUID
    let deviceName: String
    let location: String
    let lastActive: Date
    var isCurrent: Bool

    var deviceIcon: String {
        let lower = deviceName.lowercased()
        if lower.contains("iphone") { return "iphone" }
        if lower.contains("ipad")   { return "ipad" }
        if lower.contains("mac")    { return "laptopcomputer" }
        return "desktopcomputer"
    }

    var lastActiveLabel: String {
        if isCurrent { return "Active now" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastActive, relativeTo: Date())
    }
}

// MARK: - Settings Navigation Destination

/// Type-safe navigation destinations for the settings module.
enum SettingsDestination: Hashable {
    case account
    case editProfile
    case changePassword
    case activeSessions
    case appearance
    case notifications
    case privacy
    case about
    case licenses
}

// MARK: - Settings Search Item

/// A flat, searchable representation of every settings entry.
struct SettingsSearchItem: Identifiable {
    let id: String
    let section: String
    let title: String
    let destination: SettingsDestination
    let icon: String

    static let all: [SettingsSearchItem] = [
        .init(id: "edit_profile",     section: "Account",       title: "Edit Profile",             destination: .editProfile,    icon: "person.crop.circle"),
        .init(id: "change_password",  section: "Account",       title: "Change Password",           destination: .changePassword, icon: "lock"),
        .init(id: "active_sessions",  section: "Account",       title: "Active Sessions",           destination: .activeSessions, icon: "iphone"),
        .init(id: "theme",            section: "Appearance",    title: "Theme",                     destination: .appearance,     icon: "circle.lefthalf.filled"),
        .init(id: "notifications",    section: "Notifications", title: "Notification Preferences",  destination: .notifications,  icon: "bell"),
        .init(id: "biometrics",       section: "Privacy",       title: "Face ID & Screen Lock",     destination: .privacy,        icon: "faceid"),
        .init(id: "analytics",        section: "Privacy",       title: "Analytics & Diagnostics",   destination: .privacy,        icon: "chart.bar"),
        .init(id: "data_export",      section: "Privacy",       title: "Export My Data",            destination: .privacy,        icon: "square.and.arrow.up"),
        .init(id: "about",            section: "About",         title: "About Fondy",               destination: .about,          icon: "info.circle"),
        .init(id: "licenses",         section: "About",         title: "Open-Source Licenses",      destination: .licenses,       icon: "doc.text"),
    ]
}

// MARK: - Settings Error

enum SettingsError: LocalizedError {
    case incorrectPassword
    case networkError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .incorrectPassword: return "Current password is incorrect. Please try again."
        case .networkError:      return "A network error occurred. Please try again."
        case .unknown(let e):    return e.localizedDescription
        }
    }
}

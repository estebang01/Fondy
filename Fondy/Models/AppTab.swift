//
//  AppTab.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import Foundation

/// Represents each tab in the app's bottom tab bar.
enum AppTab: String, CaseIterable, Identifiable {
    case home
    case transfers
    case hub
    case analytics
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .transfers: "Transfers"
        case .hub: "Hub"
        case .analytics: "Analytics"
        case .profile: "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .home: "house.fill"
        case .transfers: "arrow.left.arrow.right"
        case .hub: "square.grid.2x2"
        case .analytics: "chart.bar.fill"
        case .profile: "person"
        }
    }
}

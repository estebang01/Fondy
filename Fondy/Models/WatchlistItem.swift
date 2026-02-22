//
//  WatchlistItem.swift
//  Fondy
//

import SwiftUI

/// Represents an item in the watchlist (stocks, crypto, forex).
struct WatchlistItem: Identifiable {
    let id: UUID
    let name: String
    let value: String
    let iconName: String
    let iconBackground: Color
}

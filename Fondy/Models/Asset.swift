//
//  Asset.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI

/// Represents a single investment asset in the user's portfolio.
struct Asset: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let iconName: String
    let iconBackground: Color
    let investedAmount: Double
    let performancePercentage: Double

    /// Whether the asset's performance is positive.
    var isPositive: Bool {
        performancePercentage >= 0
    }
}

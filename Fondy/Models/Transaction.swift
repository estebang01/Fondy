//
//  Transaction.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import SwiftUI

/// Represents a single financial transaction.
struct Transaction: Identifiable {
    let id: UUID
    let name: String
    let iconName: String
    let iconBackground: Color
    let amount: Double
    let currencySymbol: String
    let time: String

    var isExpense: Bool {
        amount < 0
    }

    var formattedAmount: String {
        if isExpense {
            return "– \(currencySymbol)\(abs(amount).formatted(.number.precision(.fractionLength(0...2))))"
        }
        return "+ \(currencySymbol)\(amount.formatted(.number.precision(.fractionLength(0...2))))"
    }
}

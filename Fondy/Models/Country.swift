//
//  Country.swift
//  Fondy
//

import Foundation

/// A country with ISO code, name, and dial code for phone auth.
struct Country: Identifiable, Equatable, Hashable {
    let id: String       // ISO 2-letter code (e.g., "US")
    let name: String
    let dialCode: String

    /// Remote PNG flag URL from flagcdn.com.
    var flagURL: URL? {
        URL(string: "https://flagcdn.com/w80/\(id.lowercased()).png")
    }

    static let unitedStates  = Country(id: "US", name: "United States", dialCode: "+1")
    static let canada        = Country(id: "CA", name: "Canada", dialCode: "+1")
    static let mexico        = Country(id: "MX", name: "Mexico", dialCode: "+52")
    static let colombia      = Country(id: "CO", name: "Colombia", dialCode: "+57")
    static let spain         = Country(id: "ES", name: "Spain", dialCode: "+34")
    static let unitedKingdom = Country(id: "GB", name: "United Kingdom", dialCode: "+44")
    static let germany       = Country(id: "DE", name: "Germany", dialCode: "+49")
    static let france        = Country(id: "FR", name: "France", dialCode: "+33")
    static let brazil        = Country(id: "BR", name: "Brazil", dialCode: "+55")
    static let argentina     = Country(id: "AR", name: "Argentina", dialCode: "+54")
    static let singapore     = Country(id: "SG", name: "Singapore", dialCode: "+65")
    static let japan         = Country(id: "JP", name: "Japan", dialCode: "+81")
    static let india         = Country(id: "IN", name: "India", dialCode: "+91")

    /// All available countries sorted by name.
    static let all: [Country] = [
        .unitedStates, .canada, .mexico, .colombia, .argentina, .brazil,
        .spain, .france, .germany, .unitedKingdom, .singapore, .japan, .india
    ].sorted { $0.name < $1.name }
}

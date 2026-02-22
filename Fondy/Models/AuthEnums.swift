//
//  AuthEnums.swift
//  Fondy
//

import SwiftUI

/// Which auth screen is currently displayed.
enum AuthScreen {
    case login
    case signUp
    case phoneSignUp
}

/// Password strength indicator levels.
enum PasswordStrength {
    case none, weak, medium, strong

    var label: String {
        switch self {
        case .none: ""
        case .weak: "Weak"
        case .medium: "Fair"
        case .strong: "Strong"
        }
    }

    var color: Color {
        switch self {
        case .none: .clear
        case .weak: .red
        case .medium: .orange
        case .strong: .green
        }
    }

    var progress: Double {
        switch self {
        case .none: 0
        case .weak: 0.33
        case .medium: 0.66
        case .strong: 1.0
        }
    }
}

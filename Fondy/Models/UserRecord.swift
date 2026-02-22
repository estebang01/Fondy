//
//  UserRecord.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import Foundation

/// Represents a user record stored locally.
///
/// Lightweight struct used for authentication state.
/// When a paid developer account is available, this can be extended
/// to map to a CloudKit `CKRecord`.
struct UserRecord: Sendable, Codable, Equatable {
    let id: String
    let fullName: String
    let email: String
    let passwordHash: String
    let passwordSalt: String
    let createdAt: Date

    // MARK: - Create from Sign-Up Data

    /// Creates a new user from sign-up data (generates a new ID).
    init(fullName: String, email: String, passwordHash: String, passwordSalt: String) {
        self.id = UUID().uuidString
        self.fullName = fullName
        self.email = email.lowercased().trimmingCharacters(in: .whitespaces)
        self.passwordHash = passwordHash
        self.passwordSalt = passwordSalt
        self.createdAt = Date()
    }

    // MARK: - Full Initializer

    init(id: String, fullName: String, email: String, passwordHash: String, passwordSalt: String, createdAt: Date) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.passwordSalt = passwordSalt
        self.createdAt = createdAt
    }
}

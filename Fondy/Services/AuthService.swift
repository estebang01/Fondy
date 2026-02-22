//
//  AuthService.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import CryptoKit
import Foundation

// MARK: - Auth Error

/// Error types for authentication operations with Spanish localized messages.
enum AuthError: LocalizedError {
    case duplicateEmail
    case invalidCredentials
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .duplicateEmail:
            "An account with this email already exists"
        case .invalidCredentials:
            "Incorrect email or password"
        case .networkError:
            "Connection error. Please try again."
        case .unknown(let detail):
            "Something went wrong: \(detail)"
        }
    }
}

// MARK: - Auth Service

/// Handles local authentication: sign-up, login, and session management.
///
/// Uses UserDefaults to store user records locally with hashed passwords.
/// Passwords are hashed using SHA-256 with unique per-user salts via CryptoKit.
///
/// - Note: When a paid Apple Developer account is available, this can be
///   swapped back to the CloudKit-based implementation.
final class AuthService: Sendable {

    // MARK: - Storage Keys

    private let sessionKey = "fondy.auth.userRecordID"
    private let usersKey = "fondy.auth.users"

    // MARK: - Sign Up

    /// Creates a new user account stored locally.
    ///
    /// - Parameters:
    ///   - fullName: User's full name.
    ///   - email: User's email (normalized to lowercase).
    ///   - password: Plain-text password (hashed before storage).
    /// - Returns: The created `UserRecord`.
    func signUp(fullName: String, email: String, password: String) async throws -> UserRecord {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)

        // 1. Check for duplicate email
        let existingUsers = loadUsers()
        if existingUsers.contains(where: { $0.email == normalizedEmail }) {
            throw AuthError.duplicateEmail
        }

        // 2. Hash password with a fresh salt
        let salt = generateSalt()
        let hash = hashPassword(password, salt: salt)

        // 3. Build and save the record
        let user = UserRecord(
            fullName: fullName.trimmingCharacters(in: .whitespaces),
            email: normalizedEmail,
            passwordHash: hash,
            passwordSalt: salt
        )

        var users = existingUsers
        users.append(user)
        saveUsers(users)
        saveSession(id: user.id)

        return user
    }

    // MARK: - Login

    /// Authenticates a user by email and password.
    ///
    /// - Parameters:
    ///   - email: User's email.
    ///   - password: Plain-text password.
    /// - Returns: The authenticated `UserRecord`.
    func login(email: String, password: String) async throws -> UserRecord {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)

        let users = loadUsers()
        guard let user = users.first(where: { $0.email == normalizedEmail }) else {
            throw AuthError.invalidCredentials
        }

        // Verify password
        let inputHash = hashPassword(password, salt: user.passwordSalt)
        guard inputHash == user.passwordHash else {
            throw AuthError.invalidCredentials
        }

        saveSession(id: user.id)
        return user
    }

    // MARK: - Session Management

    /// Retrieves the currently authenticated user from the stored session.
    ///
    /// - Returns: The `UserRecord` if the session is valid, `nil` otherwise.
    func getCurrentUser() async -> UserRecord? {
        guard let userId = UserDefaults.standard.string(forKey: sessionKey) else {
            return nil
        }

        let users = loadUsers()
        return users.first(where: { $0.id == userId })
    }

    /// Clears the stored session, effectively logging out.
    func logout() {
        clearSession()
    }

    // MARK: - Private — Password Hashing

    /// Generates a random 16-byte salt as a hex string.
    private func generateSalt() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        for i in bytes.indices {
            bytes[i] = UInt8.random(in: 0...255)
        }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    /// Hashes a password with the given salt using SHA-256.
    private func hashPassword(_ password: String, salt: String) -> String {
        let input = Data((password + salt).utf8)
        let digest = SHA256.hash(data: input)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Private — Local Storage

    private func loadUsers() -> [UserRecord] {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else {
            return []
        }
        return (try? JSONDecoder().decode([UserRecord].self, from: data)) ?? []
    }

    private func saveUsers(_ users: [UserRecord]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    // MARK: - Private — Session Persistence

    private func saveSession(id: String) {
        UserDefaults.standard.set(id, forKey: sessionKey)
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }
}

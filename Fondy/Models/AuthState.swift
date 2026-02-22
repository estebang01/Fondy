//
//  AuthState.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI

/// Manages authentication state across the app.
///
/// Owns the source of truth for whether the user is signed in,
/// current auth screen, form fields, validation, and loading state.
/// Delegates actual auth operations to `AuthService`.
@Observable
class AuthState {
    // MARK: - Dependencies

    private let authService: AuthService

    // MARK: - Navigation

    /// Whether the user is authenticated and should see the main app.
    var isAuthenticated = false

    /// Whether the user has dismissed the onboarding welcome screen.
    var hasSeenOnboarding = false

    /// Which auth screen is currently displayed.
    var currentScreen: AuthScreen = .login

    // MARK: - User Data

    /// The currently authenticated user (nil when logged out).
    var currentUser: UserRecord?

    // MARK: - Form Fields

    var fullName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""

    // MARK: - UI State

    var isLoading = false
    var showPassword = false
    var showConfirmPassword = false
    var errorMessage: String?

    // MARK: - Initialization

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    // MARK: - Validation

    var isLoginValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
        && password.count >= 6
    }

    var isSignUpValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        && !email.trimmingCharacters(in: .whitespaces).isEmpty
        && password.count >= 8
        && password == confirmPassword
    }

    var passwordStrength: PasswordStrength {
        let length = password.count
        if length == 0 { return .none }
        if length < 6 { return .weak }
        if length < 10 { return .medium }
        return .strong
    }

    // MARK: - Actions

    /// Authenticates the user with the auth service.
    func login() async {
        guard isLoginValid else {
            errorMessage = "Please check your email and password"
            return
        }
        errorMessage = nil
        isLoading = true

        do {
            let user = try await authService.login(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Creates a new user account locally.
    func signUp() async {
        guard isSignUpValid else {
            if password != confirmPassword {
                errorMessage = "Passwords do not match"
            } else {
                errorMessage = "Please fill in all fields correctly"
            }
            return
        }
        errorMessage = nil
        isLoading = true

        do {
            let user = try await authService.signUp(
                fullName: fullName,
                email: email,
                password: password
            )
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Checks for an existing session on app launch.
    func checkSession() async {
        if let user = await authService.getCurrentUser() {
            currentUser = user
            isAuthenticated = true
        }
    }

    /// Logs out the current user and clears the session.
    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
        clearForm()
    }

    /// Resets form fields when switching between screens.
    func clearForm() {
        fullName = ""
        email = ""
        password = ""
        confirmPassword = ""
        showPassword = false
        showConfirmPassword = false
        errorMessage = nil
    }
}

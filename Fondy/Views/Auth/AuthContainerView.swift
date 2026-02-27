//
//  AuthContainerView.swift
//  Fondy
//
//  Switches between login and phone sign-up screens with slide transitions.
//

import SwiftUI

/// Routes between authentication screens based on `AuthState.currentScreen`.
///
/// Manages the `PhoneAuthState` lifecycle and provides animated transitions
/// between login and phone sign-up flows.
struct AuthContainerView: View {
    @Bindable var authState: AuthState

    @State private var phoneAuth = PhoneAuthState()

    // MARK: - Body

    var body: some View {
        Group {
            switch authState.currentScreen {
            case .login:
                LoginView(authState: authState)
                    .transition(.move(edge: .leading).combined(with: .opacity))

            case .signUp, .phoneSignUp:
                phoneSignUpFlow
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.springGentle, value: authState.currentScreen == .login)
        .animation(.springGentle, value: phoneAuth.step)
    }

    // MARK: - Phone Sign-Up Flow

    @ViewBuilder
    private var phoneSignUpFlow: some View {
        switch phoneAuth.step {
        case .phoneEntry:
            PhoneSignUpView(phoneAuth: phoneAuth, authState: authState)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .otpVerification:
            OTPVerificationView(phoneAuth: phoneAuth, authState: authState)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .notifications:
            NotificationsPromptView(phoneAuth: phoneAuth)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .countryOfResidence:
            CountryOfResidenceView(phoneAuth: phoneAuth)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .nameEntry:
            NameEntryView(phoneAuth: phoneAuth)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .emailEntry:
            EmailEntryView(phoneAuth: phoneAuth)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .dateOfBirth:
            DateOfBirthView(phoneAuth: phoneAuth)
                .transition(.move(edge: .trailing).combined(with: .opacity))

        case .createPasscode:
            CreatePasscodeView(phoneAuth: phoneAuth, authState: authState)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview {
    AuthContainerView(authState: AuthState())
}

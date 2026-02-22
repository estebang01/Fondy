//
//  PhoneSignUpView.swift
//  Fondy
//
//  Phone number sign-up screen with light background,
//  country code picker, phone input field, and "Sign up" CTA.
//

import SwiftUI

/// "Let's get started!" screen where the user enters their phone number.
///
/// Features a clean light background with gray input fields,
/// country picker, and a bottom-pinned blue "Sign up" button.
struct PhoneSignUpView: View {
    @Bindable var phoneAuth: PhoneAuthState
    var authState: AuthState

    @State private var isAppeared = false
    @FocusState private var isPhoneFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            headerSection
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            phoneInputRow
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            loginLink
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 22)

            Spacer()

            signUpButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $phoneAuth.showConfirmation) {
            PhoneConfirmationSheet(phoneAuth: phoneAuth)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $phoneAuth.showCountryPicker) {
            CountryPickerSheet(selectedCountry: $phoneAuth.selectedCountry)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
            isPhoneFocused = true
        }
    }
}

// MARK: - Subviews

private extension PhoneSignUpView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                authState.currentScreen = .login
            }
        } label: {
            Image(systemName: "arrow.left")
                .font(.title3.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Go back")
    }

    // MARK: Header

    var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Let's get started!")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Enter your phone number. We will send you a confirmation code there")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(2)
        }
    }

    // MARK: Phone Input Row

    var phoneInputRow: some View {
        HStack(spacing: Spacing.sm) {
            // Country code button
            Button {
                Haptics.light()
                phoneAuth.showCountryPicker = true
            } label: {
                HStack(spacing: Spacing.sm) {
                    FlagCircle(url: phoneAuth.selectedCountry.flagURL, size: 24)
                    Text(phoneAuth.selectedCountry.dialCode)
                        .font(.body.weight(.medium))
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, 14)
                .background(
                    FondyColors.fillQuaternary,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
            }
            .accessibilityLabel("Country code \(phoneAuth.selectedCountry.dialCode)")

            // Phone number field
            ZStack(alignment: .trailing) {
                TextField("Mobile number", text: $phoneAuth.phoneNumber)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($isPhoneFocused)
                    .tint(.blue)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.trailing, phoneAuth.phoneNumber.isEmpty ? 0 : Spacing.xxl)
                    .padding(.vertical, 14)
                    .background(
                        FondyColors.fillQuaternary,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )

                // Clear button
                if !phoneAuth.phoneNumber.isEmpty {
                    Button {
                        Haptics.light()
                        phoneAuth.clearPhone()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(FondyColors.labelTertiary)
                    }
                    .padding(.trailing, Spacing.md)
                    .transition(.opacity)
                    .accessibilityLabel("Clear phone number")
                }
            }
            .animation(.springInteractive, value: phoneAuth.phoneNumber.isEmpty)
        }
    }

    // MARK: Login Link

    var loginLink: some View {
        Button {
            Haptics.selection()
            authState.clearForm()
            withAnimation(.springGentle) {
                authState.currentScreen = .login
            }
        } label: {
            HStack(spacing: 0) {
                Text("Already have an account? ")
                    .foregroundStyle(.blue.opacity(0.7))
                Text("Log in")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
        .accessibilityLabel("Already have an account? Log in")
    }

    // MARK: Sign Up Button

    var signUpButton: some View {
        Button {
            Haptics.medium()
            phoneAuth.showConfirmation = true
        } label: {
            Text("Sign up")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .background(
                    phoneAuth.isPhoneValid ? .blue : .blue.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!phoneAuth.isPhoneValid)
        .animation(.springInteractive, value: phoneAuth.isPhoneValid)
    }
}

// MARK: - Preview

#Preview("Empty") {
    PhoneSignUpView(
        phoneAuth: PhoneAuthState(),
        authState: AuthState()
    )
}

#Preview("Filled") {
    let state = PhoneAuthState()
    let _ = state.phoneNumber = "90366027"
    PhoneSignUpView(
        phoneAuth: state,
        authState: AuthState()
    )
}

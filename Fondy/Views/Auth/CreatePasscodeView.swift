//
//  CreatePasscodeView.swift
//  Fondy
//
//  "Create passcode" screen with a custom number pad for entering
//  a 6–12 digit passcode. Final step before account creation.
//

import SwiftUI

/// Passcode creation screen with a custom in-app number pad.
///
/// Centered title and subtitle, dot indicators showing entered digits,
/// and a 3×4 number grid with a backspace key. Passcode must be 6–12 digits.
/// Auto-completes sign-up when the user taps the check button after entering ≥6 digits.
struct CreatePasscodeView: View {
    @Bindable var phoneAuth: PhoneAuthState
    var authState: AuthState

    @State private var isAppeared = false

    private let maxDigits = 12

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            headerSection
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            dotIndicators
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)

            Spacer()

            numberPad
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            phoneAuth.passcodeDigits = ""
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension CreatePasscodeView {

    // MARK: Header

    var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("Create passcode")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Passcode should be 6 to 12 digits long")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    // MARK: Dot Indicators

    var dotIndicators: some View {
        HStack(spacing: Spacing.md) {
            ForEach(0..<maxDigits, id: \.self) { index in
                Circle()
                    .fill(index < phoneAuth.passcodeDigits.count
                          ? FondyColors.labelPrimary
                          : FondyColors.fillTertiary)
                    .frame(width: 12, height: 12)
                    .scaleEffect(index < phoneAuth.passcodeDigits.count ? 1 : 0.75)
                    .animation(.springInteractive, value: phoneAuth.passcodeDigits.count)
            }
        }
        .frame(height: 20)
    }

    // MARK: Number Pad

    var numberPad: some View {
        VStack(spacing: Spacing.xl) {
            // Row 1: 1 2 3
            HStack(spacing: Spacing.xl) {
                numberKey("1")
                numberKey("2")
                numberKey("3")
            }

            // Row 2: 4 5 6
            HStack(spacing: Spacing.xl) {
                numberKey("4")
                numberKey("5")
                numberKey("6")
            }

            // Row 3: 7 8 9
            HStack(spacing: Spacing.xl) {
                numberKey("7")
                numberKey("8")
                numberKey("9")
            }

            // Row 4: (confirm) 0 (backspace)
            HStack(spacing: Spacing.xl) {
                // Confirm / checkmark — visible when passcode is valid
                Button {
                    Haptics.medium()
                    completeSignUp()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(phoneAuth.isPasscodeValid ? .blue : .clear)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .contentShape(Rectangle())
                }
                .disabled(!phoneAuth.isPasscodeValid)
                .accessibilityLabel("Confirm passcode")

                numberKey("0")

                // Backspace
                Button {
                    guard !phoneAuth.passcodeDigits.isEmpty else { return }
                    Haptics.light()
                    phoneAuth.passcodeDigits.removeLast()
                } label: {
                    Image(systemName: "delete.backward")
                        .font(.title2)
                        .foregroundStyle(FondyColors.labelPrimary)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Delete")
            }
        }
    }

    func numberKey(_ digit: String) -> some View {
        Button {
            guard phoneAuth.passcodeDigits.count < maxDigits else { return }
            Haptics.light()
            phoneAuth.passcodeDigits.append(digit)
        } label: {
            Text(digit)
                .font(.system(size: 32, weight: .regular, design: .default))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Digit \(digit)")
    }

    // MARK: - Sign Up Action

    func completeSignUp() {
        guard phoneAuth.isPasscodeValid else { return }

        // Use the email entered during sign-up
        let signUpEmail = phoneAuth.email.trimmingCharacters(in: .whitespaces).lowercased()

        // Use passcode as the password
        authState.fullName = phoneAuth.fullName
        authState.email = signUpEmail.isEmpty
            ? "\(phoneAuth.phoneNumber.filter(\.isNumber))@fondy.phone"
            : signUpEmail
        authState.password = phoneAuth.passcodeDigits
        authState.confirmPassword = phoneAuth.passcodeDigits

        Task {
            await authState.signUp()
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    CreatePasscodeView(
        phoneAuth: PhoneAuthState(),
        authState: AuthState()
    )
}

#Preview("Partial") {
    let state = PhoneAuthState()
    let _ = state.passcodeDigits = "1234"
    CreatePasscodeView(
        phoneAuth: state,
        authState: AuthState()
    )
}

#Preview("Valid") {
    let state = PhoneAuthState()
    let _ = state.passcodeDigits = "123456"
    CreatePasscodeView(
        phoneAuth: state,
        authState: AuthState()
    )
}

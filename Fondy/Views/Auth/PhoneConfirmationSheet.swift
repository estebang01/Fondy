//
//  PhoneConfirmationSheet.swift
//  Fondy
//
//  Dark modal sheet asking the user to confirm their phone number
//  before sending a verification code.
//

import SwiftUI

/// Confirmation dialog displayed before sending the OTP code.
///
/// Shows the full international phone number with flag, a "Confirm" button
/// (white, prominent), and a "Go back" button (gray, secondary).
struct PhoneConfirmationSheet: View {
    @Bindable var phoneAuth: PhoneAuthState
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.xl) {
            phoneDisplay
            confirmationText
            confirmButton
            goBackButton
        }
        .padding(Spacing.xxl)
        .padding(.top, Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .presentationBackground(.clear)
    }
}

// MARK: - Subviews

private extension PhoneConfirmationSheet {

    var phoneDisplay: some View {
        HStack(spacing: Spacing.md) {
            FlagCircle(url: phoneAuth.selectedCountry.flagURL, size: 34)

            Text(phoneAuth.fullInternationalNumber)
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Phone number: \(phoneAuth.fullInternationalNumber)")
    }

    var confirmationText: some View {
        Text("Is this number correct? We'll send you a confirmation code there")
            .font(.subheadline)
            .foregroundStyle(FondyColors.labelSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
    }

    var confirmButton: some View {
        Button {
            Haptics.medium()
            phoneAuth.confirmAndSendCode()
        } label: {
            Text("Confirm")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .buttonStyle(PositiveButtonStyle())
    }

    var goBackButton: some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            Text("Go back")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .liquidGlass(cornerRadius: 16)
        }
        .buttonStyle(LiquidGlassButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    let state = PhoneAuthState()
    let _ = state.phoneNumber = "6502137390"
    let _ = state.selectedCountry = .unitedStates

    PhoneConfirmationSheet(phoneAuth: state)
        .preferredColorScheme(.dark)
}

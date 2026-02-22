//
//  PhoneAuthState.swift
//  Fondy
//
//  State model for the phone-based sign-up / OTP verification flow.
//

import SwiftUI

/// Manages state for the phone number sign-up and OTP verification flow.
///
/// Tracks the selected country, phone input, OTP digits, confirmation sheet
/// visibility, resend countdown, and navigation between steps.
@Observable
class PhoneAuthState {

    // MARK: - Navigation

    /// Current step in the phone auth flow.
    var step: PhoneAuthStep = .phoneEntry

    // MARK: - Country Selection

    /// The currently selected country for the dial code.
    var selectedCountry: Country = .singapore

    /// Whether the country picker sheet is presented.
    var showCountryPicker = false

    // MARK: - Phone Entry

    /// Raw phone number digits entered by the user.
    var phoneNumber = ""

    /// Whether the confirmation sheet is presented.
    var showConfirmation = false

    // MARK: - OTP Verification

    /// The 6 individual OTP digit characters.
    var otpDigits: [String] = Array(repeating: "", count: 6)

    /// Index of the currently focused OTP field.
    var focusedOTPIndex: Int? = 0

    /// Seconds remaining before the resend button activates.
    var resendCountdown: Int = 15

    /// Whether a verification request is in progress.
    var isLoading = false

    /// Error message to display.
    var errorMessage: String?

    // MARK: - Country of Residence

    /// The country selected during the sign-up flow.
    var residenceCountry: Country = .singapore

    /// Whether the residence country picker sheet is presented.
    var showResidenceCountryPicker = false

    // MARK: - Name Entry

    /// First name as in official ID.
    var firstName = ""

    /// Last name as in official ID.
    var lastName = ""

    /// Optional alias / nickname.
    var alias = ""

    // MARK: - Email Entry

    /// Email address entered during sign-up.
    var email = ""

    // MARK: - Passcode

    /// Digits entered for the app passcode (6–12 digits).
    var passcodeDigits = ""

    // MARK: - Computed

    /// Formatted phone number for display (e.g., "(650) 213-7390").
    var formattedPhone: String {
        let digits = phoneNumber.filter(\.isNumber)
        guard !digits.isEmpty else { return "" }

        // US-style formatting for 10-digit numbers
        if selectedCountry == .unitedStates || selectedCountry == .canada {
            return formatNorthAmerican(digits)
        }
        return digits
    }

    /// Full international number for display (e.g., "+1 650 213 7390").
    var fullInternationalNumber: String {
        let digits = phoneNumber.filter(\.isNumber)
        let spaced = digits.enumerated().map { index, char in
            (index > 0 && index % 3 == 0) ? " \(char)" : String(char)
        }.joined()
        return "\(selectedCountry.dialCode) \(spaced)"
    }

    /// Whether the phone number has enough digits to proceed.
    var isPhoneValid: Bool {
        phoneNumber.filter(\.isNumber).count >= 7
    }

    /// The complete OTP string.
    var otpCode: String {
        otpDigits.joined()
    }

    /// Whether all 6 OTP digits have been entered.
    var isOTPComplete: Bool {
        otpDigits.allSatisfy { !$0.isEmpty }
    }

    /// Whether the resend timer is still counting down.
    var canResend: Bool {
        resendCountdown <= 0
    }

    /// Masked phone for the OTP screen (e.g., "+65 9036 6027").
    var maskedPhone: String {
        let digits = phoneNumber.filter(\.isNumber)
        let spaced = digits.enumerated().map { index, char in
            (index > 0 && index % 4 == 0) ? " \(char)" : String(char)
        }.joined()
        return "\(selectedCountry.dialCode) \(spaced)"
    }

    /// Full name assembled from first + last name fields.
    var fullName: String {
        "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"
            .trimmingCharacters(in: .whitespaces)
    }

    /// Whether the name form is valid to proceed.
    var isNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
        && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Whether the email address looks valid.
    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    /// Whether the passcode meets the length requirement (6–12 digits).
    var isPasscodeValid: Bool {
        passcodeDigits.count >= 6
    }

    // MARK: - Actions

    /// Moves to OTP entry and starts the countdown timer.
    func confirmAndSendCode() {
        showConfirmation = false
        step = .otpVerification
        resendCountdown = 15
        otpDigits = Array(repeating: "", count: 6)
        focusedOTPIndex = 0
    }

    /// Resets OTP state for a resend.
    func resendCode() {
        guard canResend else { return }
        resendCountdown = 15
        otpDigits = Array(repeating: "", count: 6)
        focusedOTPIndex = 0
        errorMessage = nil
    }

    /// Goes back to phone entry from OTP.
    func goBackToPhoneEntry() {
        step = .phoneEntry
        errorMessage = nil
    }

    /// Advances from OTP to the notifications prompt.
    func completeOTP() {
        step = .notifications
    }

    /// Advances from notifications to country of residence.
    func completeNotifications() {
        step = .countryOfResidence
    }

    /// Advances from country of residence to name entry.
    func completeCountrySelection() {
        step = .nameEntry
    }

    /// Advances from name entry to email entry.
    func completeName() {
        step = .emailEntry
    }

    /// Advances from email entry to passcode creation.
    func completeEmail() {
        step = .createPasscode
    }

    /// Goes back one step in the post-OTP flow.
    func goBackFromCurrentStep() {
        switch step {
        case .notifications:
            step = .otpVerification
        case .countryOfResidence:
            step = .notifications
        case .nameEntry:
            step = .countryOfResidence
        case .emailEntry:
            step = .nameEntry
        case .createPasscode:
            step = .emailEntry
        default:
            break
        }
    }

    /// Clears the phone number field.
    func clearPhone() {
        phoneNumber = ""
    }

    // MARK: - Formatting Helpers

    private func formatNorthAmerican(_ digits: String) -> String {
        let d = Array(digits)
        var result = ""
        if d.count >= 1 { result += "(" }
        for (i, c) in d.enumerated() {
            if i == 3 { result += ") " }
            if i == 6 { result += "-" }
            if i >= 10 { break }
            result += String(c)
        }
        return result
    }
}


//
//  PhoneAuthStep.swift
//  Fondy
//

/// Steps in the phone-based sign-up flow.
enum PhoneAuthStep: Equatable {
    case phoneEntry
    case otpVerification
    case notifications
    case countryOfResidence
    case nameEntry
    case emailEntry
    case dateOfBirth
    case createPasscode
}

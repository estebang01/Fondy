//
//  EmailEntryView.swift
//  Fondy
//
//  "Email" screen where the user enters their email address
//  during the sign-up flow, with a single text field and Continue button.
//

import SwiftUI

/// Email entry screen during sign-up.
///
/// Displays a large "Email" title, descriptive subtitle,
/// a single email text field, and a bottom-pinned "Continue" button.
struct EmailEntryView: View {
    @Bindable var phoneAuth: PhoneAuthState

    @State private var isAppeared = false
    @FocusState private var isEmailFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
                .padding(.top, Spacing.xxxl + Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            emailField
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            Spacer()

            continueButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
            isEmailFocused = true
        }
    }
}

// MARK: - Subviews

private extension EmailEntryView {

    // MARK: Header

    var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Email")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Enter your email address")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
    }

    // MARK: Email Field

    var emailField: some View {
        TextField("Email", text: $phoneAuth.email)
            .font(.body)
            .foregroundStyle(FondyColors.labelPrimary)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($isEmailFocused)
            .tint(.blue)
            .submitLabel(.continue)
            .onSubmit {
                guard phoneAuth.isEmailValid else { return }
                Haptics.medium()
                withAnimation(.springGentle) {
                    phoneAuth.completeEmail()
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .background(
                FondyColors.fillQuaternary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .accessibilityLabel("Email address")
    }

    // MARK: Continue Button

    var continueButton: some View {
        Button {
            Haptics.medium()
            isEmailFocused = false
            withAnimation(.springGentle) {
                phoneAuth.completeEmail()
            }
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .buttonStyle(PositiveButtonStyle())
        .disabled(!phoneAuth.isEmailValid)
    }
}

// MARK: - Preview

#Preview("Empty") {
    EmailEntryView(phoneAuth: PhoneAuthState())
}

#Preview("Filled") {
    let state = PhoneAuthState()
    let _ = state.email = "john@email.com"
    EmailEntryView(phoneAuth: state)
}

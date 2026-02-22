//
//  CountryOfResidenceView.swift
//  Fondy
//
//  "Country of residence" screen shown during sign-up
//  with a country dropdown and "Sign up securely" CTA.
//

import SwiftUI

/// Country of residence selection screen during the sign-up flow.
///
/// Displays a large headline, descriptive subtitle, country dropdown
/// picker, legal disclaimer, and a bottom-pinned "Sign up securely" button.
struct CountryOfResidenceView: View {
    @Bindable var phoneAuth: PhoneAuthState

    @State private var isAppeared = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            headerSection
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            countryDropdown
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            Spacer()

            disclaimerText
                .padding(.bottom, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)

            signUpButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $phoneAuth.showResidenceCountryPicker) {
            CountryPickerSheet(selectedCountry: $phoneAuth.residenceCountry)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension CountryOfResidenceView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                phoneAuth.goBackFromCurrentStep()
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
            Text("Country of residence")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("The terms and services which apply to you will depend on your country of residence")
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(3)
        }
    }

    // MARK: Country Dropdown

    var countryDropdown: some View {
        Button {
            Haptics.light()
            phoneAuth.showResidenceCountryPicker = true
        } label: {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Country")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)

                HStack {
                    Text(phoneAuth.residenceCountry.name)
                        .font(.body)
                        .foregroundStyle(FondyColors.labelPrimary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + Spacing.xxs)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Country: \(phoneAuth.residenceCountry.name)")
        .accessibilityHint("Tap to change country")
    }

    // MARK: Disclaimer

    var disclaimerText: some View {
        Text("By pressing Sign up securely, you agree to our **Terms & Conditions** and **Privacy Policy**. Digital-only support available 24/7 via the in-app chat. Your data will be securely encrypted with TLS \u{1F512}")
            .font(.footnote)
            .foregroundStyle(FondyColors.labelSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .frame(maxWidth: .infinity)
    }

    // MARK: Sign Up Button

    var signUpButton: some View {
        Button {
            Haptics.medium()
            withAnimation(.springGentle) {
                phoneAuth.completeCountrySelection()
            }
        } label: {
            Text("Sign up securely")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .background(
                    .blue,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    CountryOfResidenceView(phoneAuth: PhoneAuthState())
}

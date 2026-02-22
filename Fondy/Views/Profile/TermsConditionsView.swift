//
//  TermsConditionsView.swift
//  Fondy
//
//  Terms & conditions screen displaying the app's
//  terms of service in a clean, readable format.
//

import SwiftUI

struct TermsConditionsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Terms & conditions")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                Text("Last updated: February 1, 2026")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)

                termsSection(
                    number: "1",
                    title: "Acceptance of terms",
                    content: "By accessing or using the Fondy application, you agree to be bound by these Terms & Conditions. If you do not agree, you may not use the service."
                )

                termsSection(
                    number: "2",
                    title: "Account eligibility",
                    content: "You must be at least 18 years old and a resident of a supported country to create an account. You are responsible for maintaining the confidentiality of your credentials."
                )

                termsSection(
                    number: "3",
                    title: "Services provided",
                    content: "Fondy provides digital banking services including money transfers, currency exchange, card payments, and investment features. Services are subject to availability and may vary by region."
                )

                termsSection(
                    number: "4",
                    title: "Fees and charges",
                    content: "Certain services may be subject to fees as outlined in our fee schedule. Fees vary by plan type and transaction. We will notify you of any fee changes in advance."
                )

                termsSection(
                    number: "5",
                    title: "User responsibilities",
                    content: "You agree to provide accurate information, keep your account secure, comply with applicable laws, and not use the service for prohibited activities including fraud or money laundering."
                )

                termsSection(
                    number: "6",
                    title: "Intellectual property",
                    content: "All content, trademarks, and intellectual property within the Fondy application are owned by Fondy or its licensors. You may not reproduce, modify, or distribute any content without permission."
                )

                termsSection(
                    number: "7",
                    title: "Limitation of liability",
                    content: "Fondy is not liable for indirect, incidental, or consequential damages arising from the use of our services. Our total liability is limited to the fees paid in the preceding 12 months."
                )

                termsSection(
                    number: "8",
                    title: "Termination",
                    content: "We may suspend or terminate your account for violation of these terms or for any reason with reasonable notice. You may close your account at any time through the app settings."
                )

                termsSection(
                    number: "9",
                    title: "Changes to terms",
                    content: "We reserve the right to modify these terms at any time. Material changes will be communicated via the app or email. Continued use after changes constitutes acceptance."
                )

                contactSection
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Haptics.light()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                .accessibilityLabel("Back")
            }
        }
    }
}

// MARK: - Terms Section

private extension TermsConditionsView {

    func termsSection(number: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Text(number)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(.blue, in: Circle())

                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
            }

            Text(content)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(4)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    FondyColors.surfaceSecondary,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
        }
    }
}

// MARK: - Contact Section

private extension TermsConditionsView {

    var contactSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Need help?")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("For questions about these terms, reach out to our legal team.")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)

                Button {
                    Haptics.light()
                } label: {
                    Label("Contact support", systemImage: "envelope.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.xs)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TermsConditionsView()
    }
}

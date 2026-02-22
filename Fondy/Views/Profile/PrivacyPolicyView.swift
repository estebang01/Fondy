//
//  PrivacyPolicyView.swift
//  Fondy
//
//  Privacy policy screen displaying the app's privacy
//  practices in a clean, readable format.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Privacy policy")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                Text("Last updated: February 1, 2026")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)

                policySection(
                    title: "Information we collect",
                    items: [
                        "Personal identification information (name, email, phone number)",
                        "Financial information necessary to provide our services",
                        "Device information and usage analytics",
                        "Location data when required for transactions"
                    ]
                )

                policySection(
                    title: "How we use your information",
                    items: [
                        "To provide, maintain, and improve our services",
                        "To process transactions and send related information",
                        "To detect and prevent fraud and unauthorized access",
                        "To comply with legal obligations and regulations"
                    ]
                )

                policySection(
                    title: "Data sharing",
                    items: [
                        "We do not sell your personal information to third parties",
                        "We share data with service providers who assist in our operations",
                        "We may share information when required by law or regulation",
                        "Data is shared with payment networks to process transactions"
                    ]
                )

                policySection(
                    title: "Data security",
                    items: [
                        "Industry-standard encryption for data in transit and at rest",
                        "Regular security audits and vulnerability assessments",
                        "Access controls and authentication for all systems",
                        "Continuous monitoring for suspicious activity"
                    ]
                )

                policySection(
                    title: "Your rights",
                    items: [
                        "Access and download your personal data",
                        "Request correction of inaccurate information",
                        "Request deletion of your data (subject to legal requirements)",
                        "Opt out of marketing communications at any time"
                    ]
                )

                contactCard
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

// MARK: - Policy Section

private extension PrivacyPolicyView {

    func policySection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Circle()
                            .fill(FondyColors.labelTertiary)
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)

                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(FondyColors.labelSecondary)
                    }
                }
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

// MARK: - Contact Card

private extension PrivacyPolicyView {

    var contactCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Questions?")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("If you have questions about this privacy policy, contact our Data Protection Officer.")
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
        PrivacyPolicyView()
    }
}

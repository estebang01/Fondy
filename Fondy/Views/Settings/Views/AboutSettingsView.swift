//
//  AboutSettingsView.swift
//  Fondy — Settings Module
//
//  App version, legal links, open-source licenses, rate app, report a bug.
//

import SwiftUI

struct AboutSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    private let appVersion: String = Bundle.main
        .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"

    private let buildNumber: String = Bundle.main
        .object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("About")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                appInfoCard
                legalCard
                supportCard
                versionFooter
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { backButton }
    }

    // MARK: - App Info Card

    private var appInfoCard: some View {
        SettingsCard(title: "App") {
            SettingsInfoRow(label: "Version", value: appVersion)
            SettingsDivider()
            SettingsInfoRow(label: "Build", value: buildNumber)
        }
    }

    // MARK: - Legal Card

    private var legalCard: some View {
        SettingsCard(title: "Legal") {
            NavigationLink {
                TermsConditionsView()
            } label: {
                navRowLabel(icon: "doc.text.fill", title: "Terms & Conditions")
            }
            .buttonStyle(.plain)

            SettingsDivider()

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                navRowLabel(icon: "hand.raised.fill", title: "Privacy Policy")
            }
            .buttonStyle(.plain)

            SettingsDivider()

            NavigationLink {
                LicensesView()
            } label: {
                navRowLabel(icon: "doc.badge.gearshape.fill", title: "Open-Source Licenses")
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Support Card

    private var supportCard: some View {
        SettingsCard(title: "Support") {
            SettingsNavRow(
                icon: "star.fill",
                iconColor: .orange,
                title: "Rate Fondy",
                value: nil
            ) {
                openAppStoreReview()
            }

            SettingsDivider()

            SettingsNavRow(
                icon: "ladybug.fill",
                iconColor: .blue,
                title: "Report a Bug",
                value: nil
            ) {
                openBugReport()
            }

            SettingsDivider()

            SettingsNavRow(
                icon: "envelope.fill",
                iconColor: .blue,
                title: "Contact Support",
                value: nil
            ) {
                openSupportEmail()
            }
        }
    }

    // MARK: - Version Footer

    private var versionFooter: some View {
        VStack(spacing: Spacing.xs) {
            Text("Fondy \(appVersion)")
                .font(.caption.weight(.medium))
                .foregroundStyle(FondyColors.labelTertiary)

            Text("Made with care for investors everywhere.")
                .font(.caption2)
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.sm)
    }

    // MARK: - Helpers

    private func navRowLabel(icon: String, title: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

            Text(title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer(minLength: Spacing.sm)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
        .contentShape(Rectangle())
    }

    private func openAppStoreReview() {
        // Replace with your App Store ID
        guard let url = URL(string: "https://apps.apple.com/app/id000000000?action=write-review") else { return }
        UIApplication.shared.open(url)
    }

    private func openBugReport() {
        guard let url = URL(string: "mailto:support@fondy.app?subject=Bug%20Report") else { return }
        UIApplication.shared.open(url)
    }

    private func openSupportEmail() {
        guard let url = URL(string: "mailto:support@fondy.app") else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Toolbar

    private var backButton: some ToolbarContent {
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

// MARK: - Licenses View

struct LicensesView: View {
    @Environment(\.dismiss) private var dismiss

    private let licenses: [(name: String, license: String, url: String)] = [
        ("Firebase iOS SDK",       "Apache 2.0",  "https://github.com/firebase/firebase-ios-sdk"),
        ("Swift Algorithms",       "Apache 2.0",  "https://github.com/apple/swift-algorithms"),
        ("Swift Collections",      "Apache 2.0",  "https://github.com/apple/swift-collections"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Open-Source Licenses")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                SettingsCard {
                    ForEach(Array(licenses.enumerated()), id: \.offset) { index, lib in
                        if index > 0 { SettingsDivider() }
                        licenseRow(lib)
                    }
                }
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

    private func licenseRow(_ lib: (name: String, license: String, url: String)) -> some View {
        Button {
            guard let url = URL(string: lib.url) else { return }
            UIApplication.shared.open(url)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(lib.name)
                        .font(.body)
                        .foregroundStyle(FondyColors.labelPrimary)
                    Text(lib.license)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.vertical, Spacing.md + Spacing.xxs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AboutSettingsView()
    }
}

#Preview("Licenses") {
    NavigationStack {
        LicensesView()
    }
}

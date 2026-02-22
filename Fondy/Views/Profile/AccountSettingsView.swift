//
//  AccountSettingsView.swift
//  Fondy
//
//  Account settings screen with Personal details, Account details,
//  Documents, Privacy policy, Terms & conditions, and Close account.
//

import SwiftUI

struct AccountSettingsView: View {
    let userProfile: UserProfile
    let authState: AuthState

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                // Title
                Text("Account")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                // Personal details + Account details card
                personalAccountCard

                // Documents section
                documentsCard

                // Close account
                closeAccountCard
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

// MARK: - Personal + Account Details Card

private extension AccountSettingsView {

    var personalAccountCard: some View {
        VStack(spacing: 0) {
            NavigationLink {
                EditProfileView(userProfile: userProfile)
            } label: {
                accountRow(
                    iconName: "person.fill",
                    iconColor: .blue,
                    title: "Personal details"
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            NavigationLink {
                AccountDetailsView()
            } label: {
                accountRow(
                    iconName: "dollarsign.circle.fill",
                    iconColor: .blue,
                    title: "Account details"
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}

// MARK: - Documents Card

private extension AccountSettingsView {

    var documentsCard: some View {
        VStack(spacing: 0) {
            NavigationLink {
                DocumentsView()
            } label: {
                accountRow(
                    iconName: "doc.text.fill",
                    iconColor: .blue,
                    title: "Documents"
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                accountRow(
                    iconName: "doc.fill",
                    iconColor: .blue,
                    title: "Privacy policy"
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            NavigationLink {
                TermsConditionsView()
            } label: {
                accountRow(
                    iconName: "info.circle.fill",
                    iconColor: .blue,
                    title: "Terms & conditions"
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}

// MARK: - Close Account Card

private extension AccountSettingsView {

    var closeAccountCard: some View {
        VStack(spacing: 0) {
            Button {
                Haptics.medium()
            } label: {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "heart.slash.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(red: 0.9, green: 0.3, blue: 0.2))
                        .frame(width: 30, height: 30)

                    Text("Close account")
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
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}

// MARK: - Helpers

private extension AccountSettingsView {

    func accountRow(iconName: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)

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

}

// MARK: - Preview

#Preview {
    NavigationStack {
        AccountSettingsView(
            userProfile: UserProfile.createMock(),
            authState: AuthState()
        )
    }
}

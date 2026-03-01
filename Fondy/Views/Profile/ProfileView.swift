//
//  ProfileView.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import SwiftUI

/// Full profile/settings screen matching the Revolut-style design.
///
/// Layout: Back arrow → blurred name + avatar (initials circle) →
/// @revtag → invite friends pill → help card → account details card →
/// settings rows (Plan, Account, Security & privacy, App settings) → log out.
struct ProfileView: View {
    let authState: AuthState

    @State private var userProfile = UserProfile.createMock()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.bottom, Spacing.sm)

                    revtagLabel
                        .padding(.bottom, Spacing.lg)

                    inviteFriendsPill
                        .padding(.bottom, Spacing.sectionGap)

                    helpCard
                        .padding(.bottom, Spacing.sectionGap)

                    accountDetailsCard
                        .padding(.bottom, Spacing.sectionGap)

                    settingsSection
                        .padding(.bottom, Spacing.sectionGap)

                    logOutButton
                }
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxxl + Spacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Haptics.light()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(FondyColors.labelPrimary)
                    }
                    .accessibilityLabel("Back")
                }
            }
            .onAppear {
                userProfile = UserProfile.from(user: authState.currentUser)
            }
        }
    }

    // MARK: - Header (Name + Avatar)

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(displayName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                    .redacted(reason: .placeholder)
            }

            Spacer(minLength: Spacing.lg)

            // Avatar circle with initials
            Text(userProfile.initials.isEmpty ? "US" : userProfile.initials)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color(.systemGray), in: Circle())
                .accessibilityLabel("Profile photo")
        }
    }

    // MARK: - Revtag

    private var revtagLabel: some View {
        Text("@\(userProfile.revtag.isEmpty ? "username" : userProfile.revtag)")
            .font(.subheadline)
            .foregroundStyle(.blue)
            .redacted(reason: .placeholder)
    }

    // MARK: - Invite Friends Pill

    private var inviteFriendsPill: some View {
        Button {
            Haptics.light()
        } label: {
            Label("Invite friends", systemImage: "heart.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm + Spacing.xxs)
                .liquidGlass(tint: .blue, cornerRadius: 50)
        }
        .buttonStyle(LiquidGlassButtonStyle())
    }

    // MARK: - Help Card

    private var helpCard: some View {
        NavigationLink {
            HelpArticleView(title: "Help")
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)

                Text("Help")
                    .font(.body.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)

                Spacer()
            }
            .padding(Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Account Details Card

    private var accountDetailsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Account details")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Spacer()

                Button {
                    Haptics.light()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 0) {
                accountDetailRow(label: "Name", value: "Personal \u{00B7} SGD", flagEmoji: "\u{1F1F8}\u{1F1EC}")
                Divider().padding(.leading, Spacing.lg)
                accountDetailRow(label: "Account", value: "••••••••", showCopy: true)
                Divider().padding(.leading, Spacing.lg)
                accountDetailRow(label: "Bank name", value: "DBS Bank Ltd", showCopy: true)
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }

    // MARK: - Settings Rows

    private var settingsSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                PlanView()
            } label: {
                settingsRow(iconName: "bolt.fill", iconColor: .blue, title: "Plan", subtitle: "Metal")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            NavigationLink {
                AccountSettingsView(userProfile: userProfile, authState: authState)
            } label: {
                settingsRow(iconName: "person.fill", iconColor: .blue, title: "Account")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            NavigationLink {
                SecurityPrivacyView()
            } label: {
                settingsRow(iconName: "shield.fill", iconColor: .blue, title: "Security & privacy")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            NavigationLink {
                AppSettingsView()
            } label: {
                settingsRow(iconName: "gearshape.fill", iconColor: .blue, title: "App settings")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }

    // MARK: - Log Out Button

    private var logOutButton: some View {
        Button {
            Haptics.medium()
            authState.logout()
        } label: {
            Text("Log out")
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.negative)
        }
        .buttonStyle(NegativeButtonStyle())
    }

    // MARK: - Helpers

    private var displayName: String {
        authState.currentUser?.fullName ?? "User"
    }

    private func accountDetailRow(label: String, value: String, flagEmoji: String? = nil, showCopy: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)

            Spacer()

            HStack(spacing: Spacing.sm) {
                if showCopy {
                    Button {
                        Haptics.light()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }

                if let flagEmoji {
                    Text(flagEmoji)
                        .font(.subheadline)
                }

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, Spacing.md + 2)
    }

    private func settingsRow(iconName: String, iconColor: Color, title: String, subtitle: String? = nil) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
            }

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
    ProfileView(authState: AuthState())
}

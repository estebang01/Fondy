//
//  AccountSettingsView.swift
//  Fondy — Settings Module
//
//  Three-section account screen: Edit Profile, Change Password, Active Sessions.
//  Dangerous "Delete Account" action anchored at the bottom.
//

import SwiftUI

struct AccountSettingsView: View {
    @State private var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss

    init(auth: any SettingsAuthServiceProtocol) {
        _viewModel = State(initialValue: AccountViewModel(auth: auth))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                pageTitle("Account")

                editProfileCard
                changePasswordCard
                sessionsCard

                Spacer(minLength: Spacing.xxxl)

                SettingsDestructiveButton(
                    title: "Delete Account",
                    isLoading: viewModel.isDeletingAccount
                ) {
                    viewModel.showDeleteConfirmation = true
                }
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { backButton }
        .confirmationDialog(
            "Delete your account?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) { viewModel.deleteAccount() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action is permanent and cannot be undone. All your data will be erased.")
        }
        .alert("Error", isPresented: .constant(viewModel.deleteError != nil)) {
            Button("OK") { viewModel.deleteError = nil }
        } message: {
            Text(viewModel.deleteError ?? "")
        }
    }

    // MARK: - Edit Profile Card

    private var editProfileCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Profile")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: Spacing.md) {
                SettingsTextField(
                    label: "Full Name",
                    placeholder: "Alex Rivera",
                    text: $viewModel.draftName,
                    textContentType: .name
                )

                SettingsTextField(
                    label: "Email",
                    placeholder: "you@example.com",
                    text: $viewModel.draftEmail,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )

                if let error = viewModel.profileSaveError {
                    SettingsErrorBanner(message: error)
                }

                if viewModel.profileSaveSuccess {
                    SettingsSuccessBanner(message: "Profile updated successfully.")
                }

                Button {
                    viewModel.saveProfile()
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isSavingProfile {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Text("Save Changes")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, Spacing.md)
                    .liquidGlass(
                        tint: .blue,
                        cornerRadius: Spacing.cardRadius,
                        disabled: !viewModel.isProfileValid || !viewModel.isProfileChanged
                    )
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .disabled(!viewModel.isProfileValid || !viewModel.isProfileChanged || viewModel.isSavingProfile)
            }
        }
    }

    // MARK: - Change Password Card

    private var changePasswordCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Password")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: Spacing.md) {
                SettingsTextField(
                    label: "Current Password",
                    placeholder: "••••••••",
                    text: $viewModel.currentPassword,
                    isSecure: true,
                    textContentType: .password
                )

                SettingsTextField(
                    label: "New Password",
                    placeholder: "Min. 8 characters",
                    text: $viewModel.newPassword,
                    isSecure: true,
                    textContentType: .newPassword
                )

                // Password strength bar
                if !viewModel.newPassword.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(FondyColors.fillTertiary)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(viewModel.passwordStrengthColor)
                                    .frame(width: geo.size.width * viewModel.passwordStrength)
                                    .animation(.springGentle, value: viewModel.passwordStrength)
                            }
                        }
                        .frame(height: 4)

                        if !viewModel.passwordStrengthLabel.isEmpty {
                            Text(viewModel.passwordStrengthLabel)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(viewModel.passwordStrengthColor)
                                .animation(.springGentle, value: viewModel.passwordStrengthLabel)
                        }
                    }
                }

                SettingsTextField(
                    label: "Confirm New Password",
                    placeholder: "Repeat new password",
                    text: $viewModel.confirmPassword,
                    isSecure: true,
                    textContentType: .newPassword
                )

                if let error = viewModel.passwordSaveError {
                    SettingsErrorBanner(message: error)
                }

                if viewModel.passwordSaveSuccess {
                    SettingsSuccessBanner(message: "Password changed successfully.")
                }

                Button {
                    viewModel.savePassword()
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isSavingPassword {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Text("Change Password")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, Spacing.md)
                    .liquidGlass(
                        tint: .blue,
                        cornerRadius: Spacing.cardRadius,
                        disabled: !viewModel.isPasswordValid
                    )
                }
                .buttonStyle(LiquidGlassButtonStyle())
                .disabled(!viewModel.isPasswordValid || viewModel.isSavingPassword)
            }
        }
    }

    // MARK: - Sessions Card

    private var sessionsCard: some View {
        SettingsCard(title: "Active Sessions") {
            ForEach(Array(viewModel.activeSessions.enumerated()), id: \.element.id) { index, session in
                if index > 0 { SettingsDivider() }

                sessionRow(session)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if !session.isCurrent {
                            Button(role: .destructive) {
                                viewModel.revokeSession(session)
                            } label: {
                                Label("Revoke", systemImage: "xmark.circle")
                            }
                        }
                    }
            }

            if viewModel.otherSessionCount > 1 {
                SettingsDivider()
                Button {
                    viewModel.showRevokeAllConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isRevokingAll {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                                .tint(.red)
                        } else {
                            Text("Revoke all other sessions")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.red)
                        }
                        Spacer()
                    }
                    .padding(.vertical, Spacing.md)
                }
                .buttonStyle(.plain)
            }
        }
        .confirmationDialog(
            "Revoke all other sessions?",
            isPresented: $viewModel.showRevokeAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Revoke \(viewModel.otherSessionCount) Sessions", role: .destructive) {
                viewModel.revokeAllOtherSessions()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Other devices will be signed out immediately.")
        }
    }

    private func sessionRow(_ session: ActiveSession) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: session.deviceIcon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(session.deviceName)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Text("\(session.location) · \(session.lastActiveLabel)")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.sm)

            if session.isCurrent {
                Text("This device")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FondyColors.positive)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(FondyColors.positive.opacity(0.12), in: Capsule())
            }
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.deviceName), \(session.location), \(session.lastActiveLabel)\(session.isCurrent ? ", this device" : "")")
    }

    // MARK: - Helpers

    private func pageTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(FondyColors.labelPrimary)
    }

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

// MARK: - Preview

#Preview {
    NavigationStack {
        AccountSettingsView(auth: MockSettingsAuthService())
    }
}

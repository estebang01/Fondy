//
//  AccountViewModel.swift
//  Fondy — Settings Module
//
//  Manages all account-level settings: profile editing, password change,
//  session management, and account deletion.
//

import SwiftUI

@Observable
final class AccountViewModel {

    // MARK: - Dependency

    private let auth: any SettingsAuthServiceProtocol

    // MARK: - Edit Profile

    var draftName: String
    var draftEmail: String
    var isSavingProfile: Bool = false
    var profileSaveError: String? = nil
    var profileSaveSuccess: Bool = false

    // MARK: - Change Password

    var currentPassword: String = ""
    var newPassword: String = ""
    var confirmPassword: String = ""
    var isSavingPassword: Bool = false
    var passwordSaveError: String? = nil
    var passwordSaveSuccess: Bool = false

    // MARK: - Sessions

    var isRevokingSession: Bool = false
    var isRevokingAll: Bool = false
    var showRevokeAllConfirmation: Bool = false

    // MARK: - Delete Account

    var showDeleteConfirmation: Bool = false
    var isDeletingAccount: Bool = false
    var deleteError: String? = nil

    // MARK: - Init

    init(auth: any SettingsAuthServiceProtocol) {
        self.auth = auth
        self.draftName = auth.displayName
        self.draftEmail = auth.email
    }

    // MARK: - Computed (read-through to service)

    var displayName: String { auth.displayName }
    var email: String { auth.email }
    var activeSessions: [ActiveSession] { auth.activeSessions }
    var otherSessionCount: Int { auth.activeSessions.filter { !$0.isCurrent }.count }

    var isProfileChanged: Bool {
        draftName != auth.displayName || draftEmail != auth.email
    }

    var isProfileValid: Bool {
        !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && draftEmail.contains("@")
            && draftEmail.contains(".")
    }

    var isPasswordValid: Bool {
        !currentPassword.isEmpty
            && newPassword.count >= 8
            && newPassword == confirmPassword
    }

    // MARK: - Password Strength

    var passwordStrength: Double {
        let p = newPassword
        var score = 0.0
        if p.count >= 8  { score += 0.25 }
        if p.count >= 12 { score += 0.15 }
        if p.contains(where: { $0.isUppercase })          { score += 0.2 }
        if p.contains(where: { $0.isNumber })              { score += 0.2 }
        if p.contains(where: { "!@#$%^&*".contains($0) }) { score += 0.2 }
        return min(score, 1.0)
    }

    var passwordStrengthLabel: String {
        switch passwordStrength {
        case 0..<0.01:  return ""
        case 0.01..<0.35: return "Weak"
        case 0.35..<0.65: return "Fair"
        case 0.65..<0.9:  return "Good"
        default:           return "Strong"
        }
    }

    var passwordStrengthColor: Color {
        switch passwordStrength {
        case 0..<0.35:    return FondyColors.negative
        case 0.35..<0.65: return .orange
        case 0.65..<0.9:  return .blue
        default:           return FondyColors.positive
        }
    }

    // MARK: - Actions

    func saveProfile() {
        guard isProfileValid, isProfileChanged else { return }
        isSavingProfile = true
        profileSaveError = nil
        Task {
            do {
                try await auth.updateProfile(name: draftName, email: draftEmail)
                await MainActor.run {
                    isSavingProfile = false
                    profileSaveSuccess = true
                    Haptics.success()
                }
            } catch {
                await MainActor.run {
                    isSavingProfile = false
                    profileSaveError = error.localizedDescription
                }
            }
        }
    }

    func savePassword() {
        guard isPasswordValid else { return }
        isSavingPassword = true
        passwordSaveError = nil
        Task {
            do {
                try await auth.changePassword(current: currentPassword, newPassword: newPassword)
                await MainActor.run {
                    isSavingPassword = false
                    passwordSaveSuccess = true
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                    Haptics.success()
                }
            } catch {
                await MainActor.run {
                    isSavingPassword = false
                    passwordSaveError = error.localizedDescription
                }
            }
        }
    }

    func revokeSession(_ session: ActiveSession) {
        isRevokingSession = true
        Task {
            try? await auth.revokeSession(session)
            await MainActor.run { isRevokingSession = false }
        }
    }

    func revokeAllOtherSessions() {
        isRevokingAll = true
        Task {
            try? await auth.revokeAllOtherSessions()
            await MainActor.run {
                isRevokingAll = false
                showRevokeAllConfirmation = false
                Haptics.success()
            }
        }
    }

    func deleteAccount() {
        isDeletingAccount = true
        Task {
            do {
                try await auth.deleteAccount()
                await MainActor.run { isDeletingAccount = false }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    deleteError = error.localizedDescription
                }
            }
        }
    }
}

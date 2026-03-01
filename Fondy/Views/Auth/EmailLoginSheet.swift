//
//  EmailLoginSheet.swift
//  Fondy
//
//  Email/password login form presented as a sheet
//  from the phone-first login screen.
//

import SwiftUI

/// Email and password login form presented as a sheet.
///
/// Provides the traditional email/password login path
/// as an alternative to phone-based authentication.
struct EmailLoginSheet: View {
    @Bindable var authState: AuthState
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: EmailLoginField?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.top, Spacing.lg)

                formFields
                    .padding(.top, Spacing.xxl)

                if let error = authState.errorMessage {
                    errorBanner(error)
                        .padding(.top, Spacing.md)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                logInButton
                    .padding(.bottom, Spacing.xxxl)
            }
            .padding(.horizontal, Spacing.pageMargin)
            .background(Color(.systemGroupedBackground))
            .animation(.springInteractive, value: authState.errorMessage != nil)
            .navigationTitle("Log in with email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                focusedField = .email
            }
        }
    }
}

// MARK: - Focus Enum

private enum EmailLoginField: Hashable {
    case email, password
}

// MARK: - Subviews

private extension EmailLoginSheet {

    // MARK: Header

    var headerSection: some View {
        Text("Enter your email and password to continue")
            .font(.subheadline)
            .foregroundStyle(FondyColors.labelSecondary)
            .lineSpacing(2)
    }

    // MARK: Form Fields

    var formFields: some View {
        VStack(spacing: Spacing.md) {
            // Email field
            HStack(spacing: Spacing.md) {
                Image(systemName: "envelope.fill")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .frame(width: 20)

                TextField("Email", text: $authState.email)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, 14)
            .background(
                FondyColors.fillQuaternary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        focusedField == .email ? Color.blue.opacity(0.4) : .clear,
                        lineWidth: 1.5
                    )
            )

            // Password field
            HStack(spacing: Spacing.md) {
                Image(systemName: "lock.fill")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .frame(width: 20)

                Group {
                    if authState.showPassword {
                        TextField("Password", text: $authState.password)
                    } else {
                        SecureField("Password", text: $authState.password)
                    }
                }
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit {
                    guard authState.isLoginValid else { return }
                    Task { await authState.login() }
                }

                Button {
                    Haptics.light()
                    authState.showPassword.toggle()
                } label: {
                    Image(systemName: authState.showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.body)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .accessibilityLabel(authState.showPassword ? "Hide password" : "Show password")
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, 14)
            .background(
                FondyColors.fillQuaternary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        focusedField == .password ? Color.blue.opacity(0.4) : .clear,
                        lineWidth: 1.5
                    )
            )
        }
        .animation(.springInteractive, value: focusedField)
    }

    // MARK: Error Banner

    func errorBanner(_ message: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.body)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.red.opacity(0.85),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }

    // MARK: Log In Button

    var logInButton: some View {
        Button {
            Haptics.medium()
            focusedField = nil
            Task {
                await authState.login()
                if authState.isAuthenticated {
                    dismiss()
                }
            }
        } label: {
            Group {
                if authState.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Log in")
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg + Spacing.xs)
            .background(
                authState.isLoginValid ? .blue : .blue.opacity(0.4),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!authState.isLoginValid || authState.isLoading)
        .animation(.springInteractive, value: authState.isLoginValid)
    }
}

// MARK: - Preview

#Preview {
    EmailLoginSheet(authState: AuthState())
}

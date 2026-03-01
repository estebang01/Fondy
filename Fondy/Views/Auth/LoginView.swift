//
//  LoginView.swift
//  Fondy
//
//  Login screen with email and password fields,
//  matching the clean light-themed design system.
//

import SwiftUI

/// Email/password login screen with a clean light background.
///
/// Features email and password text fields, error handling,
/// and a link to switch to phone sign-up.
struct LoginView: View {
    @Bindable var authState: AuthState

    @State private var isAppeared = false
    @FocusState private var focusedField: LoginField?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            headerSection
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            formFields
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            if let error = authState.errorMessage {
                errorBanner(error)
                    .padding(.top, Spacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            signUpLink
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 22)

            Spacer()

            logInButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .animation(.springInteractive, value: authState.errorMessage != nil)
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
            focusedField = .email
        }
    }
}

// MARK: - Focus Enum

private enum LoginField: Hashable {
    case email
    case password
}

// MARK: - Subviews

private extension LoginView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            authState.clearForm()
            withAnimation(.springGentle) {
                authState.currentScreen = .phoneSignUp
            }
        } label: {
            Image(systemName: "arrow.left")
                .font(.title3.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 40, height: 40)
                .liquidGlass(cornerRadius: 13)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Go back")
    }

    // MARK: Header

    var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Log in")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Enter your email and password to continue")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(2)
        }
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

    // MARK: Sign Up Link

    var signUpLink: some View {
        Button {
            Haptics.selection()
            authState.clearForm()
            withAnimation(.springGentle) {
                authState.currentScreen = .phoneSignUp
            }
        } label: {
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .foregroundStyle(.blue.opacity(0.7))
                Text("Sign up")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
        .accessibilityLabel("Don't have an account? Sign up")
    }

    // MARK: Log In Button

    var logInButton: some View {
        Button {
            Haptics.medium()
            focusedField = nil
            Task { await authState.login() }
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
        }
        .buttonStyle(PositiveButtonStyle())
        .disabled(!authState.isLoginValid || authState.isLoading)
    }
}

// MARK: - Preview

#Preview("Empty") {
    LoginView(authState: AuthState())
}

#Preview("Filled") {
    let state = AuthState()
    let _ = {
        state.email = "john@email.com"
        state.password = "password123"
    }()
    LoginView(authState: state)
}

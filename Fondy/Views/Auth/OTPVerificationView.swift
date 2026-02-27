//
//  OTPVerificationView.swift
//  Fondy
//
//  6-digit OTP code entry screen with individual digit boxes,
//  countdown timer, and auto-advance between fields.
//  Light theme matching the Revolut-style reference design.
//

import SwiftUI

/// OTP verification screen showing 6 individual digit boxes in a 3-dash-3 layout,
/// the full phone number, a resend countdown timer, and a login link.
struct OTPVerificationView: View {
    @Bindable var phoneAuth: PhoneAuthState
    var authState: AuthState

    @State private var isAppeared = false
    @State private var timerTask: Task<Void, Never>?
    @FocusState private var focusedIndex: Int?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            headerSection
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            otpBoxes
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            resendRow
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 22)

            loginLink
                .padding(.top, Spacing.sm)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 24)

            Spacer()
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
            focusedIndex = 0
            startCountdown()
        }
        .onDisappear {
            timerTask?.cancel()
        }
        .onChange(of: phoneAuth.isOTPComplete) { _, complete in
            if complete {
                Haptics.success()
                timerTask?.cancel()
                // Brief delay so the user sees all digits filled
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    withAnimation(.springGentle) {
                        phoneAuth.completeOTP()
                    }
                }
            }
        }
    }

    // MARK: - Timer

    private func startCountdown() {
        timerTask?.cancel()
        timerTask = Task {
            while phoneAuth.resendCountdown > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                phoneAuth.resendCountdown -= 1
            }
        }
    }
}

// MARK: - Subviews

private extension OTPVerificationView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            timerTask?.cancel()
            withAnimation(.springGentle) {
                phoneAuth.goBackToPhoneEntry()
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
            Text("6-digit code")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Code sent to \(phoneAuth.maskedPhone) unless you already have an account")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(2)
        }
    }

    // MARK: OTP Boxes — 3-dash-3 layout

    var otpBoxes: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                otpDigitBox(index: index)
            }

            Text("\u{2013}")
                .font(.title2.weight(.medium))
                .foregroundStyle(FondyColors.labelTertiary)
                .frame(width: Spacing.lg)

            ForEach(3..<6, id: \.self) { index in
                otpDigitBox(index: index)
            }
        }
    }

    // MARK: Single OTP Digit Box

    func otpDigitBox(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(FondyColors.fillQuaternary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            focusedIndex == index ? Color.blue.opacity(0.4) : .clear,
                            lineWidth: 1.5
                        )
                )

            if phoneAuth.otpDigits[index].isEmpty && focusedIndex == index {
                // Blinking cursor
                Rectangle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 2, height: 24)
                    .blinkingCursor()
            } else {
                Text(phoneAuth.otpDigits[index])
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
            }

            // Hidden text field for input capture
            TextField("", text: digitBinding(for: index))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedIndex, equals: index)
                .foregroundStyle(.clear)
                .tint(.clear)
                .accentColor(.clear)
                .frame(width: 1, height: 1)
                .opacity(0.01)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.8, contentMode: .fit)
        .onTapGesture {
            focusedIndex = index
        }
        .animation(.springInteractive, value: focusedIndex)
        .accessibilityLabel("Digit \(index + 1)")
        .accessibilityValue(phoneAuth.otpDigits[index].isEmpty ? "empty" : phoneAuth.otpDigits[index])
    }

    // MARK: Resend Row

    var resendRow: some View {
        Group {
            if phoneAuth.canResend {
                Button {
                    Haptics.light()
                    phoneAuth.resendCode()
                    startCountdown()
                } label: {
                    Text("Resend code")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
            } else {
                Text("Resend code in \(formattedCountdown)")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }
        }
    }

    var formattedCountdown: String {
        let minutes = phoneAuth.resendCountdown / 60
        let seconds = phoneAuth.resendCountdown % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: Login Link

    var loginLink: some View {
        Button {
            Haptics.selection()
            timerTask?.cancel()
            authState.clearForm()
            withAnimation(.springGentle) {
                authState.currentScreen = .login
            }
        } label: {
            HStack(spacing: 0) {
                Text("Already have an account? ")
                    .foregroundStyle(.blue.opacity(0.7))
                Text("Log in")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
        .accessibilityLabel("Already have an account? Log in")
    }

    // MARK: - Digit Binding

    /// Creates a binding that handles input, auto-advance, and backspace for each OTP field.
    func digitBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { phoneAuth.otpDigits[index] },
            set: { newValue in
                let filtered = newValue.filter(\.isNumber)

                if filtered.isEmpty {
                    // Backspace: clear current and move back
                    phoneAuth.otpDigits[index] = ""
                    if index > 0 {
                        focusedIndex = index - 1
                    }
                } else if filtered.count == 1 {
                    // Single digit entry
                    phoneAuth.otpDigits[index] = filtered
                    if index < 5 {
                        focusedIndex = index + 1
                    } else {
                        focusedIndex = nil
                    }
                } else {
                    // Paste: distribute digits across fields
                    let digits = Array(filtered.prefix(6))
                    for (i, digit) in digits.enumerated() {
                        let targetIndex = index + i
                        guard targetIndex < 6 else { break }
                        phoneAuth.otpDigits[targetIndex] = String(digit)
                    }
                    let nextIndex = min(index + digits.count, 5)
                    if phoneAuth.otpDigits[nextIndex].isEmpty {
                        focusedIndex = nextIndex
                    } else {
                        focusedIndex = nil
                    }
                }
            }
        )
    }
}

// MARK: - Blinking Cursor Modifier

private struct BlinkingCursorModifier: ViewModifier {
    @State private var visible = true

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
    }
}

private extension View {
    func blinkingCursor() -> some View {
        modifier(BlinkingCursorModifier())
    }
}

// MARK: - Preview

#Preview("Empty") {
    OTPVerificationView(
        phoneAuth: {
            let s = PhoneAuthState()
            s.phoneNumber = "90366027"
            s.step = .otpVerification
            return s
        }(),
        authState: AuthState()
    )
}

#Preview("Partial") {
    OTPVerificationView(
        phoneAuth: {
            let s = PhoneAuthState()
            s.phoneNumber = "90366027"
            s.step = .otpVerification
            s.otpDigits = ["2", "7", "6", "", "", ""]
            return s
        }(),
        authState: AuthState()
    )
}

//
//  NotificationsPromptView.swift
//  Fondy
//
//  "Don't miss a beat" push notifications opt-in screen
//  shown during sign-up after OTP verification.
//

import SwiftUI

/// Full-screen prompt asking the user to enable push notifications.
///
/// Displays a large headline, descriptive subtitle, bell illustration,
/// and two CTAs: "Enable push notifications" (primary) and "Not now" (secondary).
struct NotificationsPromptView: View {
    @Bindable var phoneAuth: PhoneAuthState

    @State private var isAppeared = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            headerSection
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            Spacer()

            bellIllustration
                .opacity(isAppeared ? 1 : 0)
                .scaleEffect(isAppeared ? 1 : 0.85)

            Spacer()

            buttonsSection
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension NotificationsPromptView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                phoneAuth.goBackFromCurrentStep()
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
            Text("Don't miss a beat")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Get notified about spending, security, wealth, market movements, discounts and deals, so you're always in the know")
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(3)
        }
    }

    // MARK: Bell Illustration

    var bellIllustration: some View {
        ZStack {
            // Phone shape
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.blue.opacity(0.08))
                .frame(width: 160, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2.5)
                )
                .overlay {
                    VStack(spacing: Spacing.md) {
                        notificationRow
                        notificationRow
                    }
                    .padding(.horizontal, Spacing.lg)
                }

            // Bell icon
            Image(systemName: "bell.fill")
                .font(.system(size: 36))
                .foregroundStyle(.blue.opacity(0.6))
                .offset(x: 50, y: 80)
                .rotationEffect(.degrees(-15))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    var notificationRow: some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(.blue.opacity(0.25))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(.blue.opacity(0.4))
                    .frame(width: 80, height: 8)
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(.blue.opacity(0.2))
                    .frame(width: 60, height: 6)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            .blue.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }

    // MARK: Buttons

    var buttonsSection: some View {
        VStack(spacing: Spacing.md) {
            // Primary CTA
            Button {
                Haptics.medium()
                // In production, request notification permissions here
                withAnimation(.springGentle) {
                    phoneAuth.completeNotifications()
                }
            } label: {
                Text("Enable push notifications")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .buttonStyle(PositiveButtonStyle())

            // Secondary CTA — dismiss / "not now" action
            Button {
                Haptics.light()
                withAnimation(.springGentle) {
                    phoneAuth.completeNotifications()
                }
            } label: {
                Text("Not now")
                    .font(.headline)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg + Spacing.xs)
                    .liquidGlass(cornerRadius: 16)
            }
            .buttonStyle(LiquidGlassButtonStyle())
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationsPromptView(phoneAuth: PhoneAuthState())
}

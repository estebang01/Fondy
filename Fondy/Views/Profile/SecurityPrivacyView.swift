//
//  SecurityPrivacyView.swift
//  Fondy
//
//  Security & privacy settings screen with biometric auth,
//  passcode, privacy controls, and session management.
//

import SwiftUI

struct SecurityPrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var faceIDEnabled = true
    @State private var screenLockEnabled = true
    @State private var analyticsEnabled = false
    @State private var personalisedAdsEnabled = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Security & privacy")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                securityCard

                privacyCard

                sessionsCard
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

// MARK: - Security Card

private extension SecurityPrivacyView {

    var securityCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Security")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                toggleRow(
                    icon: "faceid",
                    iconColor: .blue,
                    title: "Face ID",
                    subtitle: "Unlock app with Face ID",
                    isOn: $faceIDEnabled
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                toggleRow(
                    icon: "lock.fill",
                    iconColor: .blue,
                    title: "Screen lock",
                    subtitle: "Lock when leaving the app",
                    isOn: $screenLockEnabled
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                navigationRow(
                    icon: "key.fill",
                    iconColor: .blue,
                    title: "Change passcode"
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                navigationRow(
                    icon: "lock.rotation",
                    iconColor: .blue,
                    title: "Change password"
                )
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }
}

// MARK: - Privacy Card

private extension SecurityPrivacyView {

    var privacyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Privacy")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                toggleRow(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "Analytics",
                    subtitle: "Help improve Fondy with usage data",
                    isOn: $analyticsEnabled
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                toggleRow(
                    icon: "megaphone.fill",
                    iconColor: .blue,
                    title: "Personalised ads",
                    subtitle: "Show relevant offers and promotions",
                    isOn: $personalisedAdsEnabled
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                navigationRow(
                    icon: "hand.raised.fill",
                    iconColor: .blue,
                    title: "Manage permissions"
                )
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }
}

// MARK: - Sessions Card

private extension SecurityPrivacyView {

    var sessionsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Sessions")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                sessionRow(
                    device: "iPhone 16 Pro",
                    location: "Singapore",
                    isCurrent: true
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                sessionRow(
                    device: "MacBook Pro",
                    location: "Singapore",
                    isCurrent: false
                )
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }

    func sessionRow(device: String, location: String, isCurrent: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: isCurrent ? "iphone" : "laptopcomputer")
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(device)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Text(location)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.sm)

            if isCurrent {
                Text("Current")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        Color.green.opacity(0.12),
                        in: Capsule()
                    )
            }
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
    }
}

// MARK: - Shared Row Helpers

private extension SecurityPrivacyView {

    func toggleRow(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.sm)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.vertical, Spacing.md)
    }

    func navigationRow(icon: String, iconColor: Color, title: String) -> some View {
        Button {
            Haptics.light()
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
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
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SecurityPrivacyView()
    }
}

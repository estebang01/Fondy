//
//  AppSettingsView.swift
//  Fondy
//
//  App settings screen with appearance, notifications,
//  language, and general preferences.
//

import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var pushNotificationsEnabled = true
    @State private var emailNotificationsEnabled = false
    @State private var selectedAppearance: AppearanceMode = .system
    @State private var selectedCurrency = "SGD"

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("App settings")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                appearanceCard

                notificationsCard

                generalCard

                aboutCard
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

// MARK: - Appearance Mode

private enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

// MARK: - Appearance Card

private extension AppSettingsView {

    var appearanceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Appearance")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 30, height: 30)

                    Text("Theme")
                        .font(.body)
                        .foregroundStyle(FondyColors.labelPrimary)

                    Spacer(minLength: Spacing.sm)

                    Picker("", selection: $selectedAppearance) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.blue)
                }
                .padding(.vertical, Spacing.md)

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                settingsNavigationRow(
                    icon: "textformat.size",
                    iconColor: .blue,
                    title: "Text size",
                    value: "Default"
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

// MARK: - Notifications Card

private extension AppSettingsView {

    var notificationsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Notifications")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                settingsToggleRow(
                    icon: "bell.fill",
                    iconColor: .blue,
                    title: "Push notifications",
                    isOn: $pushNotificationsEnabled
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                settingsToggleRow(
                    icon: "envelope.fill",
                    iconColor: .blue,
                    title: "Email notifications",
                    isOn: $emailNotificationsEnabled
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

// MARK: - General Card

private extension AppSettingsView {

    var generalCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("General")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                settingsNavigationRow(
                    icon: "globe",
                    iconColor: .blue,
                    title: "Language",
                    value: "English"
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                settingsNavigationRow(
                    icon: "dollarsign.circle.fill",
                    iconColor: .blue,
                    title: "Default currency",
                    value: selectedCurrency
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                settingsNavigationRow(
                    icon: "map.fill",
                    iconColor: .blue,
                    title: "Country",
                    value: "Singapore"
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

// MARK: - About Card

private extension AppSettingsView {

    var aboutCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("About")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                settingsNavigationRow(
                    icon: "info.circle.fill",
                    iconColor: .blue,
                    title: "App version",
                    value: "1.0.0"
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                settingsNavigationRow(
                    icon: "star.fill",
                    iconColor: .blue,
                    title: "Rate the app",
                    value: nil
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                settingsNavigationRow(
                    icon: "ladybug.fill",
                    iconColor: .blue,
                    title: "Report a bug",
                    value: nil
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

// MARK: - Helpers

private extension AppSettingsView {

    func settingsToggleRow(icon: String, iconColor: Color, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)

            Text(title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer(minLength: Spacing.sm)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.vertical, Spacing.md)
    }

    func settingsNavigationRow(icon: String, iconColor: Color, title: String, value: String?) -> some View {
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

                if let value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

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
        AppSettingsView()
    }
}

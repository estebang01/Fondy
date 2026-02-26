//
//  PrivacySettingsView.swift
//  Fondy — Settings Module
//
//  Biometrics, screen lock, analytics, crash reporting, and data export.
//

import SwiftUI

struct PrivacySettingsView: View {
    @State private var viewModel: PrivacyViewModel
    @Environment(\.dismiss) private var dismiss

    init(store: any SettingsStoreProtocol, telemetry: any TelemetryServiceProtocol) {
        _viewModel = State(initialValue: PrivacyViewModel(store: store, telemetry: telemetry))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Privacy & Security")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                securityCard
                privacyCard
                dataCard
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { backButton }
        .alert("Data Export Queued", isPresented: $viewModel.exportComplete) {
            Button("OK") { viewModel.exportComplete = false }
        } message: {
            Text("Your data export has been prepared. You'll receive a download link at your registered email address within 24 hours.")
        }
    }

    // MARK: - Security Card

    private var securityCard: some View {
        SettingsCard(title: "Security") {
            SettingsToggleRow(
                icon: "faceid",
                iconColor: .blue,
                title: "Face ID / Touch ID",
                subtitle: "Unlock the app with biometrics",
                isOn: Binding(
                    get: { viewModel.biometricsEnabled },
                    set: { viewModel.biometricsEnabled = $0 }
                )
            )

            SettingsDivider()

            SettingsToggleRow(
                icon: "lock.fill",
                iconColor: .blue,
                title: "Screen Lock",
                subtitle: "Automatically lock when leaving the app",
                isOn: Binding(
                    get: { viewModel.screenLockEnabled },
                    set: { viewModel.screenLockEnabled = $0 }
                )
            )
        }
    }

    // MARK: - Privacy Card

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SettingsCard(title: "Privacy") {
                SettingsToggleRow(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "Analytics",
                    subtitle: "Help improve Fondy with anonymous usage data",
                    isOn: Binding(
                        get: { viewModel.analyticsEnabled },
                        set: { viewModel.analyticsEnabled = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    icon: "ladybug.fill",
                    iconColor: .blue,
                    title: "Crash Reports",
                    subtitle: "Automatically send crash logs to our team",
                    isOn: Binding(
                        get: { viewModel.crashReportingEnabled },
                        set: { viewModel.crashReportingEnabled = $0 }
                    )
                )
            }

            Text("Disabling analytics may limit our ability to identify and fix issues. We never sell your data.")
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)
                .lineSpacing(3)
        }
    }

    // MARK: - Data Card

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SettingsCard(title: "Your Data") {
                SettingsActionRow(
                    icon: "square.and.arrow.up",
                    iconColor: .blue,
                    title: "Export My Data",
                    subtitle: "Request a copy of all your account data",
                    isLoading: viewModel.isExporting
                ) {
                    viewModel.exportData()
                }
            }

            Text("Exports are delivered to your registered email. Allow up to 24 hours for processing.")
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)
                .lineSpacing(3)
        }
    }

    // MARK: - Toolbar

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
        PrivacySettingsView(store: MockSettingsStore(), telemetry: MockTelemetryService())
    }
}

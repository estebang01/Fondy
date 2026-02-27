//
//  SettingsRowComponents.swift
//  Fondy — Settings Module
//
//  Reusable, fully accessible row types that match the app's visual language.
//  All rows have a minimum 44pt touch target per Apple HIG.
//

import SwiftUI

// MARK: - Settings Card

/// Wraps a group of rows in the app's standard surfaceSecondary card.
struct SettingsCard<Content: View>: View {
    var title: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            if let title {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
            }
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
        }
    }
}

// MARK: - Settings Divider

/// Indented divider that aligns visually after the icon column.
struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 30 + Spacing.md + Spacing.lg)
    }
}

// MARK: - Settings Nav Row

/// A tappable navigation row: icon → title → optional value → chevron.
struct SettingsNavRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            guard !isDisabled, !isLoading else { return }
            Haptics.light()
            action?()
        } label: {
            HStack(spacing: Spacing.md) {
                iconView
                titleView
                Spacer(minLength: Spacing.sm)
                trailingView
            }
            .padding(.vertical, Spacing.md + Spacing.xxs)
            .contentShape(Rectangle())
            .opacity(isDisabled ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double-tap to open")
    }

    // MARK: Sub-views

    private var iconView: some View {
        Image(systemName: icon)
            .font(.body.weight(.semibold))
            .foregroundStyle(iconColor)
            .frame(width: 30, height: 30)
            .accessibilityHidden(true)
    }

    private var titleView: some View {
        Text(title)
            .font(.body)
            .foregroundStyle(FondyColors.labelPrimary)
    }

    @ViewBuilder
    private var trailingView: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
        } else {
            HStack(spacing: Spacing.xs) {
                if let value {
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
        }
    }

    private var accessibilityLabel: String {
        var label = title
        if let value { label += ", \(value)" }
        return label
    }
}

// MARK: - Settings Toggle Row

/// A row with an icon, title, optional subtitle, and a system toggle.
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }
            }

            Spacer(minLength: Spacing.sm)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
                .onChange(of: isOn) { Haptics.selection() }
        }
        .padding(.vertical, Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityHint("Double-tap to toggle")
    }
}

// MARK: - Settings Action Row

/// A tappable row that triggers a local action (not navigation).
/// Optional loading state disables interaction and shows a spinner.
struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            guard !isLoading else { return }
            Haptics.medium()
            action()
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(FondyColors.labelPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(FondyColors.labelSecondary)
                    }
                }

                Spacer(minLength: Spacing.sm)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
            }
            .padding(.vertical, Spacing.md + Spacing.xxs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

// MARK: - Settings Destructive Button

/// A full-width red button for irreversible actions (sign out, delete account).
struct SettingsDestructiveButton: View {
    let title: String
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            guard !isLoading else { return }
            Haptics.medium()
            action()
        } label: {
            HStack {
                Spacer()
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .tint(.red)
                } else {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .padding(.vertical, Spacing.lg)
            .liquidGlass(cornerRadius: Spacing.cardRadius)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

// MARK: - Settings Info Row

/// A read-only label→value pair with no interaction.
struct SettingsInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Settings Text Field

/// Styled text field that matches the app's form aesthetic.
struct SettingsTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                }
            }
            .font(.body)
            .foregroundStyle(FondyColors.labelPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(FondyColors.separator, lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Inline Error Banner

/// Compact inline error message shown below form fields.
struct SettingsErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
                .accessibilityHidden(true)
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Success Banner

struct SettingsSuccessBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.positive)
                .accessibilityHidden(true)
            Text(message)
                .font(.caption)
                .foregroundStyle(FondyColors.positive)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FondyColors.positive.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

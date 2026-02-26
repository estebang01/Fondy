//
//  AppearanceSettingsView.swift
//  Fondy — Settings Module
//
//  Theme selection with visual preview cards for System / Light / Dark.
//  Apply selection at the app root via:
//      .preferredColorScheme(store.appTheme.colorScheme)
//

import SwiftUI

struct AppearanceSettingsView: View {
    @State private var viewModel: AppearanceViewModel
    @Environment(\.dismiss) private var dismiss

    init(store: any SettingsStoreProtocol) {
        _viewModel = State(initialValue: AppearanceViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Appearance")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                themeSection
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { backButton }
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Theme")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            // Three visual theme cards side by side
            HStack(spacing: Spacing.md) {
                ForEach(AppTheme.allCases) { theme in
                    themeCard(theme)
                }
            }

            Text("The app's color scheme will update immediately. System follows your device's appearance settings.")
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)
                .lineSpacing(3)
        }
    }

    private func themeCard(_ theme: AppTheme) -> some View {
        let isSelected = viewModel.selectedTheme == theme

        return Button {
            withAnimation(.springGentle) {
                viewModel.selectedTheme = theme
            }
        } label: {
            VStack(spacing: Spacing.sm) {
                // Preview swatch
                themePreviewSwatch(theme)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )

                HStack(spacing: Spacing.xs) {
                    Image(systemName: theme.icon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(isSelected ? .blue : FondyColors.labelSecondary)
                        .accessibilityHidden(true)

                    Text(theme.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isSelected ? .blue : FondyColors.labelSecondary)
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FondyColors.labelTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("\(theme.rawValue) theme\(isSelected ? ", selected" : "")")
    }

    private func themePreviewSwatch(_ theme: AppTheme) -> some View {
        let bg: Color = theme == .dark ? Color(.systemGray6) : (theme == .light ? .white : Color(.secondarySystemBackground))
        let text: Color = theme == .dark ? .white : .black

        return VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 4)
                .fill(text.opacity(0.08))
                .frame(height: 8)
            RoundedRectangle(cornerRadius: 4)
                .fill(text.opacity(0.05))
                .frame(height: 6)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.blue.opacity(0.6))
                .frame(height: 18)
        }
        .padding(Spacing.sm)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(bg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
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
        AppearanceSettingsView(store: MockSettingsStore())
    }
}

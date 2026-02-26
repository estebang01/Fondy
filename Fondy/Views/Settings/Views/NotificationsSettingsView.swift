//
//  NotificationsSettingsView.swift
//  Fondy — Settings Module
//
//  Per-category notification toggles with Enable All / Disable All controls.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @State private var viewModel: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss

    init(store: any SettingsStoreProtocol) {
        _viewModel = State(initialValue: NotificationsViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Notifications")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                categoriesCard
                bulkActionsRow
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

    // MARK: - Categories Card

    private var categoriesCard: some View {
        SettingsCard(title: "Preferences") {
            ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                if index > 0 { SettingsDivider() }
                categoryToggleRow(category)
            }
        }
    }

    private func categoryToggleRow(_ category: NotificationCategory) -> some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(category.title)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Text(category.description)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .lineSpacing(2)
            }

            Spacer(minLength: Spacing.sm)

            Toggle("", isOn: Binding(
                get: { category.isEnabled },
                set: { _ in viewModel.toggle(categoryId: category.id) }
            ))
            .labelsHidden()
            .tint(.blue)
        }
        .padding(.vertical, Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(category.title)
        .accessibilityValue(category.isEnabled ? "On" : "Off")
        .accessibilityHint(category.description)
    }

    // MARK: - Bulk Actions

    private var bulkActionsRow: some View {
        HStack(spacing: Spacing.md) {
            Button {
                withAnimation(.springGentle) { viewModel.enableAll() }
            } label: {
                Text("Enable All")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .liquidGlass(tint: .blue, cornerRadius: Spacing.cardRadius, disabled: viewModel.allEnabled)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .disabled(viewModel.allEnabled)

            Button {
                withAnimation(.springGentle) { viewModel.disableAll() }
            } label: {
                Text("Disable All")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .liquidGlass(cornerRadius: Spacing.cardRadius, disabled: viewModel.noneEnabled)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .disabled(viewModel.noneEnabled)
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
        NotificationsSettingsView(store: MockSettingsStore())
    }
}

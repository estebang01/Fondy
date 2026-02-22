//
//  FilterPickerSheet.swift
//  Fondy
//
//  Reusable bottom sheet for single-selection filter/picker.
//

import SwiftUI

struct FilterPickerSheet: View {
    let title: String
    let options: [String]
    let selected: String
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Drag indicator
            HStack {
                Spacer()
                Capsule()
                    .fill(FondyColors.fillTertiary)
                    .frame(width: 36, height: 4)
                Spacer()
            }
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.lg)

            VStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    Button {
                        Haptics.selection()
                        onSelect(option)
                        dismiss()
                    } label: {
                        HStack {
                            Text(option)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)
                            Spacer()
                            if option == selected {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.blue)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md + Spacing.xxs)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel(option)
                    .accessibilityAddTraits(option == selected ? [.isSelected, .isButton] : .isButton)

                    if index < options.count - 1 {
                        Divider()
                            .padding(.leading, Spacing.lg)
                    }
                }
            }
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .padding(.horizontal, Spacing.pageMargin)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selected = "Annual"
    FilterPickerSheet(
        title: "Period",
        options: ["Annual", "Quarterly", "Monthly"],
        selected: selected
    ) { selected = $0 }
}

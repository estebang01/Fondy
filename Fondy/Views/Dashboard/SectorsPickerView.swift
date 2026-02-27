//
//  SectorsPickerView.swift
//  Fondy
//
//  Full-screen sector picker with search bar, checkboxes, and Apply button.
//  Pushed from AdvancedSearchView "See all sectors".
//

import SwiftUI

struct SectorsPickerView: View {
    @Binding var selectedSectors: Set<StockSector>
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredSectors: [StockSector] {
        if searchText.isEmpty {
            return StockSector.allCases
        }
        return StockSector.allCases.filter {
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text("Sectors")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.top, Spacing.lg)
                        .padding(.bottom, Spacing.lg)

                    // Search bar
                    SearchBarField(text: $searchText, placeholder: "Search")
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.bottom, Spacing.xl)

                    // Sector list card
                    sectorsList
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .overlay(alignment: .bottom) {
            applyButton
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sectors List

private extension SectorsPickerView {

    var sectorsList: some View {
        let sectors = filteredSectors
        return VStack(spacing: 0) {
            ForEach(Array(sectors.enumerated()), id: \.element.id) { index, sector in
                sectorRow(sector)

                if index < sectors.count - 1 {
                    Divider()
                        .padding(.leading, 44 + Spacing.md + Spacing.lg)
                }
            }
        }
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }

    func sectorRow(_ sector: StockSector) -> some View {
        Button {
            Haptics.selection()
            if selectedSectors.contains(sector) {
                selectedSectors.remove(sector)
            } else {
                selectedSectors.insert(sector)
            }
        } label: {
            HStack(spacing: Spacing.md) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(selectedSectors.contains(sector) ? Color.blue : FondyColors.labelTertiary, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                        .background(
                            selectedSectors.contains(sector)
                                ? RoundedRectangle(cornerRadius: 6, style: .continuous).fill(.blue)
                                : nil
                        )

                    if selectedSectors.contains(sector) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                // Sector icon
                Image(systemName: sector.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .liquidGlass(tint: .blue, cornerRadius: 50)

                Text(sector.rawValue)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md + 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Apply Button

private extension SectorsPickerView {

    var applyButton: some View {
        Button {
            Haptics.medium()
            dismiss()
        } label: {
            Text("Apply")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
        }
        .buttonStyle(PositiveButtonStyle(cornerRadius: 14))
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.bottom, Spacing.xl)
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .center
            )
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SectorsPickerView(selectedSectors: .constant([.technology, .healthcare]))
    }
}

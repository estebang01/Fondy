//
//  CountryPickerSheet.swift
//  Fondy
//
//  Sheet presenting a searchable list of countries with remote PNG flags (circular),
//  name, and dial code.
//

import SwiftUI

// MARK: - Flag UI

/// Circular remote flag image with a clean placeholder.
///
/// Loads flag PNGs from flagcdn.com and clips them into a circle.
/// Reusable anywhere a country flag is needed.
struct FlagCircle: View {
    let url: URL?
    var size: CGFloat = 34

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                placeholder

            case .empty:
                placeholder

            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Circle()
            .fill(Color.primary.opacity(0.08))
            .overlay(
                Image(systemName: "flag")
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundStyle(.secondary)
            )
    }
}

// MARK: - Country Picker Sheet

/// A scrollable, searchable sheet for selecting a country dial code.
///
/// Uses the unified `Country` model from `PhoneAuthState` and renders
/// remote PNG flags via `FlagCircle`.
struct CountryPickerSheet: View {
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredCountries: [Country] {
        if searchText.isEmpty { return Country.all }
        let query = searchText.lowercased()
        return Country.all.filter {
            $0.name.lowercased().contains(query)
            || $0.dialCode.contains(query)
            || $0.id.lowercased().contains(query)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    Haptics.selection()
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack(spacing: Spacing.md) {
                        FlagCircle(url: country.flagURL, size: 34)

                        Text(country.name)
                            .font(.body)
                            .foregroundStyle(FondyColors.labelPrimary)

                        Spacer()

                        Text(country.dialCode)
                            .font(.body)
                            .foregroundStyle(FondyColors.labelSecondary)

                        if country == selectedCountry {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .listRowBackground(FondyColors.surfaceSecondary)
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search country")
            .navigationTitle("Country code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("CountryPicker") {
    CountryPickerSheet(selectedCountry: .constant(.unitedStates))
}

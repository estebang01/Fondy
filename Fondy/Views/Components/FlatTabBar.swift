//
//  FlatTabBar.swift
//  Fondy
//
//  Horizontally scrollable tab bar where the selected item floats on a
//  white rounded-rectangle card. No outer container — tabs sit directly
//  on the page background. Use this for top-level section navigation
//  (e.g. Watchlist · Converter · Alerts · Orders).
//

import SwiftUI

// MARK: - FlatTabBar

struct FlatTabBar<Tab: Hashable & CaseIterable & Identifiable & RawRepresentable>: View
    where Tab.RawValue == String, Tab.AllCases: RandomAccessCollection
{
    @Binding var selected: Tab
    @Namespace private var selectionNS

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xxs) {
                ForEach(Tab.allCases) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.trailing, Spacing.pageMargin)
            .padding(.vertical, Spacing.xs)
        }
        .scrollClipDisabled(true)
    }

    // MARK: - Tab Button

    private func tabButton(for tab: Tab) -> some View {
        let isSelected = selected == tab
        return Button {
            Haptics.selection()
            withAnimation(.springInteractive) { selected = tab }
        } label: {
            Text(tab.rawValue)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? FondyColors.labelPrimary : FondyColors.labelSecondary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm + Spacing.xxs)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: Spacing.md, style: .continuous)
                            .fill(FondyColors.background)
                            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                            .matchedGeometryEffect(id: "flat_selection", in: selectionNS)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
        .accessibilityLabel(tab.rawValue)
    }
}

// MARK: - Preview

private enum FavouritesTab: String, CaseIterable, Identifiable {
    case watchlist  = "Watchlist"
    case converter  = "Converter"
    case alerts     = "Alerts"
    case orders     = "Orders"
    var id: String { rawValue }
}

#Preview {
    @Previewable @State var selected: FavouritesTab = .watchlist
    VStack(alignment: .leading, spacing: Spacing.lg) {
        FlatTabBar(selected: $selected)
    }
    .padding(.top, Spacing.xxl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color(.systemGroupedBackground))
}


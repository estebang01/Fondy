//
//  SegmentedTabBar.swift
//  Fondy
//
//  Reusable pill-style segmented control.
//

import SwiftUI

struct SegmentedTabBar<Tab: Hashable & CaseIterable & Identifiable & RawRepresentable>: View
    where Tab.RawValue == String, Tab.AllCases: RandomAccessCollection
{
    @Binding var selected: Tab
    @Namespace private var selectionNS

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(Tab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(Spacing.xxs)
        .background(FondyColors.fillQuaternary, in: Capsule())
    }

    private func tabButton(for tab: Tab) -> some View {
        let isSelected = selected == tab
        return Button {
            Haptics.selection()
            withAnimation(.springInteractive) { selected = tab }
        } label: {
            Text(tab.rawValue)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                // Use primary label when selected so it contrasts the fill
                .foregroundStyle(isSelected ? FondyColors.labelPrimary : FondyColors.labelSecondary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(FondyColors.background)
                            // Subtle shadow makes the selected pill "lift"
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
                            .matchedGeometryEffect(id: "seg_selection", in: selectionNS)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
        .accessibilityLabel(tab.rawValue)
    }
}

// MARK: - Preview

private enum SampleTab: String, CaseIterable, Identifiable {
    case annual = "Annual"
    case quarterly = "Quarterly"
    var id: String { rawValue }
}

#Preview {
    @Previewable @State var selected: SampleTab = .annual
    SegmentedTabBar(selected: $selected)
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.lg)
        .background(Color(.systemGroupedBackground))
}

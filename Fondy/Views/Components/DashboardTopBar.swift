//
//  DashboardTopBar.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 11/02/26.
//

import SwiftUI

struct DashboardTopBar: View {

    var body: some View {
        HStack {
            avatarButton
            Spacer()
            HStack(spacing: Spacing.sm) {
                iconButton(name: "star.fill", accessibilityLabel: "Favourites")
                iconButton(name: "bell.fill", accessibilityLabel: "Notifications")
            }
        }
    }

    // MARK: - Subviews

    private var avatarButton: some View {
        Button {
            Haptics.light()
        } label: {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 38))
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }

    private func iconButton(name: String, accessibilityLabel: String) -> some View {
        Button {
            Haptics.light()
        } label: {
            Image(systemName: name)
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                // 44×44 minimum touch target (HIG)
                .frame(width: Spacing.iconSize, height: Spacing.iconSize)
                .background(FondyColors.fillQuaternary, in: Circle())
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview

#Preview {
    DashboardTopBar()
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.lg)
}

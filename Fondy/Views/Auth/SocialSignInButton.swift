//
//  SocialSignInButton.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI

/// Social sign-in provider enum.
enum SocialProvider {
    case apple
    case google

    var label: String {
        switch self {
        case .apple: "Sign in with Apple"
        case .google: "Sign in with Google"
        }
    }

    var iconName: String {
        switch self {
        case .apple: "apple.logo"
        case .google: "g.circle.fill"
        }
    }
}

/// A bordered capsule button for social sign-in (Apple / Google).
struct SocialSignInButton: View {
    let provider: SocialProvider
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            Haptics.medium()
            action()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: provider.iconName)
                    .font(.body.weight(.medium))
                Text(provider.label)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(provider.label)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        SocialSignInButton(provider: .apple) {}
        SocialSignInButton(provider: .google) {}
    }
    .padding(Spacing.xxl)
    .background(.black)
}

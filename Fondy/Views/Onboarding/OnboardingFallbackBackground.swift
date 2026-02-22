//
//  OnboardingFallbackBackground.swift
//  Fondy
//
//  Warm-toned ambient gradient used as a placeholder background
//  when the onboarding hero image asset has not been added yet.
//

import SwiftUI

/// Rich animated gradient background that mimics the warm cocktail-bar
/// aesthetic of the design reference.
/// 
struct OnboardingFallbackBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [Float(0.5 + sin(phase) * 0.08), 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .brown.opacity(0.8), .orange.opacity(0.5), .brown.opacity(0.6),
                .brown.opacity(0.6), .yellow.opacity(0.35), .orange.opacity(0.4),
                .black, .black, .black
            ]
        )
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFallbackBackground()
        .ignoresSafeArea()
}

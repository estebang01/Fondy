//
//  SplashView.swift
//  Fondy
//
//  Full-screen animated splash shown on every cold launch.
//  Displays the Fondy wordmark on a dark mesh gradient, then fades
//  out once the session check completes (min 1.2 s for legibility).
//

import SwiftUI

struct SplashView: View {

    // MARK: - Animation State

    @State private var logoScale: CGFloat = 0.72
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var dotsOpacity: Double = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer()

                logoGroup

                Spacer()

                loadingDots
                    .padding(.bottom, 56)
            }
        }
        .ignoresSafeArea()
        .onAppear(perform: runAnimation)
    }
}

// MARK: - Background

private extension SplashView {

    var background: some View {
        ZStack {
            // Deep base
            Color(red: 0.05, green: 0.05, blue: 0.08)

            // Radial blobs — mirrors the auth screen mesh gradient
            RadialGradient(
                colors: [Color(red: 0.18, green: 0.12, blue: 0.45).opacity(0.75), .clear],
                center: .init(x: 0.15, y: 0.25),
                startRadius: 0,
                endRadius: 340
            )
            RadialGradient(
                colors: [Color(red: 0.05, green: 0.22, blue: 0.45).opacity(0.65), .clear],
                center: .init(x: 0.85, y: 0.15),
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                colors: [Color(red: 0.35, green: 0.08, blue: 0.45).opacity(0.55), .clear],
                center: .init(x: 0.5, y: 0.85),
                startRadius: 0,
                endRadius: 360
            )
        }
    }
}

// MARK: - Logo Group

private extension SplashView {

    var logoGroup: some View {
        VStack(spacing: 20) {
            logoMark
            tagline
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }

    var logoMark: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.38, green: 0.48, blue: 1.0),
                                Color(red: 0.55, green: 0.28, blue: 0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: Color(red: 0.38, green: 0.48, blue: 1.0).opacity(0.45), radius: 28, y: 8)

                Image(systemName: "f.cursive")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .overlay(shimmerOverlay)
                    .clipShape(Rectangle())
            }

            // Wordmark
            Text("Fondy")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .tracking(1.5)
                .overlay(shimmerOverlay)
                .clipShape(Rectangle())
        }
    }

    /// Subtle left-to-right shimmer that sweeps once on appear.
    var shimmerOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .white.opacity(0.35), location: 0.45),
                .init(color: .white.opacity(0.55), location: 0.5),
                .init(color: .white.opacity(0.35), location: 0.55),
                .init(color: .clear, location: 1)
            ],
            startPoint: .init(x: shimmerOffset / 300, y: 0),
            endPoint:   .init(x: shimmerOffset / 300 + 0.6, y: 0)
        )
        .blendMode(.overlay)
    }

    var tagline: some View {
        Text("Your money, your world.")
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.52))
            .tracking(0.4)
            .opacity(taglineOpacity)
    }
}

// MARK: - Loading Dots

private extension SplashView {

    var loadingDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 6, height: 6)
                    .scaleEffect(dotsOpacity > 0 ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.18),
                        value: dotsOpacity
                    )
            }
        }
        .opacity(dotsOpacity)
    }
}

// MARK: - Animation Sequence

private extension SplashView {

    func runAnimation() {
        // 1. Spring in the logo
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // 2. Shimmer sweep
        withAnimation(.easeInOut(duration: 0.9).delay(0.45)) {
            shimmerOffset = 260
        }

        // 3. Tagline fade in
        withAnimation(.easeInOut(duration: 0.5).delay(0.55)) {
            taglineOpacity = 1.0
        }

        // 4. Loading dots pulse
        withAnimation(.easeInOut(duration: 0.4).delay(0.75)) {
            dotsOpacity = 1.0
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
}

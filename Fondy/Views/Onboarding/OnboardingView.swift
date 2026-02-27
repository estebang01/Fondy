//
//  OnboardingView.swift
//  Fondy
//
//  Hero onboarding screen with a full-bleed background image,
//  gradient overlay, branding, headline, and a single CTA button.
//

import SwiftUI

/// Full-screen onboarding welcome view matching the Blackbird-style hero layout.
///
/// Displays a full-bleed background image with a bottom gradient overlay,
/// brand logo, headline text, subtitle, and a prominent "Go" CTA button.
struct OnboardingView: View {
    /// Called when the user taps the CTA button.
    var onContinue: () -> Void

    @State private var isAppeared = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundImage
            gradientOverlay
            contentStack
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.springGentle.delay(0.15)) {
                isAppeared = true
            }
        }
    }

    // MARK: - Background

    private var backgroundImage: some View {
        GeometryReader { geo in
            if UIImage(named: "onboarding_hero") != nil {
                Image("onboarding_hero")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            } else {
                // Fallback gradient when image asset is not yet provided
                OnboardingFallbackBackground()
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black.opacity(0.3), location: 0.35),
                .init(color: .black.opacity(0.85), location: 0.6),
                .init(color: .black, location: 0.78)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Content

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            brandRow
                .padding(.bottom, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            headlineText
                .padding(.bottom, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            subtitleText
                .padding(.bottom, Spacing.xxxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 24)

            goButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.bottom, Spacing.xxxl + Spacing.lg)
    }
}

// MARK: - Subviews

private extension OnboardingView {

    /// Brand icon + name row.
    var brandRow: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .accessibilityHidden(true)

            Text("FONDY")
                .font(.subheadline.weight(.bold))
                .tracking(3)
                .foregroundStyle(.white)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Fondy")
    }

    /// Two-line hero headline.
    var headlineText: some View {
        Text("The better\nway to pay")
            .font(.system(size: 44, weight: .bold, design: .default))
            .lineSpacing(2)
            .foregroundStyle(.white)
            .accessibilityAddTraits(.isHeader)
    }

    /// Single-line subtitle beneath the headline.
    var subtitleText: some View {
        Text("Earn points & never wait for the check")
            .font(.body)
            .foregroundStyle(.white.opacity(0.65))
    }

    /// Full-width Liquid Glass CTA button.
    /// Uses no color tint intentionally — the glass effect is translucent on
    /// the dark hero background, creating a frosted-glass "Get started" button.
    var goButton: some View {
        Button {
            Haptics.medium()
            onContinue()
        } label: {
            Text("Go")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .liquidGlass(cornerRadius: 16)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Get started")
    }
}

// MARK: - Preview

#Preview {
    OnboardingView {
        // CTA action
    }
    .preferredColorScheme(.dark)
}

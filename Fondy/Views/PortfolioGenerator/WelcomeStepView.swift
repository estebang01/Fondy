//
//  WelcomeStepView.swift
//  Fondy
//
//  Hero introduction screen for the AI portfolio generator flow.
//  Animated illustration + headline + CTA button.
//

import SwiftUI

/// Welcome screen with animated illustration and "Get Started" CTA.
struct WelcomeStepView: View {
    let state: PortfolioGeneratorState
    var onDismiss: () -> Void

    @State private var isAppeared = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var orbitAngle: Double = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                closeButton
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.sm)

            Spacer()

            illustration
                .opacity(isAppeared ? 1 : 0)
                .scaleEffect(isAppeared ? 1 : 0.85)

            Spacer()

            textContent
                .padding(.horizontal, Spacing.pageMargin)

            ctaButton
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl + Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.springGentle.delay(0.15)) {
                isAppeared = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
        }
    }
}

// MARK: - Subviews

private extension WelcomeStepView {

    // MARK: Close Button

    var closeButton: some View {
        Button {
            Haptics.light()
            onDismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelSecondary)
                .frame(width: 36, height: 36)
                .liquidGlass(cornerRadius: 12)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Close")
    }

    // MARK: Illustration

    var illustration: some View {
        ZStack {
            // Soft glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.blue.opacity(0.12), .blue.opacity(0.0)],
                        center: .center,
                        startRadius: 30,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)

            // Orbiting icons
            orbitingIcon(systemName: "chart.line.uptrend.xyaxis", offset: 80, baseAngle: 0)
            orbitingIcon(systemName: "dollarsign.circle.fill", offset: 80, baseAngle: 90)
            orbitingIcon(systemName: "shield.fill", offset: 80, baseAngle: 180)
            orbitingIcon(systemName: "globe.americas.fill", offset: 80, baseAngle: 270)

            // Central icon
            Image(systemName: "sparkles")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(pulseScale)
        }
        .frame(width: 240, height: 240)
    }

    func orbitingIcon(systemName: String, offset: CGFloat, baseAngle: Double) -> some View {
        let angle = Angle.degrees(baseAngle + orbitAngle)
        let x = cos(angle.radians) * offset
        let y = sin(angle.radians) * offset

        return Image(systemName: systemName)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(.blue.opacity(0.5))
            .offset(x: x, y: y)
    }

    // MARK: Text Content

    var textContent: some View {
        VStack(spacing: Spacing.md) {
            Text("Build Your\nAI Portfolio")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            Text("Answer a few questions and our AI will create a personalized investment portfolio tailored to your goals.")
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)
        }
    }

    // MARK: CTA Button

    var ctaButton: some View {
        Button {
            Haptics.medium()
            withAnimation(.springGentle) {
                state.next()
            }
        } label: {
            Text("Get Started")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .liquidGlass(tint: .blue, cornerRadius: 16)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Get started building your portfolio")
    }
}

// MARK: - Preview

#Preview {
    WelcomeStepView(state: PortfolioGeneratorState(), onDismiss: {})
}

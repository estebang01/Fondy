//
//  HolographicGradient.swift
//  Fondy
//
//  Iridescent / holographic gradient components for the AI portfolio flow.
//  Animated rainbow pastel colors that flow like the GPT-5 input style.
//

import SwiftUI

// MARK: - Holographic Colors

/// Pastel iridescent color palette for AI-themed UI.
enum HolographicColors {
    static let pastelBlue = Color(red: 0.60, green: 0.78, blue: 1.0)
    static let pastelPink = Color(red: 1.0, green: 0.70, blue: 0.85)
    static let pastelPurple = Color(red: 0.78, green: 0.65, blue: 1.0)
    static let pastelMint = Color(red: 0.60, green: 0.95, blue: 0.85)
    static let pastelPeach = Color(red: 1.0, green: 0.80, blue: 0.65)
    static let pastelLavender = Color(red: 0.82, green: 0.72, blue: 1.0)

    /// Full rainbow spectrum for holographic gradients.
    static let spectrum: [Color] = [
        pastelBlue, pastelMint, pastelPeach,
        pastelPink, pastelPurple, pastelLavender, pastelBlue,
    ]

    /// Compact version for smaller elements.
    static let compact: [Color] = [
        pastelBlue, pastelPink, pastelPurple, pastelMint,
    ]
}

// MARK: - Animated Holographic Border

/// An animated iridescent border that rotates around a rounded rectangle.
struct HolographicBorder: View {
    var cornerRadius: CGFloat = 16
    var lineWidth: CGFloat = 2.5
    var glowRadius: CGFloat = 8

    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    AngularGradient(
                        colors: HolographicColors.spectrum,
                        center: .center,
                        angle: .degrees(rotation)
                    ),
                    lineWidth: lineWidth
                )
                .blur(radius: 0.5)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            AngularGradient(
                                colors: HolographicColors.spectrum,
                                center: .center,
                                angle: .degrees(rotation)
                            ),
                            lineWidth: lineWidth * 0.6
                        )
                )
                .shadow(
                    color: HolographicColors.pastelPurple.opacity(0.3),
                    radius: glowRadius
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Animated Holographic Circle Border

/// An animated iridescent circular border.
struct HolographicCircleBorder: View {
    var lineWidth: CGFloat = 2.5
    var glowRadius: CGFloat = 6

    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: HolographicColors.spectrum,
                    center: .center,
                    angle: .degrees(rotation)
                ),
                lineWidth: lineWidth
            )
            .overlay(
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: HolographicColors.spectrum,
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: lineWidth * 0.5
                    )
                    .blur(radius: glowRadius * 0.5)
            )
            .shadow(
                color: HolographicColors.pastelPurple.opacity(0.25),
                radius: glowRadius
            )
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Holographic Glow Background

/// A soft iridescent glow for backgrounds.
struct HolographicGlow: View {
    var size: CGFloat = 300
    @State private var phase: Double = 0

    var body: some View {
        ZStack {
            ellipseBlob(color: HolographicColors.pastelBlue, offset: blobOffset(angle: phase, radius: 30))
            ellipseBlob(color: HolographicColors.pastelPink, offset: blobOffset(angle: phase + 120, radius: 25))
            ellipseBlob(color: HolographicColors.pastelPurple, offset: blobOffset(angle: phase + 240, radius: 28))
            ellipseBlob(color: HolographicColors.pastelMint, offset: blobOffset(angle: phase + 60, radius: 20))
        }
        .frame(width: size, height: size)
        .blur(radius: size * 0.25)
        .opacity(0.6)
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }

    private func ellipseBlob(color: Color, offset: CGPoint) -> some View {
        Ellipse()
            .fill(color.opacity(0.5))
            .frame(width: size * 0.6, height: size * 0.45)
            .offset(x: offset.x, y: offset.y)
    }

    private func blobOffset(angle: Double, radius: CGFloat) -> CGPoint {
        CGPoint(
            x: cos(angle * .pi / 180) * radius,
            y: sin(angle * .pi / 180) * radius
        )
    }
}

// MARK: - Holographic Capsule Progress Bar

/// Segmented progress bar with iridescent fill.
struct HolographicProgressBar: View {
    let totalSteps: Int
    let currentStep: Int

    @State private var rotation: Double = 0

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? holographicFill as! Color : Color(FondyColors.fillTertiary))
                    .frame(height: 4)
            }
        }
        .animation(.springGentle, value: currentStep)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    private var holographicFill: some ShapeStyle {
        LinearGradient(
            colors: HolographicColors.compact,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Holographic Button Style

/// A button that wraps content with a holographic animated border.
struct HolographicButtonContent: View {
    let text: String
    var icon: String? = nil
    var cornerRadius: CGFloat = 16

    @State private var rotation: Double = 0

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(.headline)
        .foregroundStyle(FondyColors.labelPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg + Spacing.xs)
        .background(FondyColors.surfaceSecondary, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            HolographicBorder(cornerRadius: cornerRadius, lineWidth: 2, glowRadius: 6)
        )
    }
}

// MARK: - Holographic Mesh Gradient Background

/// An animated mesh-like gradient background for hero screens.
struct HolographicMeshBackground: View {
    @State private var phase: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.systemGroupedBackground)

                // Top-right blob
                Circle()
                    .fill(HolographicColors.pastelBlue.opacity(0.25))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(
                        x: geo.size.width * 0.25 + cos(phase * .pi / 180) * 20,
                        y: -geo.size.height * 0.15 + sin(phase * .pi / 180) * 15
                    )

                // Center-left blob
                Circle()
                    .fill(HolographicColors.pastelPink.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(
                        x: -geo.size.width * 0.3 + sin(phase * .pi / 180) * 15,
                        y: geo.size.height * 0.05 + cos(phase * .pi / 180) * 20
                    )

                // Bottom blob
                Circle()
                    .fill(HolographicColors.pastelPurple.opacity(0.18))
                    .frame(width: 280, height: 280)
                    .blur(radius: 75)
                    .offset(
                        x: geo.size.width * 0.1 + cos((phase + 120) * .pi / 180) * 18,
                        y: geo.size.height * 0.3 + sin((phase + 120) * .pi / 180) * 12
                    )

                // Mint accent
                Circle()
                    .fill(HolographicColors.pastelMint.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(
                        x: geo.size.width * 0.2 + sin((phase + 60) * .pi / 180) * 12,
                        y: -geo.size.height * 0.05 + cos((phase + 60) * .pi / 180) * 18
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

// MARK: - View Modifier for Holographic Card

extension View {
    /// Applies a holographic animated border overlay to any view.
    func holographicCard(cornerRadius: CGFloat = Spacing.cardRadius) -> some View {
        self.overlay(
            HolographicBorder(cornerRadius: cornerRadius, lineWidth: 1.5, glowRadius: 4)
        )
    }
}

// MARK: - Preview

#Preview("Components") {
    VStack(spacing: Spacing.xxl) {
        HolographicProgressBar(totalSteps: 5, currentStep: 2)
            .padding(.horizontal, Spacing.pageMargin)

        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(FondyColors.surfaceSecondary)
            .frame(height: 60)
            .holographicCard(cornerRadius: 16)
            .padding(.horizontal, Spacing.pageMargin)

        HolographicButtonContent(text: "Get Started", icon: "sparkles")
            .padding(.horizontal, Spacing.pageMargin)
    }
    .frame(maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
}

#Preview("Mesh Background") {
    ZStack {
        HolographicMeshBackground()
        Text("AI Portfolio")
            .font(.largeTitle.bold())
    }
}

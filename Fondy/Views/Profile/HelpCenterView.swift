//
//  HelpCenterView.swift
//  Fondy
//
//  Help Center landing page with animated dark gradient hero header
//  ("Hello there / How can we help?") and a scrollable list of
//  help categories.
//

import SwiftUI

struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gradientPhase: CGFloat = 0
    @State private var isLoaded = false

    private let categories = HelpMockData.categories

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroHeader
                categoryList
            }
        }
        .scrollIndicators(.hidden)
        .background(FondyColors.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Haptics.light()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Back")
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Hero Header

private extension HelpCenterView {

    var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Animated dark gradient background
            animatedGradient
                .frame(height: 280)
                .clipped()

            // Text overlay
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Hello there")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text("How can we help?")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxl)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 10)
        }
    }

    var animatedGradient: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [Float(0.5 + sin(gradientPhase) * 0.06), 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.18),
                Color(red: 0.1, green: 0.15, blue: 0.3),
                Color(red: 0.05, green: 0.1, blue: 0.25),
                Color(red: 0.08, green: 0.12, blue: 0.28),
                Color(red: 0.15, green: 0.2, blue: 0.38),
                Color(red: 0.06, green: 0.1, blue: 0.22),
                Color(red: 0.02, green: 0.04, blue: 0.1),
                Color(red: 0.04, green: 0.06, blue: 0.14),
                Color(red: 0.02, green: 0.04, blue: 0.1),
            ]
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                gradientPhase = .pi * 2
            }
        }
    }
}

// MARK: - Category List

private extension HelpCenterView {

    var categoryList: some View {
        VStack(spacing: 0) {
            ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                NavigationLink {
                    HelpTopicView(category: category)
                } label: {
                    categoryRow(category)
                }
                .buttonStyle(.plain)

                if index < categories.count - 1 {
                    Divider()
                        .padding(.leading, 30 + Spacing.md + Spacing.pageMargin)
                }
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.xxxl)
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 12)
    }

    func categoryRow(_ category: HelpCategory) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: category.iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

            Text(category.title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: Spacing.sm)
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HelpCenterView()
    }
}

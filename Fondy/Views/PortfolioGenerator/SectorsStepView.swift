//
//  SectorsStepView.swift
//  Fondy
//
//  Sector preferences multi-select step with a 2-column grid of sector cards.
//

import SwiftUI

/// Asks the user to select at least 2 sectors they're interested in.
struct SectorsStepView: View {
    let state: PortfolioGeneratorState

    @State private var isAppeared = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md),
    ]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm + Spacing.md)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.top, Spacing.lg)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 16)

                    sectorGrid
                        .padding(.top, Spacing.xxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 20)

                    // Bottom padding for scroll content
                    Color.clear.frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)

            Spacer(minLength: Spacing.lg)

            continueButton
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 28)
                .padding(.bottom, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            withAnimation(.springGentle.delay(0.1)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension SectorsStepView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                state.back()
            }
        } label: {
            Image(systemName: "arrow.left")
                .font(.title3.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Go back")
    }

    // MARK: Header

    var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top) {
                Text("Which sectors interest you?")
                    .font(.title2.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: Spacing.lg)

                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue.opacity(0.5))
                    .accessibilityHidden(true)
            }

            HStack(spacing: Spacing.sm) {
                Text("Select at least 2")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)

                if !state.selectedSectors.isEmpty {
                    Text("\(state.selectedSectors.count) selected")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            state.canProceedFromSectors ? .blue : .orange,
                            in: Capsule()
                        )
                        .animation(.springInteractive, value: state.canProceedFromSectors)
                }
            }
        }
    }

    // MARK: Sector Grid

    var sectorGrid: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(PG.InvestmentSector.allCases) { sector in
                sectorCard(for: sector)
            }
        }
    }

    func sectorCard(for sector: PG.InvestmentSector) -> some View {
        let isSelected = state.selectedSectors.contains(sector)

        return Button {
            Haptics.selection()
            withAnimation(.springInteractive) {
                if isSelected {
                    state.selectedSectors.remove(sector)
                } else {
                    state.selectedSectors.insert(sector)
                }
            }
        } label: {
            VStack(spacing: Spacing.md) {
                // Icon
                Image(systemName: sector.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .blue)
                    .frame(width: 48, height: 48)
                    .background(
                        isSelected ? Color.blue : Color.blue.opacity(0.1),
                        in: Circle()
                    )

                // Title
                Text(sector.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .background(
                isSelected ? Color.blue.opacity(0.08) : FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? Color.blue : .clear, lineWidth: 1.5)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.blue)
                        .offset(x: -8, y: 8)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(.springInteractive, value: isSelected)
    }

    // MARK: Continue Button

    var continueButton: some View {
        Button {
            Haptics.medium()
            withAnimation(.springGentle) {
                state.next()
            }
        } label: {
            Text("Generate Portfolio")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .background(
                    state.canProceedFromSectors ? .blue : .blue.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!state.canProceedFromSectors)
        .animation(.springInteractive, value: state.canProceedFromSectors)
    }
}

// MARK: - Preview

#Preview {
    SectorsStepView(state: PortfolioGeneratorState())
}


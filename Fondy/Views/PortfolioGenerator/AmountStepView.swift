//
//  AmountStepView.swift
//  Fondy
//
//  Monthly investment amount selection with preset chips and custom input.
//

import SwiftUI

/// Asks the user to select their monthly investment amount.
struct AmountStepView: View {
    let state: PortfolioGeneratorState

    @State private var isAppeared = false
    @State private var showCustomField = false
    @FocusState private var isCustomFieldFocused: Bool

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
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

                    amountDisplay
                        .padding(.top, Spacing.xxxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 18)

                    presetGrid
                        .padding(.top, Spacing.xxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 22)

                    customAmountSection
                        .padding(.top, Spacing.xl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 24)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

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

private extension AmountStepView {

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
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("How much would you like to invest monthly?")
                .font(.title2.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("You can change this anytime")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
    }

    // MARK: Amount Display

    var amountDisplay: some View {
        VStack(spacing: Spacing.sm) {
            Text(state.formattedAmount)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(FondyColors.labelPrimary)
                .contentTransition(.numericText())
                .animation(.springInteractive, value: state.monthlyAmount)

            Text("per month")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Preset Grid

    var presetGrid: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(PortfolioGeneratorState.presetAmounts, id: \.self) { amount in
                presetChip(amount: amount)
            }
        }
    }

    func presetChip(amount: Double) -> some View {
        let isSelected = state.monthlyAmount == amount && !showCustomField

        return Button {
            Haptics.selection()
            showCustomField = false
            isCustomFieldFocused = false
            withAnimation(.springInteractive) {
                state.selectPresetAmount(amount)
            }
        } label: {
            Text("$\(Int(amount))")
                .font(.body.weight(.semibold))
                .foregroundStyle(isSelected ? .white : FondyColors.labelPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .liquidGlass(tint: isSelected ? .blue : nil, cornerRadius: 12)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .animation(.springInteractive, value: isSelected)
    }

    // MARK: Custom Amount

    var customAmountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button {
                Haptics.light()
                withAnimation(.springInteractive) {
                    showCustomField.toggle()
                    if showCustomField {
                        isCustomFieldFocused = true
                    }
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: showCustomField ? "minus.circle.fill" : "plus.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Custom amount")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
            }

            if showCustomField {
                HStack(spacing: Spacing.sm) {
                    Text("$")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(FondyColors.labelSecondary)

                    TextField("Enter amount", text: Binding(
                        get: { state.customAmountText },
                        set: { newValue in
                            state.customAmountText = newValue
                            state.applyCustomAmount()
                        }
                    ))
                    .font(.title3)
                    .keyboardType(.decimalPad)
                    .focused($isCustomFieldFocused)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
                .background(
                    FondyColors.surfaceSecondary,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isCustomFieldFocused ? Color.blue.opacity(0.4) : .clear,
                            lineWidth: 1.5
                        )
                )
                .animation(.springInteractive, value: isCustomFieldFocused)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: Continue Button

    var continueButton: some View {
        Button {
            Haptics.medium()
            isCustomFieldFocused = false
            withAnimation(.springGentle) {
                state.next()
            }
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .liquidGlass(tint: .blue, cornerRadius: 16, disabled: !state.canProceedFromAmount)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .disabled(!state.canProceedFromAmount)
        .animation(.springInteractive, value: state.canProceedFromAmount)
    }
}

// MARK: - Preview

#Preview {
    AmountStepView(state: PortfolioGeneratorState())
}

//
//  DateOfBirthView.swift
//  Fondy
//
//  Date of birth entry screen with Month, Day, Year fields
//  and auto-advance between them.
//

import SwiftUI

/// Date of birth entry screen shown after OTP verification during sign-up.
///
/// Features three numeric input fields (Month, Day, Year) with
/// auto-advance when each field reaches its max length.
struct DateOfBirthView: View {
    @Bindable var phoneAuth: PhoneAuthState

    @State private var isAppeared = false
    @FocusState private var focusedField: DOBField?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            headerSection
                .padding(.top, Spacing.lg)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 16)

            dateFields
                .padding(.top, Spacing.xxl)
                .opacity(isAppeared ? 1 : 0)
                .offset(y: isAppeared ? 0 : 20)

            Spacer()

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
            focusedField = .month
        }
        .onChange(of: phoneAuth.dobMonth) { _, newValue in
            let filtered = String(newValue.filter(\.isNumber).prefix(2))
            if filtered != phoneAuth.dobMonth { phoneAuth.dobMonth = filtered }
            if filtered.count == 2 { focusedField = .day }
        }
        .onChange(of: phoneAuth.dobDay) { _, newValue in
            let filtered = String(newValue.filter(\.isNumber).prefix(2))
            if filtered != phoneAuth.dobDay { phoneAuth.dobDay = filtered }
            if filtered.count == 2 { focusedField = .year }
        }
        .onChange(of: phoneAuth.dobYear) { _, newValue in
            let filtered = String(newValue.filter(\.isNumber).prefix(4))
            if filtered != phoneAuth.dobYear { phoneAuth.dobYear = filtered }
            if filtered.count == 4 { focusedField = nil }
        }
    }
}

// MARK: - Focus Enum

private enum DOBField: Hashable {
    case month, day, year
}

// MARK: - Subviews

private extension DateOfBirthView {

    // MARK: Back Button

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                phoneAuth.goBackFromCurrentStep()
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
            Text("Date of birth")
                .font(.largeTitle.bold())
                .foregroundStyle(FondyColors.labelPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("We need this to verify your identity")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
                .lineSpacing(2)
        }
    }

    // MARK: Date Fields

    var dateFields: some View {
        HStack(spacing: Spacing.md) {
            dobField(
                placeholder: "Month",
                text: $phoneAuth.dobMonth,
                field: .month
            )

            dobField(
                placeholder: "Day",
                text: $phoneAuth.dobDay,
                field: .day
            )

            dobField(
                placeholder: "Year",
                text: $phoneAuth.dobYear,
                field: .year
            )
        }
    }

    func dobField(
        placeholder: String,
        text: Binding<String>,
        field: DOBField
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .transition(.opacity)
            }

            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: field)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, 14)
                .background(
                    FondyColors.fillQuaternary,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            focusedField == field ? Color.blue.opacity(0.4) : .clear,
                            lineWidth: 1.5
                        )
                )
        }
        .animation(.springInteractive, value: text.wrappedValue.isEmpty)
    }

    // MARK: Continue Button

    var continueButton: some View {
        Button {
            Haptics.medium()
            withAnimation(.springGentle) {
                phoneAuth.completeDateOfBirth()
            }
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg + Spacing.xs)
                .background(
                    phoneAuth.isDateOfBirthValid ? .blue : .blue.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!phoneAuth.isDateOfBirthValid)
        .animation(.springInteractive, value: phoneAuth.isDateOfBirthValid)
    }
}

// MARK: - Preview

#Preview("Empty") {
    DateOfBirthView(phoneAuth: PhoneAuthState())
}

#Preview("Filled") {
    let state = PhoneAuthState()
    let _ = {
        state.dobMonth = "03"
        state.dobDay = "15"
        state.dobYear = "1995"
    }()
    DateOfBirthView(phoneAuth: state)
}

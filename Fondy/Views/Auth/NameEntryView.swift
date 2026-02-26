//
//  NameEntryView.swift
//  Fondy
//
//  "Name as in ID" screen with first name, last name, and optional alias
//  fields. Final step of the sign-up flow before account creation.
//

import SwiftUI

/// Name entry screen asking for the user's legal name as in their ID.
///
/// Displays first name, last name, and optional alias fields with a
/// floating "Continue" action button. Matches the reference design with
/// an ID document icon in the header.
struct NameEntryView: View {
    @Bindable var phoneAuth: PhoneAuthState

    @State private var isAppeared = false
    @FocusState private var focusedField: NameField?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.top, Spacing.lg)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 16)

                    formFields
                        .padding(.top, Spacing.xxl)
                        .opacity(isAppeared ? 1 : 0)
                        .offset(y: isAppeared ? 0 : 20)
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
            focusedField = .firstName
        }
    }
}

// MARK: - Focus Enum

private enum NameField: Hashable {
    case firstName
    case lastName
    case alias
}

// MARK: - Subviews

private extension NameEntryView {

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
                .frame(width: 40, height: 40)
                .liquidGlass(cornerRadius: 13)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("Go back")
    }

    // MARK: Header

    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Name as in ID")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FondyColors.labelPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("Name as in your official documents")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.lg)

            // ID document icon
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(.blue.opacity(0.5))
                .accessibilityHidden(true)
        }
    }

    // MARK: Form Fields

    var formFields: some View {
        VStack(spacing: Spacing.lg) {
            // First name
            VStack(alignment: .leading, spacing: Spacing.xs) {
                nameField(
                    placeholder: "First name",
                    text: $phoneAuth.firstName,
                    field: .firstName,
                    submitLabel: .next,
                    onSubmit: { focusedField = .lastName }
                )

                Text("e.g., Daniel, not \u{201C}Dan\u{201D}")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .padding(.leading, Spacing.xs)
            }

            // Last name
            nameField(
                placeholder: "Last name",
                text: $phoneAuth.lastName,
                field: .lastName,
                submitLabel: .next,
                onSubmit: { focusedField = .alias }
            )

            // Alias
            VStack(alignment: .leading, spacing: Spacing.xs) {
                nameField(
                    placeholder: "Alias",
                    text: $phoneAuth.alias,
                    field: .alias,
                    submitLabel: .done,
                    onSubmit: { focusedField = nil }
                )

                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .padding(.leading, Spacing.xs)
            }
        }
    }

    func nameField(
        placeholder: String,
        text: Binding<String>,
        field: NameField,
        submitLabel: SubmitLabel,
        onSubmit: @escaping () -> Void
    ) -> some View {
        TextField(placeholder, text: text)
            .font(.body)
            .foregroundStyle(FondyColors.labelPrimary)
            .textContentType(contentType(for: field))
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .focused($focusedField, equals: field)
            .onSubmit(onSubmit)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        focusedField == field ? Color.blue.opacity(0.4) : .clear,
                        lineWidth: 1.5
                    )
            )
            .animation(.springInteractive, value: focusedField)
            .accessibilityLabel(placeholder)
    }

    func contentType(for field: NameField) -> UITextContentType {
        switch field {
        case .firstName: .givenName
        case .lastName: .familyName
        case .alias: .nickname
        }
    }

    // MARK: Continue Button

    var continueButton: some View {
        ZStack(alignment: .trailing) {
            // Full-width invisible button for tap area
            Button {
                Haptics.medium()
                advanceToEmail()
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: 0)
            }
            .disabled(!phoneAuth.isNameValid)

            // Floating action button
            Button {
                Haptics.medium()
                advanceToEmail()
            } label: {
                Image(systemName: "arrow.down")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .liquidGlass(tint: .blue, cornerRadius: 28, disabled: !phoneAuth.isNameValid)
            }
            .buttonStyle(LiquidGlassButtonStyle())
            .disabled(!phoneAuth.isNameValid)
            .animation(.springInteractive, value: phoneAuth.isNameValid)
        }
    }

    // MARK: - Advance to Email

    func advanceToEmail() {
        guard phoneAuth.isNameValid else { return }
        focusedField = nil
        withAnimation(.springGentle) {
            phoneAuth.completeName()
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    NameEntryView(phoneAuth: PhoneAuthState())
}

#Preview("Filled") {
    let state = PhoneAuthState()
    let _ = {
        state.firstName = "John"
        state.lastName = "Smith"
    }()
    NameEntryView(phoneAuth: state)
}

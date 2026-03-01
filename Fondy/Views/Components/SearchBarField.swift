//
//  SearchBarField.swift
//  Fondy
//
//  Reusable search bar matching Apple's native search bar appearance and behaviour.
//  Supports two modes:
//    - Interactive: live TextField with animated Clear and Cancel buttons
//    - Tap target: non-interactive Button styled as a search bar for push navigation

import SwiftUI

struct SearchBarField: View {
    @Binding var text: String
    var placeholder: String
    private var tapAction: (() -> Void)?

    @FocusState private var isFocused: Bool

    init(text: Binding<String>, placeholder: String = "Search") {
        self._text = text
        self.placeholder = placeholder
        self.tapAction = nil
    }

    // MARK: - Body

    var body: some View {
        if let tapAction {
            tapTargetBar(action: tapAction)
        } else {
            interactiveBar
        }
    }

    // MARK: - Tap-target mode

    private func tapTargetBar(action: @escaping () -> Void) -> some View {
        Button {
            Haptics.light()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                searchIcon
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(.clear)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
        .accessibilityLabel(placeholder)
    }

    // MARK: - Interactive mode

    private var interactiveBar: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                searchIcon

                TextField(placeholder, text: $text)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !text.isEmpty {
                    clearButton
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.clear)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
            .animation(.springInteractive, value: text.isEmpty)

            if isFocused {
                cancelButton
            }
        }
        .animation(.springInteractive, value: isFocused)
    }

    // MARK: - Common subviews

    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
    }

    private var clearButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { text = "" }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.5).combined(with: .opacity),
            removal: .scale(scale: 0.5).combined(with: .opacity)
        ))
        .accessibilityLabel("Clear search")
    }

    private var cancelButton: some View {
        Button("Cancel") {
            withAnimation(.springInteractive) { text = "" }
            isFocused = false
            Haptics.light()
        }
        .font(.body)
        .foregroundStyle(.tint)
        .fixedSize()
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

// MARK: - Tap-target initialiser

extension SearchBarField {
    /// Creates a non-interactive search bar that acts as a tap target for navigating
    /// to a dedicated search screen (e.g. the App Store pattern).
    init(placeholder: String = "Search", onTap: @escaping () -> Void) {
        self._text = .constant("")
        self.placeholder = placeholder
        self.tapAction = onTap
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var text = ""
    VStack(spacing: Spacing.lg) {
        SearchBarField(text: $text, placeholder: "Search assets")
        SearchBarField(placeholder: "Tap to search") {}
    }
    .padding(.horizontal, Spacing.pageMargin)
    .padding(.top, Spacing.lg)
}

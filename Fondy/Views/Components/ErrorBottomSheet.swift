//
//  ErrorBottomSheet.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 13/02/26.
//

import SwiftUI

struct ErrorBottomSheet: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onButtonTap: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Drag indicator
            Capsule()
                .fill(FondyColors.fillTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.md)

            // Error icon
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(FondyColors.negative)
                .accessibilityHidden(true)

            // Text content
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            // Action button — primary recovery action (e.g., "Try again")
            Button(action: onButtonTap) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundStyle(FondyColors.background)
            }
            .buttonStyle(PositiveButtonStyle(cornerRadius: 50, tint: FondyColors.labelPrimary))
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity)
        .background(FondyColors.surfaceSecondary, in: RoundedRectangle(cornerRadius: Spacing.xxl, style: .continuous))
        .padding(.horizontal, Spacing.md)
        .shadow(color: .black.opacity(0.14), radius: Spacing.xl, x: 0, y: Spacing.sm)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - BottomSheetPresenter

struct BottomSheetPresenter<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dismissOnBackdropTap: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        if dismissOnBackdropTap {
                            withAnimation(.springGentle) { isPresented = false }
                        }
                    }
                    .accessibilityLabel("Dismiss")
                    .accessibilityAction { isPresented = false }

                VStack {
                    Spacer()
                    sheetContent()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, Spacing.md)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(.springGentle, value: isPresented)
    }
}

extension View {
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        dismissOnBackdropTap: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(BottomSheetPresenter(
            isPresented: isPresented,
            dismissOnBackdropTap: dismissOnBackdropTap,
            sheetContent: content
        ))
    }
}

// MARK: - Preview

#Preview {
    ErrorBottomSheet(
        title: "Something went wrong",
        message: "We couldn't process your request. Please check your connection and try again.",
        buttonTitle: "Try again"
    ) {}
}

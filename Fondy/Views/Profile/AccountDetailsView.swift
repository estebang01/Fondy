//
//  AccountDetailsView.swift
//  Fondy
//
//  Account details screen showing account information,
//  linked cards, and account limits.
//

import SwiftUI

struct AccountDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Account details")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                accountInfoCard

                linkedCardsCard

                limitsCard
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
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
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                .accessibilityLabel("Back")
            }
        }
    }
}

// MARK: - Account Info Card

private extension AccountDetailsView {

    var accountInfoCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Account information")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                detailRow(label: "Account name", value: "Personal")
                Divider().padding(.leading, Spacing.lg)
                detailRow(label: "Account number", value: "••••••7823", copyable: true)
                Divider().padding(.leading, Spacing.lg)
                detailRow(label: "Sort code", value: "04-00-75", copyable: true)
                Divider().padding(.leading, Spacing.lg)
                detailRow(label: "IBAN", value: "SG••••••••3847", copyable: true)
                Divider().padding(.leading, Spacing.lg)
                detailRow(label: "BIC / SWIFT", value: "DBSSSGSG", copyable: true)
                Divider().padding(.leading, Spacing.lg)
                detailRow(label: "Currency", value: "SGD \u{1F1F8}\u{1F1EC}")
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }

    func detailRow(label: String, value: String, copyable: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)

            Spacer()

            HStack(spacing: Spacing.sm) {
                if copyable {
                    Button {
                        Haptics.light()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
            }
        }
        .padding(.vertical, Spacing.md + 2)
    }
}

// MARK: - Linked Cards Card

private extension AccountDetailsView {

    var linkedCardsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Linked cards")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                cardRow(
                    type: "Metal",
                    lastFour: "4291",
                    icon: "creditcard.fill",
                    isActive: true
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                cardRow(
                    type: "Virtual",
                    lastFour: "8103",
                    icon: "creditcard",
                    isActive: true
                )
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )

            Button {
                Haptics.light()
            } label: {
                Label("Add new card", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        Color.blue.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    func cardRow(type: String, lastFour: String, icon: String, isActive: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("\(type) card")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Text("•••• \(lastFour)")
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer(minLength: Spacing.sm)

            Text(isActive ? "Active" : "Frozen")
                .font(.caption.weight(.semibold))
                .foregroundStyle(isActive ? .green : .orange)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(
                    (isActive ? Color.green : Color.orange).opacity(0.12),
                    in: Capsule()
                )
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
    }
}

// MARK: - Limits Card

private extension AccountDetailsView {

    var limitsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Account limits")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                limitRow(title: "Daily transfer limit", used: "$2,500", total: "$50,000")
                Divider().padding(.leading, Spacing.lg)
                limitRow(title: "Monthly ATM withdrawal", used: "$800", total: "$3,000")
                Divider().padding(.leading, Spacing.lg)
                limitRow(title: "Card payment limit", used: "$1,200", total: "$25,000")
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }

    func limitRow(title: String, used: String, total: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelPrimary)

                Spacer()

                Text("\(used) / \(total)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(FondyColors.fillTertiary)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.15, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, Spacing.md + 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AccountDetailsView()
    }
}

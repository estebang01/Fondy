//
//  PlanView.swift
//  Fondy
//
//  Subscription plan details screen showing current plan,
//  features, and upgrade options.
//

import SwiftUI

struct PlanView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Plan")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                currentPlanCard

                featuresCard

                managePlanCard
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

// MARK: - Current Plan Card

private extension PlanView {

    var currentPlanCard: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "bolt.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.yellow)
                    .frame(width: 44, height: 44)
                    .background(
                        Color.yellow.opacity(0.15),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Metal")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text("Your current plan")
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer()

                Text("Active")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        Color.green.opacity(0.12),
                        in: Capsule()
                    )
            }

            Divider()

            HStack {
                Text("Next billing date")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)

                Spacer()

                Text("Mar 15, 2026")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
            }

            HStack {
                Text("Monthly price")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)

                Spacer()

                Text("$13.99/mo")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FondyColors.labelPrimary)
            }
        }
        .padding(Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}

// MARK: - Features Card

private extension PlanView {

    var featuresCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Plan features")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                featureRow(icon: "arrow.left.arrow.right", title: "Unlimited transfers", subtitle: "No fees on international transfers")
                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)
                featureRow(icon: "creditcard.fill", title: "Metal card", subtitle: "Exclusive metal debit card")
                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)
                featureRow(icon: "banknote.fill", title: "Cashback", subtitle: "Up to 1% cashback on purchases")
                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)
                featureRow(icon: "chart.line.uptrend.xyaxis", title: "Trading", subtitle: "Commission-free stock trading")
                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)
                featureRow(icon: "shield.checkered", title: "Insurance", subtitle: "Device and purchase protection")
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }

    func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelSecondary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.green)
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
    }
}

// MARK: - Manage Plan Card

private extension PlanView {

    var managePlanCard: some View {
        VStack(spacing: 0) {
            Button {
                Haptics.light()
            } label: {
                planActionRow(icon: "arrow.up.circle.fill", iconColor: .blue, title: "Upgrade plan")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            Button {
                Haptics.light()
            } label: {
                planActionRow(icon: "arrow.down.circle.fill", iconColor: .orange, title: "Downgrade plan")
            }
            .buttonStyle(.plain)

            Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

            Button {
                Haptics.light()
            } label: {
                planActionRow(icon: "xmark.circle.fill", iconColor: .red, title: "Cancel plan")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }

    func planActionRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)

            Text(title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer(minLength: Spacing.sm)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlanView()
    }
}

//
//  DocumentsView.swift
//  Fondy
//
//  Documents screen showing user's uploaded documents,
//  statements, and verification status.
//

import SwiftUI

struct DocumentsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                Text("Documents")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.top, Spacing.lg)

                verificationCard

                statementsCard

                uploadedDocumentsCard
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

// MARK: - Verification Card

private extension DocumentsView {

    var verificationCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Identity verification")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                documentStatusRow(
                    icon: "person.text.rectangle.fill",
                    title: "Proof of identity",
                    status: .verified
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                documentStatusRow(
                    icon: "house.fill",
                    title: "Proof of address",
                    status: .verified
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                documentStatusRow(
                    icon: "camera.fill",
                    title: "Selfie verification",
                    status: .verified
                )
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }
}

// MARK: - Statements Card

private extension DocumentsView {

    var statementsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("Statements")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Spacer()

                Button {
                    Haptics.light()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 0) {
                statementRow(month: "January 2026", date: "Feb 1, 2026")
                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)
                statementRow(month: "December 2025", date: "Jan 1, 2026")
                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)
                statementRow(month: "November 2025", date: "Dec 1, 2025")
            }
            .padding(.horizontal, Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
    }

    func statementRow(month: String, date: String) -> some View {
        Button {
            Haptics.light()
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "doc.text.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(month)
                        .font(.body)
                        .foregroundStyle(FondyColors.labelPrimary)

                    Text("Generated \(date)")
                        .font(.caption)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer(minLength: Spacing.sm)

                Image(systemName: "arrow.down.circle")
                    .font(.body)
                    .foregroundStyle(.blue)
            }
            .padding(.vertical, Spacing.md + Spacing.xxs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Uploaded Documents Card

private extension DocumentsView {

    var uploadedDocumentsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Uploaded documents")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                documentStatusRow(
                    icon: "doc.fill",
                    title: "National ID",
                    status: .verified
                )

                Divider().padding(.leading, 30 + Spacing.md + Spacing.lg)

                documentStatusRow(
                    icon: "doc.fill",
                    title: "Utility bill",
                    status: .verified
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
                Label("Upload document", systemImage: "arrow.up.circle.fill")
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
}

// MARK: - Helpers

private extension DocumentsView {

    enum DocumentStatus {
        case verified
        case pending
        case required

        var label: String {
            switch self {
            case .verified: "Verified"
            case .pending: "Pending"
            case .required: "Required"
            }
        }

        var color: Color {
            switch self {
            case .verified: .green
            case .pending: .orange
            case .required: .red
            }
        }
    }

    func documentStatusRow(icon: String, title: String, status: DocumentStatus) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)

            Text(title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer(minLength: Spacing.sm)

            Text(status.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(status.color)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(
                    status.color.opacity(0.12),
                    in: Capsule()
                )
        }
        .padding(.vertical, Spacing.md + Spacing.xxs)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DocumentsView()
    }
}

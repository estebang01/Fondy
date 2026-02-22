//
//  HelpTopicView.swift
//  Fondy
//
//  Help topic detail showing "What's your issue?",
//  a "Select a transaction" card, and a "Help with something else"
//  list of related FAQ articles.
//

import SwiftUI

struct HelpTopicView: View {
    let category: HelpCategory

    @Environment(\.dismiss) private var dismiss
    @State private var isLoaded = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text("What's your issue?")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.sectionGap)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : 8)

                // Transactions section (if any)
                if !category.transactions.isEmpty {
                    transactionsSection
                        .padding(.bottom, Spacing.sectionGap)
                }

                // FAQ articles section
                if !category.articles.isEmpty {
                    articlesSection
                        .padding(.bottom, Spacing.xxxl)
                }

                // Empty state if no content
                if category.transactions.isEmpty && category.articles.isEmpty {
                    emptyState
                }
            }
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
        .onAppear {
            withAnimation(.springGentle.delay(0.05)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Transactions Section

private extension HelpTopicView {

    var transactionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Select a transaction")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .padding(.horizontal, Spacing.pageMargin)

            VStack(spacing: 0) {
                ForEach(Array(category.transactions.enumerated()), id: \.element.id) { index, transaction in
                    transactionRow(transaction)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)

                    if index < category.transactions.count - 1 {
                        Divider()
                            .padding(.leading, 44 + Spacing.md + Spacing.lg)
                    }
                }
            }
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .padding(.horizontal, Spacing.pageMargin)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 10)
        }
    }

    func transactionRow(_ transaction: HelpTransaction) -> some View {
        Button {
            Haptics.light()
        } label: {
            HStack(spacing: Spacing.md) {
                // Icon
                Image(systemName: transaction.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(transaction.iconColor)
                    .frame(width: 44, height: 44)
                    .background(transaction.iconBackground, in: Circle())
                    .accessibilityHidden(true)

                // Name + subtitle
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(transaction.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .lineLimit(1)
                        .redacted(reason: transaction.name == "Spotify" ? .placeholder : [])

                    Text(transaction.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: Spacing.sm)

                // Amount
                Text(transaction.amount)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Articles Section

private extension HelpTopicView {

    var articlesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Help with something else")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
                .padding(.horizontal, Spacing.pageMargin)

            VStack(spacing: 0) {
                ForEach(Array(category.articles.enumerated()), id: \.element.id) { index, article in
                    NavigationLink {
                        HelpArticleView(title: article.title)
                    } label: {
                        articleRow(article)
                    }
                    .buttonStyle(.plain)

                    if index < category.articles.count - 1 {
                        Divider()
                            .padding(.leading, Spacing.lg)
                    }
                }
            }
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .padding(.horizontal, Spacing.pageMargin)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 10)
        }
    }

    func articleRow(_ article: HelpArticle) -> some View {
        HStack(spacing: Spacing.md) {
            Text(article.title)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer(minLength: Spacing.sm)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelTertiary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md + 2)
        .contentShape(Rectangle())
    }
}

// MARK: - Empty State

private extension HelpTopicView {

    var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40))
                .foregroundStyle(FondyColors.labelTertiary)

            Text("No articles available yet")
                .font(.body)
                .foregroundStyle(FondyColors.labelSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxl + Spacing.xl)
        .opacity(isLoaded ? 1 : 0)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HelpTopicView(category: HelpMockData.categories[6]) // Subscriptions
    }
}

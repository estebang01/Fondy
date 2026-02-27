//
//  AddStocksSheet.swift
//  Fondy
//
//  Modal sheet for searching and selecting stocks to add to the watchlist.
//  Matches the Revolut "Add Stocks" sheet: × dismiss, search bar, checkbox list,
//  legal footer, and a bottom "Add" button (disabled until selection made).
//

import SwiftUI

/// Sheet for searching and adding stocks to the user's watchlist.
///
/// Presents a searchable list of available stocks with checkboxes.
/// The "Add" button is disabled until at least one stock is selected.
struct AddStocksSheet: View {
    @Bindable var viewModel: StocksViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var localStocks: [SelectableStock] = []
    @FocusState private var searchFocused: Bool

    // MARK: - Computed

    private var filteredStocks: [SelectableStock] {
        if searchText.isEmpty { return localStocks }
        return localStocks.filter {
            $0.companyName.localizedCaseInsensitiveContains(searchText) ||
            $0.ticker.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var selectedCount: Int {
        localStocks.filter(\.isSelected).count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Fixed header (not scrollable)
            VStack(alignment: .leading, spacing: 0) {
                headerBar
                    .padding(.bottom, Spacing.lg)

                searchBar
                    .padding(.bottom, Spacing.lg)
            }
            .padding(.horizontal, Spacing.pageMargin)
            .background(Color(.systemGroupedBackground))

            // Scrollable list
            ScrollView {
                VStack(spacing: 0) {
                    stocksCard

                    footerText
                        .padding(.top, Spacing.xl)
                        .padding(.bottom, Spacing.xxxl + 60) // room for Add button
                }
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.sm)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            addButton
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.bottom, Spacing.xl)
        }
        .onAppear {
            // Copy available stocks into local mutable state
            localStocks = viewModel.availableStocks.map { s in
                var copy = s
                copy.isSelected = false
                return copy
            }
        }
    }
}

// MARK: - Header Bar

private extension AddStocksSheet {

    var headerBar: some View {
        HStack {
            Button {
                Haptics.light()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .frame(width: 32, height: 32)
                    .background(FondyColors.fillTertiary, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")

            Spacer()
        }
        .padding(.top, Spacing.lg)
    }

    var titleText: some View {
        Text("Add Stocks")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(FondyColors.labelPrimary)
    }
}

// MARK: - Search Bar

private extension AddStocksSheet {

    var searchBar: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            titleText

            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(FondyColors.labelTertiary)
                    .accessibilityHidden(true)

                TextField("Search", text: $searchText)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .accessibilityLabel("Search stocks")

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(FondyColors.labelTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }

                if searchFocused {
                    Button("Cancel") {
                        searchText = ""
                        searchFocused = false
                    }
                    .font(.body)
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm + 2)
            .background(FondyColors.fillQuaternary, in: Capsule())
            .animation(.springGentle, value: searchFocused)
        }
    }
}

// MARK: - Stocks Card

private extension AddStocksSheet {

    var stocksCard: some View {
        VStack(spacing: 0) {
            if filteredStocks.isEmpty {
                emptySearchState
            } else {
                ForEach(Array(filteredStocks.enumerated()), id: \.element.id) { index, stock in
                    stockRow(stock: stock, index: index)

                    if index < filteredStocks.count - 1 {
                        Divider()
                            .padding(.leading, 44 + Spacing.md + Spacing.lg + 28)
                    }
                }
            }
        }
        .background(FondyColors.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    func stockRow(stock: SelectableStock, index: Int) -> some View {
        Button {
            Haptics.light()
            toggleSelection(id: stock.id)
        } label: {
            HStack(spacing: Spacing.md) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(stock.isSelected ? Color.clear : FondyColors.separator, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(stock.isSelected ? Color.blue : Color.clear)
                        )
                    if stock.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .accessibilityHidden(true)

                // Logo
                Image(systemName: stock.logoSystemName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(stock.logoColor)
                    .frame(width: 44, height: 44)
                    .background(stock.logoBackground, in: Circle())
                    .accessibilityHidden(true)

                // Name column
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(stock.companyName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(stock.ticker)
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("\(stock.companyName), \(stock.ticker)\(stock.isSelected ? ", selected" : "")")
    }

    var emptySearchState: some View {
        HStack {
            Spacer()
            VStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(FondyColors.labelTertiary)
                Text("No results for \"\(searchText)\"")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .padding(.vertical, Spacing.xxxl)
            Spacer()
        }
    }
}

// MARK: - Add Button

private extension AddStocksSheet {

    var addButton: some View {
        Button {
            Haptics.medium()
            addSelectedStocks()
            dismiss()
        } label: {
            Text("Add")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
        }
        .buttonStyle(PositiveButtonStyle(cornerRadius: 50))
        .disabled(selectedCount == 0)
        .accessibilityLabel("Add \(selectedCount) stocks to watchlist")
    }
}

// MARK: - Footer

private extension AddStocksSheet {

    var footerText: some View {
        VStack(spacing: Spacing.md) {
            Text("Past performance is not a reliable indicator of future results.")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)

            Text("Services are provided by Fondy Securities, a Capital Markets Services License holder authorized by the Monetary Authority of Singapore (License no. CMS101155).")
                .font(.footnote)
                .foregroundStyle(FondyColors.labelTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Text("View")
                    .font(.footnote)
                    .foregroundStyle(FondyColors.labelTertiary)
                Button("Terms of business") {}
                    .font(.footnote)
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
                Text("and")
                    .font(.footnote)
                    .foregroundStyle(FondyColors.labelTertiary)
                Button("Trading Disclosures") {}
                    .font(.footnote)
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
                Text(".")
                    .font(.footnote)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers

private extension AddStocksSheet {

    func toggleSelection(id: UUID) {
        guard let index = localStocks.firstIndex(where: { $0.id == id }) else { return }
        localStocks[index].isSelected.toggle()
    }

    func addSelectedStocks() {
        let selected = localStocks.filter(\.isSelected)
        for stock in selected {
            let watchlistItem = WatchlistStock(
                id: UUID(),
                name: stock.companyName,
                ticker: stock.ticker,
                logoSystemName: stock.logoSystemName,
                logoColor: stock.logoColor,
                price: 0.0,
                changePercent: 0.0,
                currencySymbol: "$"
            )
            if !viewModel.watchlist.contains(where: { $0.ticker == stock.ticker }) {
                viewModel.watchlist.append(watchlistItem)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddStocksSheet(viewModel: StocksViewModel.createMock())
}

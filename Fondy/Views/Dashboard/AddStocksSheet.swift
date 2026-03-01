//
//  AddStocksSheet.swift
//  Fondy
//
//  Modal sheet for searching and selecting stocks to add to the watchlist.
//  Professional, Apple-native design with smooth interactions and animations.
//

import SwiftUI

/// Sheet for searching and adding stocks to the user's watchlist.
///
/// Presents a searchable list of available stocks with smooth selection animations.
/// The "Add" button dynamically updates to show the selection count.
struct AddStocksSheet: View {
    @Bindable var viewModel: StocksViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var localStocks: [SelectableStock] = []
    @State private var isLoaded = false
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

    private var selectedStocks: [SelectableStock] {
        localStocks.filter(\.isSelected)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Scrollable content
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Search bar at the top of scroll view
                        searchBarSection
                            .padding(.top, Spacing.xs)
                        
                        // Selected stocks section (always visible; wraps vertically)
                        if !selectedStocks.isEmpty {
                            selectedStocksSection
                        }

                        // All stocks section
                        allStocksSection
                    }
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Stocks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        Haptics.light()
                        dismiss()
                    }
                    .opacity(isLoaded ? 1 : 0)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if selectedCount > 0 {
                    addButtonSection
                        .padding(.horizontal, Spacing.pageMargin)
                        .padding(.vertical, Spacing.md)
                        .background(.ultraThinMaterial)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCount)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchFocused)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .onAppear {
            // Copy available stocks into local mutable state
            localStocks = viewModel.availableStocks.map { s in
                var copy = s
                copy.isSelected = false
                return copy
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                isLoaded = true
            }
        }
    }
}

// MARK: - Search Bar

private extension AddStocksSheet {

    var searchBarSection: some View {
        HStack(spacing: Spacing.sm) {
            // Search field with glass effect
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                TextField("Search", text: $searchText)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityLabel("Search stocks")

                if !searchText.isEmpty {
                    Button {
                        Haptics.light()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                        removal: .scale(scale: 0.5).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.clear)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
            
            // Glass cancel button with X icon that appears when focused
            if searchFocused || !searchText.isEmpty {
                Button {
                    Haptics.light()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        searchText = ""
                        searchFocused = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityLabel("Cancel search")
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .move(edge: .trailing)).combined(with: .opacity),
                    removal: .scale(scale: 0.5).combined(with: .move(edge: .trailing)).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: searchFocused)
        .animation(.easeInOut(duration: 0.25), value: searchText.isEmpty)
    }
}

// MARK: - Selected Stocks Section

private extension AddStocksSheet {

    var selectedStocksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Selected")
                    .font(.headline)
                    .foregroundStyle(FondyColors.labelPrimary)
                
                Spacer()
                
                Button {
                    Haptics.light()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        // Deselect all
                        for index in localStocks.indices {
                            localStocks[index].isSelected = false
                        }
                    }
                } label: {
                    Text("Clear All")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, Spacing.xs)

            // Wrapping chips using LazyVGrid
            let columns = [
                GridItem(.adaptive(minimum: 90, maximum: 110), spacing: Spacing.xs)
            ]
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.sm) {
                ForEach(selectedStocks) { stock in
                    selectedStockChip(stock)
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    func selectedStockChip(_ stock: SelectableStock) -> some View {
        HStack(spacing: Spacing.xxs) {
            CompanyLogoView(
                domain: nil,
                systemName: stock.logoSystemName,
                symbolColor: stock.logoColor,
                background: stock.logoBackground,
                size: 20
            )

            Text(stock.ticker)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)

            Button {
                Haptics.light()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    toggleSelection(id: stock.id)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(FondyColors.background, in: Capsule())
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - All Stocks Section

private extension AddStocksSheet {

    var allStocksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(searchText.isEmpty ? "All Stocks" : "Results")
                .font(.headline)
                .foregroundStyle(FondyColors.labelPrimary)
                .padding(.bottom, Spacing.xs)

            if filteredStocks.isEmpty {
                emptySearchState
            } else {
                stocksCard
            }
        }
    }

    var stocksCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredStocks.enumerated()), id: \.element.id) { index, stock in
                stockRow(stock: stock)

                if index < filteredStocks.count - 1 {
                    Divider()
                        .padding(.leading, Spacing.lg + Spacing.iconSize + Spacing.md)
                }
            }
        }
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    func stockRow(stock: SelectableStock) -> some View {
        Button {
            Haptics.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                toggleSelection(id: stock.id)
            }
        } label: {
            HStack(spacing: Spacing.md) {
                // Logo
                CompanyLogoView(
                    domain: nil,
                    systemName: stock.logoSystemName,
                    symbolColor: stock.logoColor,
                    background: stock.logoBackground,
                    size: Spacing.iconSize
                )

                // Name and ticker
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(stock.companyName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                        .lineLimit(1)

                    Text(stock.ticker)
                        .font(.subheadline)
                        .foregroundStyle(FondyColors.labelSecondary)
                }

                Spacer(minLength: Spacing.sm)

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(stock.isSelected ? Color.clear : FondyColors.separator, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(stock.isSelected ? Color.blue : Color.clear)
                        )
                    
                    if stock.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: stock.isSelected)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidGlassButtonStyle())
        .accessibilityLabel("\(stock.companyName), \(stock.ticker)")
        .accessibilityAddTraits(stock.isSelected ? .isSelected : [])
    }

    var emptySearchState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(FondyColors.labelTertiary)
                .symbolEffect(.pulse)

            VStack(spacing: Spacing.xs) {
                Text("No Results")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)

                Text("Try adjusting your search")
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxxl * 2)
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }
}

// MARK: - Add Button

private extension AddStocksSheet {

    var addButtonSection: some View {
        Button {
            Haptics.medium()
            addSelectedStocks()
            dismiss()
        } label: {
            HStack(spacing: Spacing.sm) {
                Text("Add")
                    .font(.body.weight(.semibold))
                
                if selectedCount > 0 {
                    Text("(\(selectedCount))")
                        .font(.body.weight(.semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PositiveButtonStyle(cornerRadius: 14))
        .accessibilityLabel("Add \(selectedCount) stock\(selectedCount == 1 ? "" : "s") to watchlist")
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


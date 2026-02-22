//
//  HomeAccountView.swift
//  Fondy
//
//  Main Home screen matching the Revolut-style account dashboard.
//  Grey grouped background with white rounded container cards.
//

import SwiftUI

/// The primary Home Account dashboard screen.
///
/// Uses a grey `systemGroupedBackground` with white rounded container cards
/// grouping related content. Layout: Top bar → Search → Segment tabs →
/// Tab-driven content (Accounts / Cards / Stocks).
struct HomeAccountView: View {
    @State private var isSearchPresented = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    @Bindable var viewModel: HomeAccountViewModel

    @State private var isLoaded = false

    @State private var aiQuery: String = ""
    @State private var isAnalysisPresented: Bool = false
    @State private var isAIBarExpanded: Bool = false
    @State private var isAISending: Bool = false
    
    @Namespace private var glassNS

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        topBar
                            .padding(.bottom, Spacing.md)
                        
                        if isSearchPresented {
                            searchContent
                                .transition(.opacity)
                        } else {

                            tabContent
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, Spacing.pageMargin)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.xxxl + Spacing.lg)
                    .animation(.springGentle, value: isSearchPresented)
                }
                .scrollIndicators(.hidden)

                GlassEffectContainer(spacing: 28) {
                    Group {
                        if isAIBarExpanded {
                            AIQueryBar(
                                text: $aiQuery,
                                isLoading: $isAISending,
                                onAnalyze: {
                                    let trimmed = aiQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { Haptics.selection(); return }
                                    Haptics.medium()
                                    isAISending = true
                                    Task {
                                        try? await Task.sleep(for: .milliseconds(600))
                                        isAnalysisPresented = true
                                        isAISending = false
                                    }
                                },
                                autoFocus: true,
                                onClose: {
                                    withAnimation(.springGentle) {
                                        isAIBarExpanded = false
                                    }
                                }
                            )
                            .padding(.horizontal, Spacing.pageMargin)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .glassEffectID("aiBubble", in: glassNS)
                            .accessibilityAddTraits(.isSearchField)
                        } else {
                            Button {
                                Haptics.light()
                                withAnimation(.springGentle) { isAIBarExpanded = true }
                            } label: {
                                LiquidOrb()
                                    .frame(width: 56, height: 56)
                                    .glassEffect(.regular.interactive(), in: .circle)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Ask AI")
                            .transition(.scale.combined(with: .opacity))
                            .glassEffectID("aiBubble", in: glassNS)
                        }
                    }
                }
                .padding(.bottom, Spacing.xxxl)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                guard !isSearchPresented else { return }
                Haptics.medium()
                try? await Task.sleep(for: .seconds(1))
                Haptics.success()
            }
            .onAppear {
                withAnimation(.springGentle) {
                    isLoaded = true
                }
            }
            .sheet(isPresented: $isAnalysisPresented) {
                AIAnalysisSheet(question: aiQuery, isPresented: $isAnalysisPresented)
                    .presentationDetents([.medium, .large])
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
// MARK: - Tab Content Switch

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .stocks:
            StocksView(
                actionItems: viewModel.actionItems,
                onRemoveActionItem: { viewModel.removeActionItem(id: $0) }
            )
            .transition(.opacity)
        case .accounts, .cards:
            StocksView(
                actionItems: viewModel.actionItems,
                onRemoveActionItem: { viewModel.removeActionItem(id: $0)
                }
            )
        }
    }
}

// MARK: - Reusable Card Container

private extension HomeAccountView {

    /// A white rounded rectangle container for grouping content.
    func cardContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }
}

// MARK: - Top Bar

private extension HomeAccountView {

    var topBar: some View {
        HStack(spacing: Spacing.md) {
            // Leading: back arrow (search) or avatar (normal)
            if isSearchPresented {
                backButton
                    .transition(.scale.combined(with: .opacity))
            } else {
                avatarButton
                    .transition(.scale.combined(with: .opacity))
            }

            // Search bar — tap-to-activate when idle, live input when searching
            if isSearchPresented {
                activeSearchBar
                    .transition(.opacity)
            } else {
                SearchBarField(placeholder: "Search") {
                    Haptics.light()
                    withAnimation(.springGentle) {
                        isSearchPresented = true
                    }
                }
                .transition(.opacity)
            }

            // Trailing: hidden when searching, bell when idle
            if !isSearchPresented {
                topBarIcon("bell") {
                    Haptics.light()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 6)
    }

    var backButton: some View {
        Button {
            Haptics.light()
            withAnimation(.springGentle) {
                isSearchPresented = false
                searchText = ""
                isSearchFocused = false
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }

    var activeSearchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(FondyColors.labelTertiary)
                .accessibilityHidden(true)

            TextField("Search", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    Haptics.light()
                    withAnimation(.springInteractive) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(FondyColors.labelTertiary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm + Spacing.xxs)
        .background(FondyColors.fillQuaternary, in: Capsule())
        .animation(.springInteractive, value: searchText.isEmpty)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isSearchFocused = true
            }
        }
    }

    var avatarButton: some View {
        Button {
            Haptics.light()
        } label: {
            Text(viewModel.userInitials)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray3), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }

    func topBarIcon(
        _ name: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(FondyColors.labelPrimary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Content

private extension HomeAccountView {

    /// Inline search results — rendered in the same scroll view as the rest of the dashboard.
    var searchContent: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionGap) {
            if searchText.isEmpty {
                recentSearchesSection
                quickLinksSection
            } else {
                searchResultsSection
            }
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: Recent Searches

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                ForEach(["AAPL", "EUR/USD", "Tesla", "Bitcoin"], id: \.self) { term in
                    Button {
                        Haptics.light()
                        searchText = term
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "clock")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(FondyColors.labelTertiary)
                                .frame(width: 28)

                            Text(term)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)

                            Spacer()

                            Image(systemName: "arrow.up.left")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(FondyColors.labelTertiary)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if term != "Bitcoin" {
                        Divider()
                            .padding(.leading, 28 + Spacing.md + Spacing.lg)
                    }
                }
            }
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        }
    }

    // MARK: Quick Links

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Browse")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            let links: [(icon: String, color: Color, label: String)] = [
                ("chart.bar.fill", .blue, "Stocks"),
                ("dollarsign.arrow.circlepath", .green, "Crypto"),
                ("globe", .orange, "Forex"),
                ("sparkles", .purple, "Top movers"),
            ]

            VStack(spacing: 0) {
                ForEach(links, id: \.label) { link in
                    Button {
                        Haptics.light()
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: link.icon)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(link.color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                            Text(link.label)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(FondyColors.labelTertiary)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if link.label != "Top movers" {
                        Divider()
                            .padding(.leading, 32 + Spacing.md + Spacing.lg)
                    }
                }
            }
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        }
    }

    // MARK: Search Results

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Results")
                .font(.title3.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            VStack(spacing: 0) {
                ForEach(["AAPL · Apple Inc.", "AMZN · Amazon.com", "MSFT · Microsoft"].filter {
                    $0.localizedCaseInsensitiveContains(searchText)
                }, id: \.self) { result in
                    Button {
                        Haptics.light()
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(FondyColors.labelSecondary)
                                .frame(width: 28)

                            Text(result)
                                .font(.body)
                                .foregroundStyle(FondyColors.labelPrimary)

                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if result != "MSFT · Microsoft" {
                        Divider()
                            .padding(.leading, 28 + Spacing.md + Spacing.lg)
                    }
                }

                if ["AAPL · Apple Inc.", "AMZN · Amazon.com", "MSFT · Microsoft"].filter({
                    $0.localizedCaseInsensitiveContains(searchText)
                }).isEmpty {
                    Text("No results for \(searchText)")
                        .font(.body)
                        .foregroundStyle(FondyColors.labelSecondary)
                        .padding(Spacing.lg)
                }
            }
            .background(FondyColors.background, in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous))
        }
    }
}



// MARK: - Segment Tabs

private extension HomeAccountView {
    
    var segmentTabs: some View {
        FlatTabBar(selected: $viewModel.selectedTab)
            .opacity(isLoaded ? 1 : 0)
            .offset(y: isLoaded ? 0 : 8)
    }
}

// MARK: - Liquid Orb View

private struct LiquidOrb: View {
    @State private var breathe = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.6)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .scaleEffect(breathe ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: breathe)
        }
        .onAppear { breathe = true }
    }
}

// MARK: - Preview

#Preview {
    HomeAccountView(viewModel: HomeAccountViewModel.createMock())
}

#Preview("With Transactions") {
    let vm = HomeAccountViewModel.createMock()
    let _ = vm.transactions = PortfolioService.mockTransactions
    HomeAccountView(viewModel: vm)
}


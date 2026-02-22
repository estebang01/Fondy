import SwiftUI

struct PaperPortfolioView: View {
    @State private var store = PaperPortfolioStore()
    @State private var showAdd = false
    @State private var editTarget: PaperPosition? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, Spacing.sectionGap)

                if store.positions.isEmpty {
                    emptyCard
                } else {
                    positionsList
                }
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Paper portfolio")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) { addFAB }
        .sheet(isPresented: $showAdd) {
            AddPaperPositionView(onSave: { t, s, p in
                store.add(ticker: t, shares: s, price: p)
            })
            .presentationDetents([.medium])
        }
        .sheet(item: $editTarget) { position in
            AddPaperPositionView(onSave: { t, s, p in
                store.update(id: position.id, ticker: t, shares: s, price: p)
            }, existing: position)
            .presentationDetents([.medium])
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Paper portfolio")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
            Text("Track test buys before opening a broker")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
    }

    // MARK: - List

    private var positionsList: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            cardContainer {
                VStack(spacing: 0) {
                    ForEach(Array(store.positions.enumerated()), id: \.element.id) { index, p in
                        Button {
                            Haptics.light()
                            editTarget = p
                        } label: {
                            positionRow(p)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                        }
                        .buttonStyle(.plain)

                        if index < store.positions.count - 1 {
                            Divider().padding(.leading, Spacing.lg)
                        }
                    }
                }
            }

            HStack {
                Button(role: .destructive) {
                    Haptics.selection()
                    store.clearAll()
                } label: {
                    Label("Clear all", systemImage: "trash")
                }
                .buttonStyle(.borderless)
                Spacer()
            }
            .padding(.horizontal, Spacing.xs)
            .padding(.top, Spacing.xs)
        }
    }

    private var emptyCard: some View {
        cardContainer {
            HStack(spacing: Spacing.md) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelTertiary)
                    .frame(width: 40, height: 40)
                    .background(FondyColors.fillQuaternary, in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("No positions yet")
                        .font(.body)
                        .foregroundStyle(FondyColors.labelSecondary)
                    Button {
                        Haptics.light(); showAdd = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add your first position")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Row

    private func positionRow(_ p: PaperPosition) -> some View {
        HStack(spacing: Spacing.md) {
            Text(p.ticker)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Color.blue, in: Capsule())
                .accessibilityLabel("Ticker \(p.ticker)")

            VStack(alignment: .leading, spacing: 2) {
                Text("\(p.formattedShares) × \(p.formattedAvgCost)")
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
                Text(p.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(FondyColors.labelTertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(p.formattedTotalCost)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FondyColors.labelPrimary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FondyColors.labelTertiary)
            }
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button { Haptics.selection(); editTarget = p } label: { Label("Edit", systemImage: "pencil") }
            Button(role: .destructive) { Haptics.selection(); store.remove(id: p.id) } label: { Label("Delete", systemImage: "trash") }
        }
    }

    // MARK: - Add Button

    private var addFAB: some View {
        Button {
            Haptics.medium(); showAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(.blue, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
        .padding(.trailing, Spacing.pageMargin)
        .padding(.bottom, Spacing.xxxl)
        .accessibilityLabel("Add position")
    }

    // MARK: - Card Container

    private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(
                FondyColors.background,
                in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
            )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PaperPortfolioViewPreview()
    }
}

private struct PaperPortfolioViewPreview: View {
    var body: some View {
        PaperPortfolioView()
    }
}


import SwiftUI

struct AddPaperPositionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var ticker: String = ""
    @State private var sharesText: String = ""
    @State private var priceText: String = ""

    var onSave: (String, Double, Double) -> Void
    var existing: PaperPosition? = nil

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionGap) {
                    header
                    fieldsCard
                    if let total = computedTotal { totalRow(total) }
                    disclaimer
                }
                .padding(.horizontal, Spacing.pageMargin)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xxxl)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(existing == nil ? "Add position" : "Edit position")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { Haptics.light(); dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear { prefillIfNeeded() }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(existing == nil ? "Add a paper trade" : "Edit paper trade")
                .font(.title2.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)
            Text("Enter the ticker, number of shares, and the price you paid.")
                .font(.subheadline)
                .foregroundStyle(FondyColors.labelSecondary)
        }
    }

    private var fieldsCard: some View {
        VStack(spacing: 0) {
            fieldRow(title: "Ticker", placeholder: "AAPL", text: $ticker) {
                TextField("AAPL", text: $ticker)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
            }
            Divider().padding(.leading, Spacing.lg)
            fieldRow(title: "Shares", placeholder: "10", text: $sharesText) {
                TextField("10", text: $sharesText)
                    .keyboardType(.decimalPad)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
            }
            Divider().padding(.leading, Spacing.lg)
            fieldRow(title: "Price", placeholder: "150.00", text: $priceText) {
                TextField("150.00", text: $priceText)
                    .keyboardType(.decimalPad)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
            }
        }
        .padding(.vertical, Spacing.xs)
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    private func fieldRow<Content: View>(title: String, placeholder: String, text: Binding<String>, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelSecondary)
                .frame(width: 70, alignment: .leading)
            content()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private func totalRow(_ total: Double) -> some View {
        HStack {
            Text("Total cost")
                .font(.body.weight(.medium))
                .foregroundStyle(FondyColors.labelPrimary)
            Spacer()
            Text(total, format: .currency(code: "USD"))
                .font(.body.weight(.semibold))
                .foregroundStyle(FondyColors.labelPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            FondyColors.background,
            in: RoundedRectangle(cornerRadius: Spacing.cardRadius, style: .continuous)
        )
    }

    private var disclaimer: some View {
        Text("This is for practice only — no orders are sent to a broker.")
            .font(.caption)
            .foregroundStyle(FondyColors.labelTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Logic

    private func prefillIfNeeded() {
        guard let existing else { return }
        ticker = existing.ticker
        sharesText = existing.shares == existing.shares.rounded() ? "\(Int(existing.shares))" : String(format: "%.4f", existing.shares)
        priceText = String(format: "%.2f", existing.avgCost)
    }

    private func save() {
        guard canSave, let shares = sharesValue, let price = priceValue else { return }
        let t = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        Haptics.medium()
        onSave(t, shares, price)
        dismiss()
    }

    private func parsedDouble(_ s: String) -> Double? {
        let cleaned = s.filter { $0.isNumber || $0 == "." }
        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }

    private var sharesValue: Double? { parsedDouble(sharesText) }
    private var priceValue: Double? { parsedDouble(priceText) }
    private var computedTotal: Double? {
        guard let s = sharesValue, let p = priceValue, s > 0, p > 0 else { return nil }
        return s * p
    }
    private var canSave: Bool {
        let t = ticker.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t.isEmpty && (sharesValue ?? 0) > 0 && (priceValue ?? 0) > 0
    }
}
// MARK: - Preview

#Preview {
    AddPaperPositionView(onSave: { _,_,_ in })
}

#Preview("Editing") {
    let existing = PaperPosition(ticker: "AAPL", shares: 2.5, avgCost: 150.0)
    return AddPaperPositionView(onSave: { _,_,_ in }, existing: existing)
}


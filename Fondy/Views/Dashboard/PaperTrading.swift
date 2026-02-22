import SwiftUI
import Foundation

// MARK: - Paper Position Model

struct PaperPosition: Identifiable, Codable, Equatable {
    let id: UUID
    var ticker: String
    var shares: Double
    var avgCost: Double
    var createdAt: Date

    init(id: UUID = UUID(), ticker: String, shares: Double, avgCost: Double, createdAt: Date = Date()) {
        self.id = id
        self.ticker = ticker
        self.shares = shares
        self.avgCost = avgCost
        self.createdAt = createdAt
    }

    var totalCost: Double { shares * avgCost }

    var formattedShares: String {
        if shares == shares.rounded() { return "\(Int(shares))" }
        return String(format: "%.4f", shares)
    }

    var formattedAvgCost: String {
        String(format: "$%.2f", avgCost)
    }

    var formattedTotalCost: String {
        String(format: "$%.2f", totalCost)
    }
}

// MARK: - Paper Portfolio Store

@Observable
class PaperPortfolioStore {
    private let storageKey = "paper_positions_v1"

    var positions: [PaperPosition] = [] {
        didSet { persist() }
    }

    init() {
        load()
    }

    func add(ticker: String, shares: Double, price: Double) {
        let norm = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !norm.isEmpty, shares > 0, price > 0 else { return }
        let p = PaperPosition(ticker: norm, shares: shares, avgCost: price)
        positions.append(p)
    }

    func remove(id: UUID) {
        positions.removeAll { $0.id == id }
    }

    func update(id: UUID, ticker: String, shares: Double, price: Double) {
        let norm = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let idx = positions.firstIndex(where: { $0.id == id }) else { return }
        var existing = positions[idx]
        existing.ticker = norm
        existing.shares = shares
        existing.avgCost = price
        positions[idx] = existing
    }

    func clearAll() {
        positions.removeAll()
    }

    // MARK: - Persistence

    private func load() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([PaperPosition].self, from: data)
            self.positions = decoded
        } catch {
            self.positions = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(positions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Ignore persistence errors in this lightweight store
        }
    }
}

// MARK: - Sample Store for Previews

extension PaperPortfolioStore {
    static func sample() -> PaperPortfolioStore {
        let s = PaperPortfolioStore()
        s.positions = [
            PaperPosition(ticker: "AAPL", shares: 5, avgCost: 165.40, createdAt: Date().addingTimeInterval(-86_400)),
            PaperPosition(ticker: "NVDA", shares: 1.25, avgCost: 730.00, createdAt: Date())
        ]
        return s
    }
}

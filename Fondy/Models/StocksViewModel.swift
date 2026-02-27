//
//  StocksViewModel.swift
//  Fondy
//
//  View model and factory for the Stocks tab.
//  Mock data lives in Services/MockStockData.swift (SRP).
//

import SwiftUI

/// Manages state for the Stocks tab.
@Observable
class StocksViewModel {
    var orders: [StockOrder]
    var watchlist: [WatchlistStock]
    var topMovers: [TopMover]
    var availableStocks: [SelectableStock]

    init(
        orders: [StockOrder] = [],
        watchlist: [WatchlistStock] = [],
        topMovers: [TopMover] = [],
        availableStocks: [SelectableStock] = []
    ) {
        self.orders = orders
        self.watchlist = watchlist
        self.topMovers = topMovers
        self.availableStocks = availableStocks
    }

    // MARK: - Watchlist Mutations

    /// Removes a stock from the watchlist by id without animating the parent layout.
    func removeFromWatchlist(id: UUID) {
        watchlist.removeAll { $0.id == id }
    }

    // MARK: - Mock Factory

    static func createMock() -> StocksViewModel {
        StocksViewModel(
            orders: [
                StockOrder(
                    id: UUID(),
                    ticker: "AAPL",
                    companyName: "Apple",
                    logoSystemName: "apple.logo",
                    logoColor: .white,
                    orderType: .buy,
                    shares: 0.00595167,
                    statusLabel: "When market opens",
                    amount: 1.99,
                    currencySymbol: "$",
                    domain: "apple.com"
                ),
            ],
            watchlist: MockStockData.watchlistStocks,
            topMovers: MockStockData.topMovers,
            availableStocks: MockStockData.availableStocks
        )
    }

    // MARK: - Screener Data

    /// Full stock list for the screener/search — sourced from MockStockData.
    static var mockAllStocks: [AllStock] { MockStockData.allStocks }
}

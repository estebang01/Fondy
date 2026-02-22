//
//  StocksViewModel.swift
//  Fondy
//
//  View model and mock data for the Stocks tab.
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

    // MARK: - Mock Data

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
                    currencySymbol: "$"
                )
            ],
            watchlist: Self.mockWatchlistStocks,
            topMovers: Self.mockTopMovers,
            availableStocks: Self.mockAvailableStocks
        )
    }

    // MARK: - Mock Watchlist Stocks

    static let mockWatchlistStocks: [WatchlistStock] = [
        WatchlistStock(
            id: UUID(), name: "Apple", ticker: "AAPL",
            logoSystemName: "apple.logo", logoColor: .white,
            price: 227.82, changePercent: 1.23, currencySymbol: "$"
        ),
        WatchlistStock(
            id: UUID(), name: "Tesla", ticker: "TSLA",
            logoSystemName: "bolt.car.fill", logoColor: .white,
            price: 172.63, changePercent: -2.47, currencySymbol: "$"
        ),
        WatchlistStock(
            id: UUID(), name: "NVIDIA", ticker: "NVDA",
            logoSystemName: "cpu.fill", logoColor: .white,
            price: 875.39, changePercent: 4.18, currencySymbol: "$"
        ),
        WatchlistStock(
            id: UUID(), name: "Microsoft", ticker: "MSFT",
            logoSystemName: "square.grid.2x2.fill", logoColor: .white,
            price: 415.10, changePercent: 0.56, currencySymbol: "$"
        ),
        WatchlistStock(
            id: UUID(), name: "Amazon", ticker: "AMZN",
            logoSystemName: "cart.fill", logoColor: .white,
            price: 193.22, changePercent: -0.88, currencySymbol: "$"
        ),
    ]

    // MARK: - Mock Available Stocks

    static let mockAvailableStocks: [SelectableStock] = [
        SelectableStock(id: UUID(), companyName: "abrdn Physical Gold Shares ETF", ticker: "SGOL",
                        logoSystemName: "chart.bar.fill", logoColor: .white,
                        logoBackground: Color(.systemGray4)),
        SelectableStock(id: UUID(), companyName: "Global X Cloud Computing ETF", ticker: "CLOU",
                        logoSystemName: "cloud.fill", logoColor: .white,
                        logoBackground: .black),
        SelectableStock(id: UUID(), companyName: "iShares Emerging Markets Dividend ETF", ticker: "DVYE",
                        logoSystemName: "leaf.fill", logoColor: .white,
                        logoBackground: Color(red: 0.5, green: 0.8, blue: 0.1)),
        SelectableStock(id: UUID(), companyName: "iShares MSCI Indonesia ETF", ticker: "EIDO",
                        logoSystemName: "globe.asia.australia.fill", logoColor: .white,
                        logoBackground: Color(red: 0.5, green: 0.8, blue: 0.1)),
        SelectableStock(id: UUID(), companyName: "PIMCO Active Bond Exchange-Traded Fund", ticker: "BOND",
                        logoSystemName: "building.columns.fill", logoColor: Color(.systemGray),
                        logoBackground: Color(.systemGray5)),
        SelectableStock(id: UUID(), companyName: "iShares International Treasury Bond ETF", ticker: "BWX",
                        logoSystemName: "banknote.fill", logoColor: .white,
                        logoBackground: Color(red: 0.5, green: 0.8, blue: 0.1)),
        SelectableStock(id: UUID(), companyName: "Apple", ticker: "AAPL",
                        logoSystemName: "apple.logo", logoColor: .white,
                        logoBackground: .black),
        SelectableStock(id: UUID(), companyName: "Microsoft", ticker: "MSFT",
                        logoSystemName: "square.grid.2x2.fill", logoColor: .white,
                        logoBackground: Color(red: 0.0, green: 0.47, blue: 0.84)),
        SelectableStock(id: UUID(), companyName: "Tesla", ticker: "TSLA",
                        logoSystemName: "bolt.car.fill", logoColor: .white,
                        logoBackground: .red),
        SelectableStock(id: UUID(), companyName: "Amazon", ticker: "AMZN",
                        logoSystemName: "cart.fill", logoColor: .white,
                        logoBackground: Color(red: 1.0, green: 0.6, blue: 0.0)),
    ]

    // MARK: - Mock Top Movers (losers + gainers combined)

    static let mockTopMovers: [TopMover] = mockTopLosers + mockTopGainers

    static let mockTopLosers: [TopMover] = [
        TopMover(id: UUID(), companyName: "PTC Therapeutics Inc", ticker: "PTCT",
                 sector: "Pharmaceutical", logoSystemName: "pills.fill",
                 logoColor: .orange, logoBackground: Color(.systemGray5),
                 price: 18.88, changePercent: -21.33, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Sanofi", ticker: "SNY",
                 sector: "Pharmaceuticals", logoSystemName: "cross.vial.fill",
                 logoColor: .white, logoBackground: .black,
                 price: 43.13, changePercent: -19.17, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Tempo Automation", ticker: "TMPO",
                 sector: "Financials", logoSystemName: "t.square.fill",
                 logoColor: .white, logoBackground: Color(.systemGray3),
                 price: 0.11, changePercent: -15.38, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Enphase Energy Inc", ticker: "ENPH",
                 sector: "Solar Energy", logoSystemName: "sun.max.fill",
                 logoColor: .white, logoBackground: .orange,
                 price: 81.87, changePercent: -14.76, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "MoneyHero Limited", ticker: "MNY",
                 sector: "Finance", logoSystemName: "chart.bar.fill",
                 logoColor: .blue, logoBackground: Color(.systemGray5),
                 price: 1.47, changePercent: -13.02, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Ford", ticker: "F",
                 sector: "Automobiles", logoSystemName: "car.fill",
                 logoColor: .white, logoBackground: .blue,
                 price: 9.98, changePercent: -12.15, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "TPI Composites", ticker: "TPIC",
                 sector: "Wind Turbines", logoSystemName: "wind",
                 logoColor: Color(.systemGray), logoBackground: Color(.systemGray5),
                 price: 2.11, changePercent: -10.59, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "First Foundation", ticker: "FFWM",
                 sector: "Financial Services", logoSystemName: "building.columns.fill",
                 logoColor: .white, logoBackground: Color(.systemBlue).opacity(0.8),
                 price: 4.89, changePercent: -8.60, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Sunnova Energy International", ticker: "NOVA",
                 sector: "Solar", logoSystemName: "sun.max.circle.fill",
                 logoColor: Color(.systemGray), logoBackground: Color(.systemGray5),
                 price: 8.51, changePercent: -8.59, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Hutchison China", ticker: "HCM",
                 sector: "Drug Manufacturing", logoSystemName: "cross.circle.fill",
                 logoColor: .white, logoBackground: .black,
                 price: 18.44, changePercent: 8.41, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Under Armour (Class C)", ticker: "UA",
                 sector: "Performance Apparel", logoSystemName: "figure.run",
                 logoColor: .white, logoBackground: .red,
                 price: 6.18, changePercent: -8.31, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Fluence Energy", ticker: "FLNC",
                 sector: "Energy", logoSystemName: "bolt.circle.fill",
                 logoColor: .white, logoBackground: .indigo,
                 price: 17.11, changePercent: -8.11, currencySymbol: "$")
    ]

    // MARK: - Mock All Stocks (for screener)

    static let mockAllStocks: [AllStock] = [
        AllStock(companyName: "Agilent Technologies", ticker: "A", sector: .technology, sectorDetail: "Medical Diagnostics",
                 logoSystemName: "waveform.path.ecg", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.55, blue: 0.85),
                 price: 102.77, changePercent: -1.48, marketCap: .largeCap, peRatio: 28.5, dividendYield: 0.7, yearlyChange: 12.3),
        AllStock(companyName: "Alcoa", ticker: "AA", sector: .basicMaterials, sectorDetail: "Metals Mining",
                 logoSystemName: "diamond.fill", logoColor: .white, logoBackground: .blue,
                 price: 23.41, changePercent: -0.43, marketCap: .midCap, peRatio: 0, dividendYield: 0, yearlyChange: -15.2),
        AllStock(companyName: "Ares Acquisition Corp.", ticker: "AAC", sector: .financial, sectorDetail: "General purpose SPAC",
                 logoSystemName: "dollarsign.circle.fill", logoColor: .white, logoBackground: Color(red: 0.85, green: 0.1, blue: 0.35),
                 price: 9.59, changePercent: -2.14, marketCap: .smallCap, peRatio: 0, dividendYield: 0, yearlyChange: -4.1),
        AllStock(companyName: "American Airlines", ticker: "AAL", sector: .industrials, sectorDetail: "Airline Service",
                 logoSystemName: "airplane", logoColor: .white, logoBackground: .blue,
                 price: 10.92, changePercent: -2.06, marketCap: .midCap, peRatio: 5.2, dividendYield: 0, yearlyChange: -22.5),
        AllStock(companyName: "AAON", ticker: "AAON", sector: .industrials, sectorDetail: "HVAC",
                 logoSystemName: "thermometer.medium", logoColor: .white, logoBackground: Color(.systemGray3),
                 price: 53.75, changePercent: -0.13, marketCap: .midCap, peRatio: 45.3, dividendYield: 0.3, yearlyChange: 18.7),
        AllStock(companyName: "Advance Auto Parts", ticker: "AAP", sector: .consumerDiscretionary, sectorDetail: "Auto Parts & Tools",
                 logoSystemName: "wrench.and.screwdriver.fill", logoColor: .white, logoBackground: .red,
                 price: 49.90, changePercent: -2.21, marketCap: .midCap, peRatio: 0, dividendYield: 1.0, yearlyChange: -45.8),
        AllStock(companyName: "Apple", ticker: "AAPL", sector: .technology, sectorDetail: "iPhones & Macs",
                 logoSystemName: "apple.logo", logoColor: .white, logoBackground: .black,
                 price: 168.02, changePercent: 0.68, marketCap: .megaCap, peRatio: 28.3, dividendYield: 0.6, yearlyChange: 15.4),
        AllStock(companyName: "iShares MSCI All Country Asia ex Japan ETF", ticker: "AAXJ", sector: .financial, sectorDetail: "ETF",
                 logoSystemName: "globe.asia.australia.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.55, blue: 0.85),
                 price: 61.26, changePercent: 0.07, marketCap: .largeCap, peRatio: 0, dividendYield: 2.1, yearlyChange: 3.2),
        AllStock(companyName: "AbbVie Inc.", ticker: "ABBV", sector: .healthcare, sectorDetail: "Pharmaceuticals",
                 logoSystemName: "pills.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.35, blue: 0.7),
                 price: 154.38, changePercent: 1.23, marketCap: .megaCap, peRatio: 22.1, dividendYield: 3.8, yearlyChange: 8.9),
        AllStock(companyName: "Alphabet Inc.", ticker: "GOOGL", sector: .technology, sectorDetail: "Internet Services",
                 logoSystemName: "magnifyingglass", logoColor: .white, logoBackground: Color(red: 0.26, green: 0.52, blue: 0.96),
                 price: 131.86, changePercent: 1.05, marketCap: .megaCap, peRatio: 25.4, dividendYield: 0, yearlyChange: 22.1),
        AllStock(companyName: "Microsoft", ticker: "MSFT", sector: .technology, sectorDetail: "Software",
                 logoSystemName: "square.grid.2x2.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.47, blue: 0.84),
                 price: 369.14, changePercent: 0.87, marketCap: .megaCap, peRatio: 35.2, dividendYield: 0.8, yearlyChange: 28.3),
        AllStock(companyName: "Tesla", ticker: "TSLA", sector: .consumerDiscretionary, sectorDetail: "Electric Vehicles",
                 logoSystemName: "bolt.car.fill", logoColor: .white, logoBackground: .red,
                 price: 238.45, changePercent: -1.32, marketCap: .megaCap, peRatio: 72.1, dividendYield: 0, yearlyChange: 45.2),
        AllStock(companyName: "Amazon", ticker: "AMZN", sector: .consumerDiscretionary, sectorDetail: "E-commerce",
                 logoSystemName: "cart.fill", logoColor: .white, logoBackground: Color(red: 1.0, green: 0.6, blue: 0.0),
                 price: 127.72, changePercent: 2.15, marketCap: .megaCap, peRatio: 58.3, dividendYield: 0, yearlyChange: 35.7),
        AllStock(companyName: "JPMorgan Chase", ticker: "JPM", sector: .financial, sectorDetail: "Banking",
                 logoSystemName: "building.columns.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.3, blue: 0.6),
                 price: 148.22, changePercent: 0.54, marketCap: .megaCap, peRatio: 10.8, dividendYield: 2.6, yearlyChange: 18.4),
        AllStock(companyName: "Johnson & Johnson", ticker: "JNJ", sector: .healthcare, sectorDetail: "Pharmaceuticals",
                 logoSystemName: "cross.case.fill", logoColor: .white, logoBackground: .red,
                 price: 155.80, changePercent: -0.38, marketCap: .megaCap, peRatio: 15.2, dividendYield: 3.0, yearlyChange: -5.1),
        AllStock(companyName: "Procter & Gamble", ticker: "PG", sector: .consumerStaples, sectorDetail: "Consumer Products",
                 logoSystemName: "house.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.35, blue: 0.7),
                 price: 148.95, changePercent: 0.22, marketCap: .megaCap, peRatio: 24.8, dividendYield: 2.5, yearlyChange: 1.2),
        AllStock(companyName: "Intel", ticker: "INTC", sector: .technology, sectorDetail: "Semiconductors",
                 logoSystemName: "cpu.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.45, blue: 0.85),
                 price: 35.49, changePercent: 3.21, marketCap: .largeCap, peRatio: 0, dividendYield: 1.4, yearlyChange: -28.5),
        AllStock(companyName: "Pfizer", ticker: "PFE", sector: .healthcare, sectorDetail: "Pharmaceuticals",
                 logoSystemName: "pills.circle.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.45, blue: 0.85),
                 price: 28.73, changePercent: -0.87, marketCap: .largeCap, peRatio: 30.1, dividendYield: 5.7, yearlyChange: -18.3),
        AllStock(companyName: "Realty Income", ticker: "O", sector: .realEstate, sectorDetail: "REIT",
                 logoSystemName: "building.2.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.35, blue: 0.7),
                 price: 52.18, changePercent: 0.45, marketCap: .largeCap, peRatio: 42.1, dividendYield: 5.9, yearlyChange: -12.1),
        AllStock(companyName: "Exxon Mobil", ticker: "XOM", sector: .energy, sectorDetail: "Oil & Gas",
                 logoSystemName: "fuelpump.fill", logoColor: .white, logoBackground: .red,
                 price: 104.52, changePercent: -0.65, marketCap: .megaCap, peRatio: 10.2, dividendYield: 3.4, yearlyChange: 5.8),
        AllStock(companyName: "NextEra Energy", ticker: "NEE", sector: .utilities, sectorDetail: "Electric Utilities",
                 logoSystemName: "bolt.fill", logoColor: .white, logoBackground: Color(red: 0.0, green: 0.55, blue: 0.85),
                 price: 59.82, changePercent: 0.33, marketCap: .largeCap, peRatio: 19.8, dividendYield: 3.1, yearlyChange: -8.4),
        AllStock(companyName: "Verizon Communications", ticker: "VZ", sector: .communication, sectorDetail: "Telecom",
                 logoSystemName: "antenna.radiowaves.left.and.right", logoColor: .white, logoBackground: .red,
                 price: 34.57, changePercent: 0.12, marketCap: .largeCap, peRatio: 7.2, dividendYield: 7.1, yearlyChange: -15.6),
    ]

    static let mockTopGainers: [TopMover] = [
        TopMover(id: UUID(), companyName: "DexCom Inc", ticker: "DXCM",
                 sector: "Biotechnology", logoSystemName: "waveform.path.ecg",
                 logoColor: .white, logoBackground: Color(red: 0.1, green: 0.7, blue: 0.2),
                 price: 89.30, changePercent: 10.18, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Intel", ticker: "INTC",
                 sector: "Semiconductors", logoSystemName: "cpu.fill",
                 logoColor: .white, logoBackground: Color(red: 0.0, green: 0.45, blue: 0.85),
                 price: 35.49, changePercent: 9.33, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Capital One", ticker: "COF",
                 sector: "Credit Services", logoSystemName: "creditcard.fill",
                 logoColor: .white, logoBackground: Color(red: 0.7, green: 0.1, blue: 0.1),
                 price: 97.49, changePercent: 9.05, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Eldorado Gold Corporation", ticker: "EGO",
                 sector: "Gold Mining", logoSystemName: "circle.fill",
                 logoColor: Color(red: 1.0, green: 0.8, blue: 0.0), logoBackground: .black,
                 price: 10.74, changePercent: 8.81, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Hutchison China", ticker: "HCM",
                 sector: "Drug Manufacturing", logoSystemName: "cross.circle.fill",
                 logoColor: .white, logoBackground: .black,
                 price: 18.44, changePercent: 8.41, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Rambus", ticker: "RMBS",
                 sector: "Technology", logoSystemName: "r.circle.fill",
                 logoColor: .white, logoBackground: Color(red: 0.0, green: 0.45, blue: 0.85),
                 price: 51.87, changePercent: 7.44, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Amazon", ticker: "AMZN",
                 sector: "E-commerce", logoSystemName: "cart.fill",
                 logoColor: .white, logoBackground: Color(red: 0.08, green: 0.08, blue: 0.08),
                 price: 127.72, changePercent: 6.74, currencySymbol: "$"),
        TopMover(id: UUID(), companyName: "Novo Nordisk", ticker: "NVO",
                 sector: "Pharmaceuticals", logoSystemName: "cross.vial.fill",
                 logoColor: .white, logoBackground: Color(red: 0.0, green: 0.55, blue: 0.85),
                 price: 94.12, changePercent: 6.21, currencySymbol: "$"),
    ]
}

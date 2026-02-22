//
//  StockDetail.swift
//  Fondy
//

import SwiftUI

/// Full detail data for a single stock.
struct StockDetail: Identifiable, Hashable {
    let id: UUID
    let companyName: String
    let ticker: String
    let sector: String
    let logoSystemName: String
    let logoColor: Color
    let logoBackground: Color
    let price: Double
    let priceChange: Double
    let priceChangePercent: Double
    let currencySymbol: String
    let marketStatus: String
    let chartPoints: [Double]
    let chartData: [ChartDataPoint]
    let marketCap: String
    let peRatio: String
    let eps: String
    let dividendYield: String
    let beta: String
    let priceAlertValue: Double
    let analystCount: Int
    let strongBuyPercent: Double
    let buyPercent: Double
    let holdPercent: Double
    let aboutText: String
    let financials: StockFinancials
    /// Ordered list of period returns shown in the Returns card (e.g. 1M → 3Y).
    let periodReturns: [PeriodReturn]
    /// Optional fund analysis (portfolio breakdown). Nil for individual stocks.
    let fundAnalysis: FundAnalysis?

    // MARK: - Init (chartData defaults to [] so existing call sites compile unchanged)

    init(
        id: UUID = UUID(),
        companyName: String,
        ticker: String,
        sector: String,
        logoSystemName: String,
        logoColor: Color,
        logoBackground: Color,
        price: Double,
        priceChange: Double,
        priceChangePercent: Double,
        currencySymbol: String,
        marketStatus: String,
        chartPoints: [Double],
        chartData: [ChartDataPoint] = [],
        marketCap: String,
        peRatio: String,
        eps: String,
        dividendYield: String,
        beta: String,
        priceAlertValue: Double,
        analystCount: Int,
        strongBuyPercent: Double,
        buyPercent: Double,
        holdPercent: Double,
        aboutText: String = "",
        financials: StockFinancials,
        periodReturns: [PeriodReturn] = [],
        fundAnalysis: FundAnalysis? = nil
    ) {
        self.id = id
        self.companyName = companyName
        self.ticker = ticker
        self.sector = sector
        self.logoSystemName = logoSystemName
        self.logoColor = logoColor
        self.logoBackground = logoBackground
        self.price = price
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.currencySymbol = currencySymbol
        self.marketStatus = marketStatus
        self.chartPoints = chartPoints
        self.chartData = chartData
        self.marketCap = marketCap
        self.peRatio = peRatio
        self.eps = eps
        self.dividendYield = dividendYield
        self.beta = beta
        self.priceAlertValue = priceAlertValue
        self.analystCount = analystCount
        self.strongBuyPercent = strongBuyPercent
        self.buyPercent = buyPercent
        self.holdPercent = holdPercent
        self.aboutText = aboutText
        self.financials = financials
        self.periodReturns = periodReturns
        self.fundAnalysis = fundAnalysis
    }

    // Hashable / Equatable — use id only (Color isn't Hashable)
    static func == (lhs: StockDetail, rhs: StockDetail) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var isPositive: Bool { priceChange >= 0 }

    var formattedPrice: String {
        String(format: "\(currencySymbol)%.2f", price)
    }

    var formattedChange: String {
        String(format: "%@\(currencySymbol)%.2f", priceChange >= 0 ? "+" : "", priceChange)
    }

    var formattedChangePercent: String {
        String(format: "%.1f%%", abs(priceChangePercent))
    }

    static let apple = StockDetail(
        id: UUID(),
        companyName: "Apple",
        ticker: "AAPL",
        sector: "iPhones & Macs",
        logoSystemName: "apple.logo",
        logoColor: .white,
        logoBackground: .black,
        price: 168.02,
        priceChange: -0.33,
        priceChangePercent: -0.2,
        currencySymbol: "$",
        marketStatus: "The market is currently closed\nIt will open again at Oct 30 at 9:30 PM",
        chartPoints: [
            168.55, 172.3, 178.1, 185.4, 189.2, 192.7, 187.3, 183.6, 180.1,
            176.8, 179.4, 182.0, 185.7, 191.3, 195.8, 196.46, 193.2, 188.7,
            185.1, 181.9, 178.3, 175.6, 172.1, 169.8, 171.4, 173.9, 170.2,
            167.5, 169.1, 170.8, 168.4, 165.81, 166.9, 168.02
        ],
        chartData: Self.mockChartData,
        marketCap: "$2,629.99B",
        peRatio: "28.27",
        eps: "$6.11",
        dividendYield: "0.57%",
        beta: "1.30",
        priceAlertValue: 160.0,
        analystCount: 42,
        strongBuyPercent: 0.26,
        buyPercent: 0.43,
        holdPercent: 0.29,
        aboutText: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, a line of smartphones; Mac, a line of personal computers; iPad, a line of multi-purpose tablets; and wearables, home, and accessories comprising AirPods, Apple TV, Apple Watch, Beats products, HomePod, iPod touch, and other Apple-branded and third-party accessories.\n\nIt also provides AppleCare support and cloud services; and operates various platforms, including the App Store that allow customers to discover and download applications and digital content, such as books, music, video, games, and podcasts. The company serves consumers, and small and mid-sized businesses, and the education, enterprise and government customers through its retail and online stores and its direct sales force.",
        financials: .apple,
        periodReturns: [
            PeriodReturn(label: "1M",  percent:  2.34, rank:  3, rankOutOf: 24, updatedAt: PeriodReturn.date("2025-03")),
            PeriodReturn(label: "6M",  percent:  8.71, rank:  5, rankOutOf: 24, updatedAt: PeriodReturn.date("2025-03")),
            PeriodReturn(label: "YTD", percent: -1.48, rank: 14, rankOutOf: 24, updatedAt: PeriodReturn.date("2025-03")),
            PeriodReturn(label: "1Y",  percent: 15.42, rank:  2, rankOutOf: 24, updatedAt: PeriodReturn.date("2025-02")),
            PeriodReturn(label: "2Y",  percent: 28.09, rank:  4, rankOutOf: 22, updatedAt: PeriodReturn.date("2025-02")),
            PeriodReturn(label: "3Y",  percent: 52.37, rank:  1, rankOutOf: 20, updatedAt: PeriodReturn.date("2025-02"))
        ],
        fundAnalysis: .sample
    )

    // MARK: - Mock Chart Data (34 trading days, ~6 months)

    static let mockChartData: [ChartDataPoint] = {
        let rawValues: [(String, Double)] = [
            ("2024-08-01", 168.55), ("2024-08-05", 172.30), ("2024-08-08", 178.10),
            ("2024-08-12", 185.40), ("2024-08-15", 189.20), ("2024-08-19", 192.70),
            ("2024-08-22", 187.30), ("2024-08-26", 183.60), ("2024-08-29", 180.10),
            ("2024-09-02", 176.80), ("2024-09-05", 179.40), ("2024-09-09", 182.00),
            ("2024-09-12", 185.70), ("2024-09-16", 191.30), ("2024-09-19", 195.80),
            ("2024-09-23", 196.46), ("2024-09-26", 193.20), ("2024-09-30", 188.70),
            ("2024-10-03", 185.10), ("2024-10-07", 181.90), ("2024-10-10", 178.30),
            ("2024-10-14", 175.60), ("2024-10-17", 172.10), ("2024-10-21", 169.80),
            ("2024-10-24", 171.40), ("2024-10-28", 173.90), ("2024-10-31", 170.20),
            ("2024-11-04", 167.50), ("2024-11-07", 169.10), ("2024-11-11", 170.80),
            ("2024-11-14", 168.40), ("2024-11-18", 165.81), ("2024-11-21", 166.90),
            ("2024-11-25", 168.02),
        ]
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        return rawValues.compactMap { (dateStr, value) in
            guard let date = fmt.date(from: dateStr) else { return nil }
            return ChartDataPoint(date: date, value: value)
        }
    }()
}

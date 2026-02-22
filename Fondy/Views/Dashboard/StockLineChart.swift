//
//  StockLineChart.swift
//  Fondy
//
//  Interactive NAV line chart with a long-press / drag tooltip.
//  Designed for mutual fund / portfolio performance tracking.
//
//  Interaction:
//    • Drag → snaps scrubber + tooltip to the nearest data point
//    • Tooltip and vertical line always sit exactly on the data point, never on raw touch X
//    • Smooth cubic Bézier spline (Catmull-Rom → Bézier conversion)
//    • Smooth haptic tick on each new data point
//    • Touch lift → tooltip fades out
//

import SwiftUI

// MARK: - Main View

struct StockLineChart: View {
    // Legacy flat-array support (used where no dated points are available)
    let points: [Double]
    let isPositive: Bool
    let minPrice: Double
    let maxPrice: Double

    // Rich dated points (drives the tooltip when available)
    var chartData: [ChartDataPoint] = []
    var currencySymbol: String = "$"
    /// The period's start value used to compute total-return since period start.
    var periodStartValue: Double? = nil

    // MARK: - Scrubber state

    @State private var activeIndex: Int? = nil
    @State private var isInteracting = false
    @State private var chartSize: CGSize = .zero

    private var lineColor: Color {
        isPositive ? FondyColors.positive : FondyColors.negative
    }

    // Use chartData if available, else derive from flat points
    private var effectivePoints: [Double] {
        chartData.isEmpty ? points : chartData.map(\.value)
    }

    private var effectiveMin: Double { effectivePoints.min() ?? minPrice }
    private var effectiveMax: Double { effectivePoints.max() ?? maxPrice }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topLeading) {
            chartCanvas
            if isInteracting, let idx = activeIndex {
                scrubberOverlay(idx: idx)
                tooltipCard(idx: idx)
            }
        }
        .accessibilityLabel("NAV chart, \(isPositive ? "positive" : "negative") trend")
        .accessibilityValue(accessibilitySummary)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let newIndex = indexAt(x: value.location.x, width: chartSize.width)
                    if newIndex != activeIndex {
                        Haptics.selection()
                    }
                    activeIndex = newIndex
                    withAnimation(.springInteractive) { isInteracting = true }
                }
                .onEnded { _ in
                    withAnimation(.springGentle) { isInteracting = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        activeIndex = nil
                    }
                }
        )
    }
}

// MARK: - Chart Canvas

private extension StockLineChart {

    var chartCanvas: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pts = effectivePoints
            let lo = effectiveMin
            let hi = effectiveMax
            let range = hi - lo > 0 ? hi - lo : 1
            let step = w / CGFloat(max(pts.count - 1, 1))

            let normalized: [CGFloat] = pts.map {
                CGFloat(($0 - lo) / range)
            }

            let yOf: (CGFloat) -> CGFloat = { n in
                h - (n * h * 0.8 + h * 0.1)
            }

            // Build CGPoints for the spline
            let cgPoints: [CGPoint] = normalized.enumerated().map { i, n in
                CGPoint(x: CGFloat(i) * step, y: yOf(n))
            }

            let linePath  = smoothPath(through: cgPoints, closed: false)
            let fillPath  = smoothFillPath(through: cgPoints, width: w, height: h)

            ZStack {
                // Gradient fill under the line
                fillPath.fill(
                    LinearGradient(
                        colors: [lineColor.opacity(0.18), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Main smooth line
                linePath.stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // Dot snapped to the active data point
                if isInteracting, let idx = activeIndex, idx < cgPoints.count {
                    let pt = cgPoints[idx]
                    Circle()
                        .fill(lineColor)
                        .frame(width: 10, height: 10)
                        .shadow(color: lineColor.opacity(0.4), radius: 4)
                        .position(x: pt.x, y: pt.y)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear { chartSize = geo.size }
            .onChange(of: geo.size) { chartSize = $1 }
        }
    }

    // MARK: Catmull-Rom → cubic Bézier spline

    /// Smooth open path through all points using Catmull-Rom tension = 1/3.
    func smoothPath(through points: [CGPoint], closed: Bool) -> Path {
        guard points.count > 1 else {
            return Path { path in points.first.map { path.move(to: $0) } }
        }
        return Path { path in
            path.move(to: points[0])
            for i in 0..<(points.count - 1) {
                let (cp1, cp2) = controlPoints(points: points, index: i)
                path.addCurve(to: points[i + 1], control1: cp1, control2: cp2)
            }
        }
    }

    /// Closed fill path: smooth top edge + straight bottom edge.
    func smoothFillPath(through points: [CGPoint], width: CGFloat, height: CGFloat) -> Path {
        guard !points.isEmpty else { return Path() }
        return Path { path in
            path.move(to: CGPoint(x: points[0].x, y: height))
            path.addLine(to: points[0])
            for i in 0..<(points.count - 1) {
                let (cp1, cp2) = controlPoints(points: points, index: i)
                path.addCurve(to: points[i + 1], control1: cp1, control2: cp2)
            }
            path.addLine(to: CGPoint(x: width, y: height))
            path.closeSubpath()
        }
    }

    /// Catmull-Rom control points for segment i → i+1, tension α = 1/3.
    func controlPoints(points: [CGPoint], index i: Int) -> (CGPoint, CGPoint) {
        let p0 = points[max(i - 1, 0)]
        let p1 = points[i]
        let p2 = points[i + 1]
        let p3 = points[min(i + 2, points.count - 1)]

        let α: CGFloat = 1.0 / 3.0

        let cp1 = CGPoint(
            x: p1.x + (p2.x - p0.x) * α,
            y: p1.y + (p2.y - p0.y) * α
        )
        let cp2 = CGPoint(
            x: p2.x - (p3.x - p1.x) * α,
            y: p2.y - (p3.y - p1.y) * α
        )
        return (cp1, cp2)
    }
}

// MARK: - Scrubber Line (snapped to data point X)

private extension StockLineChart {

    @ViewBuilder
    func scrubberOverlay(idx: Int) -> some View {
        GeometryReader { geo in
            let pts = effectivePoints
            guard !pts.isEmpty else { return AnyView(EmptyView()) }
            let step = geo.size.width / CGFloat(max(pts.count - 1, 1))
            // Always snap to the exact data point X — never the raw touch X
            let dotX = CGFloat(idx) * step

            return AnyView(
                Rectangle()
                    .fill(FondyColors.labelTertiary.opacity(0.35))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .position(x: dotX, y: geo.size.height / 2)
                    .transition(.opacity)
            )
        }
    }
}

// MARK: - Tooltip Card (snapped to data point X)

private extension StockLineChart {

    @ViewBuilder
    func tooltipCard(idx: Int) -> some View {
        GeometryReader { geo in
            let pts = effectivePoints
            guard idx < pts.count else { return AnyView(EmptyView()) }

            let step = geo.size.width / CGFloat(max(pts.count - 1, 1))
            // Tooltip X always anchored to the data point, not raw touch
            let dotX = CGFloat(idx) * step

            let nav = pts[idx]
            let prevNav = idx > 0 ? pts[idx - 1] : nav
            let dailyAbs = nav - prevNav
            let dailyPct = prevNav != 0 ? (dailyAbs / prevNav) * 100 : 0
            let startNav = periodStartValue ?? pts.first ?? nav
            let totalReturn = startNav != 0 ? ((nav - startNav) / startNav) * 100 : 0
            let totalAbs = nav - startNav

            let tooltipW: CGFloat = 175
            let margin: CGFloat = 12

            // Clamp so tooltip never overflows either edge
            var tx = dotX - tooltipW / 2
            tx = max(margin, min(tx, geo.size.width - tooltipW - margin))
            let ty: CGFloat = 6

            return AnyView(
                TooltipCardView(
                    date: idx < chartData.count ? chartData[idx].date : nil,
                    nav: nav,
                    dailyAbs: dailyAbs,
                    dailyPct: dailyPct,
                    totalAbs: totalAbs,
                    totalPct: totalReturn,
                    currencySymbol: currencySymbol
                )
                .frame(width: tooltipW)
                .fixedSize(horizontal: false, vertical: true)
                .offset(x: tx, y: ty)
                .transition(.scale(scale: 0.9, anchor: .top).combined(with: .opacity))
            )
        }
    }
}

// MARK: - Tooltip Card View

private struct TooltipCardView: View {
    let date: Date?
    let nav: Double
    let dailyAbs: Double
    let dailyPct: Double
    let totalAbs: Double
    let totalPct: Double
    let currencySymbol: String

    private var dailyColor: Color {
        if dailyAbs > 0 { return FondyColors.positive }
        if dailyAbs < 0 { return FondyColors.negative }
        return FondyColors.labelSecondary
    }

    private var totalColor: Color {
        if totalAbs > 0 { return FondyColors.positive }
        if totalAbs < 0 { return FondyColors.negative }
        return FondyColors.labelSecondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Date
            if let date {
                Text(date, format: .dateTime.day().month(.abbreviated).year())
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(FondyColors.labelTertiary)
            }

            // NAV value — largest emphasis
            Text("\(currencySymbol)\(nav, specifier: "%.2f")")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(FondyColors.labelPrimary)
                .contentTransition(.numericText())

            Divider()
                .padding(.vertical, 1)

            // Daily change row
            HStack(spacing: 4) {
                Image(systemName: dailyAbs >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(dailyColor)
                Text("\(dailyAbs >= 0 ? "+" : "")\(currencySymbol)\(abs(dailyAbs), specifier: "%.2f")")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(dailyColor)
                Text("(\(dailyPct >= 0 ? "+" : "")\(dailyPct, specifier: "%.2f")%)")
                    .font(.caption2)
                    .foregroundStyle(dailyColor)
            }

            // Period total return row
            HStack(spacing: 4) {
                Text("Period:")
                    .font(.caption2)
                    .foregroundStyle(FondyColors.labelTertiary)
                Text("\(totalAbs >= 0 ? "+" : "")\(totalPct, specifier: "%.2f")%")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(totalColor)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        )
    }
}

// MARK: - Helpers

private extension StockLineChart {

    func indexAt(x: CGFloat, width: CGFloat) -> Int {
        let pts = effectivePoints
        guard !pts.isEmpty, width > 0 else { return 0 }
        let step = width / CGFloat(max(pts.count - 1, 1))
        let raw = Int((x / step).rounded())
        return raw.clamped(to: 0...(pts.count - 1))
    }

    var accessibilitySummary: String {
        guard let first = effectivePoints.first, let last = effectivePoints.last else { return "" }
        let change = last - first
        let sign = change >= 0 ? "up" : "down"
        return "\(sign) \(currencySymbol)\(String(format: "%.2f", abs(change))) over period"
    }
}

// MARK: - Clamped helper

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview

#Preview("Interactive Chart") {
    let data = StockDetail.mockChartData
    let values = data.map(\.value)
    StockLineChart(
        points: values,
        isPositive: true,
        minPrice: values.min() ?? 0,
        maxPrice: values.max() ?? 1,
        chartData: data,
        currencySymbol: "$",
        periodStartValue: values.first
    )
    .frame(height: 180)
    .padding(.horizontal, Spacing.pageMargin)
    .padding(.vertical, Spacing.xl)
}

#Preview("Negative Trend") {
    let data = StockDetail.mockChartData
    let values = data.map(\.value).reversed() as [Double]
    StockLineChart(
        points: values,
        isPositive: false,
        minPrice: values.min() ?? 0,
        maxPrice: values.max() ?? 1,
        chartData: data.map { ChartDataPoint(date: $0.date, value: values[$0.id.hashValue % values.count]) },
        currencySymbol: "$"
    )
    .frame(height: 180)
    .padding(.horizontal, Spacing.pageMargin)
    .padding(.vertical, Spacing.xl)
}

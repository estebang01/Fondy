//
//  DonutChart.swift
//  Fondy
//

import SwiftUI

// MARK: - Donut Slice Layout

struct DonutSliceLayout: Identifiable {
    let id: UUID
    let originalIndex: Int
    let color: Color
    let label: String
    let percent: Double
    let from: Double
    let to: Double
}

// MARK: - Donut Chart (Interactive)

struct DonutChart: View {
    let slices: [AnalysisSlice]
    @Binding var selectedIndex: Int?
    let size: CGFloat

    private let gap: Double = 6.0
    private var strokeWidth: CGFloat { size * 0.155 }

    private var layouts: [DonutSliceLayout] {
        let total = slices.reduce(0) { $0 + $1.percent }
        guard total > 0 else { return [] }
        let usable = 360.0 - gap * Double(slices.count)
        var cursor = 0.0
        return slices.enumerated().map { idx, slice in
            let sweep = (slice.percent / total) * usable
            let start = cursor; cursor += sweep + gap
            return DonutSliceLayout(id: slice.id, originalIndex: idx,
                                    color: slice.color, label: slice.label,
                                    percent: slice.percent, from: start, to: start + sweep)
        }
    }

    var body: some View {
        let computed = layouts
        let selected = selectedIndex.flatMap { idx in computed.first { $0.originalIndex == idx } }

        ZStack {
            Circle().stroke(FondyColors.background.opacity(0.1),lineWidth: strokeWidth)

            ForEach(computed) { layout in
                let isSel = selectedIndex == layout.originalIndex
                ArcSegment(fromDegrees: layout.from, toDegrees: layout.to,
                           lineWidth: isSel ? strokeWidth * 1.18 : strokeWidth)
                    .stroke(layout.color.opacity(selectedIndex == nil ? 1.0 : isSel ? 1.0 : 0.3),
                            style: StrokeStyle(lineWidth: isSel ? strokeWidth * 1.18 : strokeWidth, lineCap: .round))
                    .scaleEffect(isSel ? 1.06 : 1.0)
                    .animation(.springInteractive, value: isSel)
                    .contentShape(Circle())
                    .onTapGesture {
                        withAnimation(.springInteractive) {
                            selectedIndex = selectedIndex == layout.originalIndex ? nil : layout.originalIndex
                        }
                        Haptics.selection()
                    }
            }

            // Centre tooltip / idle label
            Group {
                if let sel = selected {
                    VStack(spacing: 3) {
                        Text(String(format: "%.1f%%", sel.percent))
                            .font(.system(size: size * 0.13, weight: .bold))
                            .foregroundStyle(sel.color)
                            .contentTransition(.numericText())
                        Text(sel.label)
                            .font(.system(size: size * 0.075))
                            .foregroundStyle(FondyColors.labelSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: size * 0.48)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                } else if let top = slices.max(by: { $0.percent < $1.percent }) {
                    VStack(spacing: 3) {
                        Text(String(format: "%.0f%%", top.percent))
                            .font(.system(size: size * 0.13, weight: .bold))
                            .foregroundStyle(FondyColors.labelPrimary)
                        Text(top.label)
                            .font(.system(size: size * 0.075))
                            .foregroundStyle(FondyColors.labelSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: size * 0.48)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Arc Segment Shape

struct ArcSegment: Shape {
    var fromDegrees: Double
    var toDegrees: Double
    var lineWidth: CGFloat

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(fromDegrees, toDegrees) }
        set { fromDegrees = newValue.first; toDegrees = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let inset = lineWidth / 2
        let r = rect.insetBy(dx: inset, dy: inset)
        let centre = CGPoint(x: r.midX, y: r.midY)
        let radius = min(r.width, r.height) / 2
        let startRad = (fromDegrees - 90) * .pi / 180
        let endRad   = (toDegrees   - 90) * .pi / 180
        var p = Path()
        p.addArc(center: centre, radius: radius,
                 startAngle: .radians(startRad), endAngle: .radians(endRad), clockwise: false)
        return p
    }
}

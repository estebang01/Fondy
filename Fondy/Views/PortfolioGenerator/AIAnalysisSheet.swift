import SwiftUI

// MARK: - AI Analysis Sheet

/// A playful, Apple-like analysis sheet that shows progress and then
/// reveals insights and suggestions.
struct AIAnalysisSheet: View {
    let question: String
    @Binding var isPresented: Bool

    @State private var progress: Double = 0
    @State private var status: String = "Preparing…"
    @State private var result: AIAnalysisResult?

    var body: some View {
        VStack(spacing: Spacing.sectionGap) {
            Capsule()
                .fill(FondyColors.fillTertiary)
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.lg)
                .accessibilityHidden(true)

            VStack(spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(.tint)
                    Text("AI Analysis")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                Text(question)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let result { resultView(result) } else { progressView }

            Button {
                Haptics.light()
                isPresented = false
            } label: {
                Text(result == nil ? "Cancel" : "Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg)
                    .background(.tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.pageMargin)
            }
            .buttonStyle(.plain)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .task { await runAnalysis() }
    }

    // MARK: - Progress View

    private var progressView: some View {
        VStack(spacing: Spacing.xl) {
            RainbowActivityView(size: 120, lineWidth: 10)
                .accessibilityHidden(true)

            VStack(spacing: Spacing.xs) {
                Text(status)
                    .font(.subheadline)
                    .foregroundStyle(FondyColors.labelSecondary)
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                    .padding(.horizontal, Spacing.pageMargin)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Result View

    @ViewBuilder
    private func resultView(_ result: AIAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sectionGap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(result.headline)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                ForEach(result.keyPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text(point)
                            .font(.subheadline)
                            .foregroundStyle(FondyColors.labelPrimary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Suggestions")
                    .font(.headline)
                    .foregroundStyle(FondyColors.labelPrimary)
                ForEach(result.suggestions, id: \.self) { tip in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.tint)
                        Text(tip)
                            .font(.subheadline)
                            .foregroundStyle(FondyColors.labelSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Run Analysis

    private func runAnalysis() async {
        await withTaskGroup(of: Void.self) { _ in
            let res = await AIAnalysisService.analyze(question: question) { prog, msg in
                progress = prog
                status = msg
            }
            withAnimation(.springGentle) {
                result = res
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AIAnalysisSheet(question: "What do you think about increasing AAPL exposure?", isPresented: .constant(true))
}


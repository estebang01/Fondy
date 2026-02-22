import SwiftUI

// MARK: - AI Analysis Result

struct AIAnalysisResult: Identifiable {
    let id = UUID()
    let headline: String
    let keyPoints: [String]
    let suggestions: [String]
}

// MARK: - AI Analysis Service (Mock)

/// A lightweight mock service that simulates an AI analysis workflow with progress updates.
/// This is UI-focused and does not call any network APIs.
enum AIAnalysisService {

    /// Performs a simulated analysis for a given question.
    /// - Parameters:
    ///   - question: The user's question to analyze.
    ///   - update: A closure that receives progress (0...1) and a status message.
    /// - Returns: A synthesized `AIAnalysisResult`.
    static func analyze(
        question: String,
        update: @escaping (_ progress: Double, _ message: String) -> Void
    ) async -> AIAnalysisResult {
        let steps: [(String, UInt64)] = [
            ("Understanding your question…", 500),
            ("Scanning market context…", 600),
            ("Assessing risk & exposure…", 650),
            ("Summarizing insights…", 550)
        ]

        for (index, step) in steps.enumerated() {
            await MainActor.run {
                let progress = Double(index) / Double(steps.count)
                update(progress, step.0)
            }
            try? await Task.sleep(nanoseconds: step.1 * 1_000_000)
        }

        await MainActor.run {
            update(1.0, "Done")
        }

        // Very simple synthesis based on keywords in the question to keep things playful.
        let lower = question.lowercased()
        var points: [String] = []
        var suggestions: [String] = []

        if lower.contains("apple") || lower.contains("aapl") {
            points.append("AAPL shows strong long-term fundamentals with healthy cash flows.")
            suggestions.append("Compare AAPL to sector ETFs (e.g., QQQ)")
        }
        if lower.contains("risk") {
            points.append("Consider aligning exposure with your risk tolerance and horizon.")
            suggestions.append("Run the portfolio generator to calibrate risk")
        }
        if lower.contains("crypto") {
            points.append("Crypto exposure can increase volatility; diversify across assets.")
            suggestions.append("Set a max allocation cap for volatile assets")
        }

        if points.isEmpty {
            points = [
                "Diversification across sectors can improve risk-adjusted returns.",
                "Dollar-cost averaging helps reduce timing risk.",
                "Rebalance periodically to maintain your target allocations."
            ]
        }

        if suggestions.isEmpty {
            suggestions = [
                "Explore sector tilts that match your interests",
                "Review your monthly contribution plan",
                "Try the AI Portfolio Generator"
            ]
        }

        return AIAnalysisResult(
            headline: "Here's what I found",
            keyPoints: points,
            suggestions: suggestions
        )
    }
}

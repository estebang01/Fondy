//
//  ChatMessage.swift
//  Fondy
//
//  Chat data model and @Observable view-model for the Claude-style
//  chat module. Handles streaming text reveal and conversation state.
//

import SwiftUI

// MARK: - Chat Role

enum ChatRole {
    case user
    case assistant
}

// MARK: - Chat Message

struct ChatMessage: Identifiable {
    let id: UUID
    var role: ChatRole
    var content: String
    /// True while the assistant is still streaming characters into this message.
    var isStreaming: Bool

    init(id: UUID = UUID(), role: ChatRole, content: String, isStreaming: Bool = false) {
        self.id = id
        self.role = role
        self.content = content
        self.isStreaming = isStreaming
    }
}

// MARK: - Chat View Model

@Observable
final class ChatViewModel {

    // MARK: State

    var messages: [ChatMessage] = []
    var inputText: String = ""
    /// True while the assistant is composing a response (thinking dots shown).
    var isThinking: Bool = false

    // MARK: - Actions

    /// Sends the current inputText and streams a mock assistant response.
    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isThinking else { return }

        let userMessage = ChatMessage(role: .user, content: trimmed)
        messages.append(userMessage)
        inputText = ""

        Task { await generateResponse(to: trimmed) }
    }

    /// Sends a pre-set suggestion chip as a user message.
    func sendSuggestion(_ text: String) {
        guard !isThinking else { return }
        inputText = text
        send()
    }

    /// Clears the entire conversation.
    func clear() {
        messages.removeAll()
    }

    // MARK: - Private

    private func generateResponse(to question: String) async {
        isThinking = true

        // Show thinking state — simulates network / model latency
        try? await Task.sleep(for: .milliseconds(900))

        guard !Task.isCancelled else {
            isThinking = false
            return
        }

        // Fetch analysis from mock AI service (same service used by AIAnalysisSheet)
        let result = await AIAnalysisService.analyze(question: question) { _, _ in }

        let fullText = buildResponseText(from: result)

        isThinking = false

        // Stream character-by-character into a new assistant message
        var streamingMessage = ChatMessage(
            role: .assistant,
            content: "",
            isStreaming: true
        )
        messages.append(streamingMessage)
        let streamId = streamingMessage.id

        for character in fullText {
            try? await Task.sleep(for: .milliseconds(14))
            guard !Task.isCancelled else { break }
            guard let index = messages.firstIndex(where: { $0.id == streamId }) else { break }
            messages[index].content.append(character)
        }

        // Mark streaming complete
        if let index = messages.firstIndex(where: { $0.id == streamId }) {
            messages[index].isStreaming = false
        }
    }

    private func buildResponseText(from result: AIAnalysisResult) -> String {
        var parts: [String] = [result.headline + "\n"]
        for point in result.keyPoints {
            parts.append("• " + point)
        }
        if !result.suggestions.isEmpty {
            parts.append("\nYou might also explore:")
            for suggestion in result.suggestions {
                parts.append("→ " + suggestion)
            }
        }
        return parts.joined(separator: "\n")
    }
}

// MARK: - Suggestion Chips Data

extension ChatViewModel {
    static let suggestions: [(icon: String, text: String)] = [
        ("chart.bar.fill",       "How is my portfolio performing?"),
        ("shield.lefthalf.filled", "What's my biggest risk right now?"),
        ("arrow.left.arrow.right", "Should I rebalance?"),
        ("chart.pie.fill",       "Break down my asset allocation")
    ]
}

//
//  OpenAIManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/5/25.
//

import Foundation

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let max_completion_tokens: Int
}

struct ChatResponse: Codable {
    let choices: [ChatChoice]
}

struct ChatChoice: Codable {
    let message: ChatMessage
}

//class OpenAIService {

//    private let endpoint = "https://api.openai.com/v1/chat/completions"
//
//    func transformCSV(inputCSVPreview: String) async throws -> String {
//        let prompt = """
//        Convert this poker session CSV into this exact format with exactly 23 columns:
//
//        Date,Start Time,End Time,Location,Game,Stakes,Buy In,Cash Out,Profit,Table Expenses,High Hands,Tournament,Multi-Day,Days,Day Two Start,Day Two End,Rebuy Count,Size,Speed,Entrants,Finish,Tags,Notes
//
//        🔒 Rules:
//        - Output **exactly 23 comma-separated values per row** — no more, no less
//        - Only include the fields listed above — do not add anything extra like "USD", "Full-Ring", or "no"
//        - If a field is missing or unknown, leave it completely blank
//        - Tags and Notes must be plain text or empty — do not use square brackets, arrays, or symbols
//        - Game must be "NL Texas Hold Em" if it's a No Limit Texas Holdem game
//        - Tournament must be lowercase: "true" or "false"
//        - If Tournament is true:
//          - Size = MTT if missing
//          - Speed = Standard if missing
//        - Profit = Cash Out - Buy In
//
//        Return the output in **CSV format**, including the header line as the first row. Your response must only include the transformed CSV — no explanation.
//
//        CSV Preview:
//        \(inputCSVPreview)
//        """
//
//        let messages = [
//            ChatMessage(role: "system", content: "You are a CSV transformation assistant."),
//            ChatMessage(role: "user", content: prompt)
//        ]
//
//        let requestBody = ChatRequest(
//            model: "o3-mini-2025-01-31",
//            messages: messages,
//            max_completion_tokens: 6000
//        )
//
//        var request = URLRequest(url: URL(string: endpoint)!)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try JSONEncoder().encode(requestBody)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        let rawText = String(data: data, encoding: .utf8) ?? "n/a"
//        print("🧾 RAW GPT RESPONSE:\n\(rawText)")
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
//        }
//
//        guard (200..<300).contains(httpResponse.statusCode) else {
//            let raw = String(data: data, encoding: .utf8) ?? "unknown"
//            throw NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error \(httpResponse.statusCode): \(raw)"])
//        }
//
//        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
//        print("✅ Decoded Message: \(decoded.choices.first?.message.content ?? "empty")")
//        return decoded.choices.first?.message.content ?? ""
//        
//    }
//}

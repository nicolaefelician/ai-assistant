import Foundation

final class QwenApi: ApiModel, Hashable {
    var models: [String: String] = [
        "Qwen-VL Max": "qwen-vl-max",
        "Qwen-VL Plus": "qwen-vl-plus"
    ]
    
    var title: String = "Qwen"
    var description: String = "Alibaba's AI assistant, Qwen, utilizes large language models for enterprise and consumer applications."
    var image: String = "qwen"
    var modelType: ApiModelType = .qwen
    
    static var shared: QwenApi = QwenApi()
    
    static func == (lhs: QwenApi, rhs: QwenApi) -> Bool {
        return lhs.modelType == rhs.modelType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(modelType)
        hasher.combine(description)
    }
    
    private struct CompletionResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    private func cleanResponseText(_ text: String) -> String {
        var cleanedText = text
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "####\\s*", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "##\\s*", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "#\\s*", with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^-\\s", with: "• ", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
        
        return cleanedText
    }
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error> {
        let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/qwen/chat")!
        
        let headers = [
            "Content-Type": "application/json",
        ]
        
        var messages: [[String: Any]] = []
        
        history.forEach { chatHistory in
            messages.append([
                "role": "user",
                "content": [["type": "text", "text": chatHistory.sendText]]
            ])
            messages.append([
                "role": "assistant",
                "content": [["type": "text", "text": chatHistory.responseText ?? ""]]
            ])
        }
        
        var userMessageContent: [[String: Any]] = []
        
        images.forEach { image in
            userMessageContent.insert(["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]], at: 0)
        }
        
        userMessageContent.append(["type": "text", "text": message])
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": version,
            "messages": messages,
            "stream": true,
        ]
        
        var request = URLRequest(url: url)
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpMethod = "POST"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw ApiError.decodingFailded
        }
        request.httpBody = jsonData
        
        let (result, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw ApiError.invalidResponse
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8), let response = try? JSONDecoder().decode(CompletionResponse.self, from: data), let text = response.choices.first?.delta.content {
                            continuation.yield(cleanResponseText(text))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

import Foundation

final class ClaudeApi: ApiModel, Hashable {
    var models: [String: String] = [
        "Claude 3.7 Sonnet": "claude-3-7-sonnet-20250219",
        "Claude 3.5 Haiku": "claude-3-5-haiku-20241022",
        "Claude 3 Opus": "claude-3-opus-20240229",
        "Claude 3.5 Sonnet": "claude-3-5-sonnet-20240620",
        "Claude 3 Haiku": "claude-3-haiku-20240307"
    ]
    
    var modelType: ApiModelType = .claude
    var title: String = "Claude"
    var description: String = "Claude, created by Anthropic, is an AI assistant designed for safety, reliability, and helpful, insightful conversations."
    var image: String = "claude"
    
    static var shared: ClaudeApi = ClaudeApi()
    
    static func == (lhs: ClaudeApi, rhs: ClaudeApi) -> Bool {
        return lhs.modelType == rhs.modelType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(modelType)
        hasher.combine(description)
    }
    
    private struct ClaudeRequest: Codable {
        let model: String
        let max_tokens: Int
        let temperature: Double
        let system: String
        let messages: [Message]
    }
    
    private struct Message: Codable {
        let role: String
        let content: [Content]
    }
    
    private struct Content: Codable {
        let type: String
        let text: String
    }
    
    private struct ClaudeResponse: Codable {
        struct Response: Codable {
            let text: String
        }
        
        let delta: Response
    }
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error> {
        let apiURL = URL(string: "\(Consts.shared.apiBaseUrl)/api/claude/chat")!
        
        var contentList: [[String: Any]] = [["type": "text", "text": message]]
        
        for index in 0..<images.count {
            contentList.insert([
                "type": "text",
                "text": "Image: \(index + 1)"
            ], at: 0)
            contentList.insert([
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": images[index],
                ],
            ], at: 1)
        }
        
        var messagesList: [[String: Any]] = []
        
        history.forEach { ch in
            messagesList.append(["role": "user", "content": ch.sendText])
            messagesList.append(["role": "assistant", "content": ch.responseText == "" ? "No response was generated." : ch.responseText ?? "No response was generated." ])
        }
        
        messagesList.append(["role": "user", "content": contentList])
        
        let requestPayload: [String: Any] = [
            "model": version,
            "max_tokens": 2048,
            "stream": true,
            "messages": messagesList
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in data.lines {
                        if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8), let text = try? JSONDecoder().decode(ClaudeResponse.self, from: data).delta.text {
                            continuation.yield(text)
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

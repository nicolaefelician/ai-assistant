import Foundation

final class GrokApi: ApiModel, Hashable {
    var models: [String : String] = ["Grok 2": "grok-2-vision-1212"]
    
    var description: String = "Developed by xAI, Grok is an AI chatbot designed to provide real-time and insightful responses with a touch of humor."
    var image: String = "grok"
    var title: String = "Grok"
    var modelType: ApiModelType = .grok
    
    static var shared: GrokApi = GrokApi()
    
    static func == (lhs: GrokApi, rhs: GrokApi) -> Bool {
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
        
        cleanedText = cleanedText.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^-\\s", with: "• ", options: .regularExpression)
        
        return cleanedText
    }
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error> {
        let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/grok/chat")!
        
        let headers = [
            "Content-Type": "application/json",
        ]
        
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": "You are Grok, a chatbot inspired by the Hitchhikers Guide to the Galaxy."
            ]
        ]
        
        history.forEach { chatHistory in
            messages.append([
                "role": "user",
                "content": chatHistory.sendText
            ])
            messages.append([
                "role": "system",
                "content": chatHistory.responseText ?? ""
            ])
        }
        
        var userMessageContent: [[String: Any]] = []
        
        images.forEach { image in
            userMessageContent.append(
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)", "detail": "high"]]
            )
        }
        
        userMessageContent.append(["type": "text", "text": message])
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": version,
            "messages": messages,
            "stop": [
                "\n\n\n",
                "<|im_end|>"
            ],
            "stream": true,
        ]
        
        var request = URLRequest(url: url)
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpMethod = "POST"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw ApiError.encodingFailded
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

import Foundation

final class StoryTellingApi: ApiModel, Hashable {
    private struct ChatMessageApiResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    static func == (lhs: StoryTellingApi, rhs: StoryTellingApi) -> Bool {
        return lhs.modelType == rhs.modelType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(modelType)
        hasher.combine(description)
    }
    
    private func cleanResponse(_ response: String) -> String {
        var cleanedText = response
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^-\\s", with: "• ", options: .regularExpression)
        
        return cleanedText
    }
    
    var models: [String: String] = [:]
    
    var title: String = "Storytelling AI"
    var description: String = "Unleash your creativity with AI-powered storytelling. Generate unique plots, craft immersive narratives, and bring your ideas to life."
    var image: String = "storytelling_ai"
    var modelType: ApiModelType = .storyTelling
    
    static var shared: StoryTellingApi = StoryTellingApi()
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/chatgpt/chat") else { throw URLError(.badURL) }
        
        var messages: [[String: Any]] = [
            [
                "role": "storyteller",
                "content": "You are an AI storyteller, helping users craft compelling stories. You generate creative plots, develop engaging characters, and refine narratives in various genres. Whether it's fantasy, sci-fi, mystery, or romance, you assist in bringing ideas to life."
            ]
        ]
        
        history.forEach { chatHistory in
            messages.append([
                "role": "user",
                "content": chatHistory.sendText
            ])
            messages.append([
                "role": "developer",
                "content": chatHistory.responseText ?? ""
            ])
        }
        
        var userMessageContent: [[String: Any]] = [
            ["type": "text", "text": message],
        ]
        
        images.forEach { image in
            userMessageContent.append(
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]]
            )
        }
        
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
        
        if let data = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted) {
            print(String(data: data, encoding: .utf8) ?? "")
        }
        
        var request = URLRequest(url: url)
        
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
                        if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8), let response = try? JSONDecoder().decode(ChatMessageApiResponse.self, from: data), let text = response.choices.first?.delta.content {
                            continuation.yield(cleanResponse(text))
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

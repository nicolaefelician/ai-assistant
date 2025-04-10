import Foundation

final class ChatGptApi: ApiModel, Hashable {
    private struct ChatMessageApiResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    private struct MathApiResponse: Decodable {
        struct Message: Decodable {
            let content: String
        }
        
        struct Choice: Decodable {
            let message: Message
        }
        
        let choices: [Choice]
    }
    
    static func == (lhs: ChatGptApi, rhs: ChatGptApi) -> Bool {
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
    
    var models: [String: String] = [
        "GPT-4o Mini": "gpt-4o-mini",
        "Omni-3 Mini": "o3-mini",
        "Omni-1": "o1",
        "GPT-4o": "gpt-4o",
        "GPT-4 Turbo": "gpt-4-turbo",
    ]
    
    var title: String = "ChatGPT"
    var description: String = "Powered by OpenAI's GPT-4o model, ChatGPT is an advanced conversational AI designed for natural interactions."
    var image: String = "chatgpt"
    var modelType: ApiModelType = .chatGpt
    
    static var shared: ChatGptApi = ChatGptApi()
    
    func generateSpeach(_ prompt: String, voice: String) async throws -> String {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/chatgpt/generate-audio") else { throw URLError(.badURL) }
        
        let headers = [
            "Content-Type": "application/json",
        ]
        
        let body: [String: Any] = [
            "model": "tts-1",
            "input": prompt,
            "voice": voice,
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            throw NSError(domain: "Invalid JSON", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let tempFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent("speech.mp3")
        
        if FileManager.default.fileExists(atPath: tempFileUrl.path) {
            try FileManager.default.removeItem(at: tempFileUrl)
        }
        
        try data.write(to: tempFileUrl)
        
        return tempFileUrl.path
    }
    
    func solveMathProblem(image: String) async throws -> String {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/chatgpt/solve-math-problem") else { throw URLError(.badURL) }
        
        let messages: [[String: Any]] = [
            [
                "role": "developer",
                "content": "You are MathGPT, a brilliant and patient math expert. Your role is to help users solve math problems of any kind — from basic arithmetic to advanced calculus, linear algebra, and discrete mathematics. Always explain your reasoning clearly and provide step-by-step solutions when possible."
            ],
            [
                "role": "user",
                "content": [["type": "text", "text": "Solve this math problem from the image."], ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]]]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "stop": [
                "\n\n\n",
                "<|im_end|>"
            ],
        ]
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw ApiError.encodingFailded
        }
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("Error: HTTP status code \(httpResponse.statusCode)")
            throw ApiError.invalidResponse
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
        
        let decoded = try JSONDecoder().decode(MathApiResponse.self, from: data)
        
        return decoded.choices.first?.message.content ?? ""
    }
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: "\(Consts.shared.apiBaseUrl)/api/chatgpt/chat") else { throw URLError(.badURL) }
        
        var messages: [[String: Any]] = [
            [
                "role": "developer",
                "content": "You are Chat GPT, a helpful assistant. You can answer any questions that user has."
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
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw ApiError.encodingFailded
        }
        request.httpBody = jsonData
        
        let (result, response) = try await URLSession.shared.bytes(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code:", httpResponse.statusCode)
        } else {
            print("Invalid response")
        }
        
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

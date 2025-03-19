import Foundation
import SwiftUI

func getChatAssistant(_ type: ApiModelType) -> any ApiModel {
    switch type {
    case .chatGpt: return ChatGptApi.shared
    case .claude: return ClaudeApi.shared
    case .grok: return GrokApi.shared
    case .gemini: return GeminiApi.shared
    case .qwen: return QwenApi.shared
    case .recruiter: return RecruiterApi.shared
    case .invest: return InvestApi.shared
    case .storyTelling: return StoryTellingApi.shared
    case .coding: return AiCodingApi.shared
    }
}

enum NavigationDestination: Hashable {
    case settingsView
    case chatView(prompt: String? = nil, modelType: ApiModelType = .chatGpt, chatHistory: ChatHistoryItem? = nil)
    case summaryView(text: String, isLyrics: Bool = false)
    case imageDataView(image: UIImage)
    case audioDataView(audioPath: String)
}

enum ApiModelType: String, Codable {
    case chatGpt = "chatGpt"
    case grok = "grok"
    case qwen = "qwen"
    case claude = "claude"
    case gemini = "gemini"
    case recruiter = "recruiter"
    case invest = "invest"
    case storyTelling = "storyTelling"
    case coding = "coding"
}

enum ApiError: Error {
    case invalidResponse
    case decodingFailded
    case encodingFailded
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}

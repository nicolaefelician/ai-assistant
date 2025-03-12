import Foundation
import SwiftUI

final class StateProvider: ObservableObject {
    static let shared = StateProvider()
    
    private init() {
        self.haptics.prepare()
        loadChatHistory()
    }
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    @Published var path: [NavigationDestination] = []
    
    @Published var chatHistory: [ChatHistoryItem] = []
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isBlurred = false
    
    @Published var stringToShare: String = ""
    @Published var imageToShare: UIImage? = nil
    @Published var isSharing: Bool = false
    
    @Published var showOnboarding = false
    
    @Published var showYoutubeSummary: Bool = false
    @Published var showImageGeneration: Bool = false
    @Published var showLyricsGeneration: Bool = false
    @Published var showPdfSummary: Bool = false
    @Published var showTextToSpeach: Bool = false
    
    @Published var showPhotoCamera: Bool = false
    
    func saveChatHistory() {
        do {
            let data = try JSONEncoder().encode(chatHistory)
            let fileURL = getChatHistoryFileURL()
            
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("❌ Error saving chat history: \(error.localizedDescription)")
        }
    }
    
    private func loadChatHistory() {
        let fileURL = getChatHistoryFileURL()
        do {
            let data = try Data(contentsOf: fileURL)
            chatHistory = try JSONDecoder().decode([ChatHistoryItem].self, from: data)
        } catch {
            print("⚠️ Error loading chat history: \(error.localizedDescription)")
        }
    }
    
    private func getChatHistoryFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("chatHistory.json")
    }
}

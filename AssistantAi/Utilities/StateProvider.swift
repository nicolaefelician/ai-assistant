import Foundation
import SwiftUI
import RevenueCat
import SuperwallKit

final class StateProvider: ObservableObject {
    static let shared = StateProvider()
    
    private init() {
        self.haptics.prepare()
    }
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    @Published var isSubscribed: Bool = false
    
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
    
    @Published var isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    @Published var showYoutubeSummary: Bool = false
    @Published var showImageGeneration: Bool = false
    @Published var showLyricsGeneration: Bool = false
    @Published var showPdfSummary: Bool = false
    @Published var showTextToSpeach: Bool = false
    
    @Published var showPhotoCamera: Bool = false
    
    @Published var messagesCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let messageCountKey = "dailyMessageCount"
    private let lastResetKey = "lastResetDate"
    private let taskKey = "CompletedTasks"
    
    private func loadMessagesCount() {
        let lastResetDate = userDefaults.object(forKey: lastResetKey) as? Date ?? Date.distantPast
        
        if !Calendar.current.isDateInToday(lastResetDate) {
            resetDailyMessages()
        } else {
            messagesCount = userDefaults.integer(forKey: messageCountKey)
        }
    }
    
    func sendMessage() {
        guard messagesCount > 0 else { return }
        
        messagesCount -= 1
        userDefaults.set(messagesCount, forKey: messageCountKey)
    }
    
    func isTaskCompleted(_ task: AiTask) -> Bool {
        let completedTasks = UserDefaults.standard.array(forKey: taskKey) as? [String] ?? []
        return completedTasks.contains(task.title)
    }
    
    func completeTask(_ taskTitle: String) {
        var completedTasks = UserDefaults.standard.array(forKey: taskKey) as? [String] ?? []
        if !completedTasks.contains(taskTitle) {
            completedTasks.append(taskTitle)
            UserDefaults.standard.set(completedTasks, forKey: taskKey)
        }
    }
    
    private func resetDailyMessages() {
        messagesCount = 3
        userDefaults.set(messagesCount, forKey: messageCountKey)
        userDefaults.set(Date(), forKey: lastResetKey)
    }
    
    func saveChatHistory() {
        do {
            let data = try JSONEncoder().encode(chatHistory)
            let fileURL = getChatHistoryFileURL()
            
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("❌ Error saving chat history: \(error.localizedDescription)")
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        showOnboarding = false
    }
    
    func loadContent() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isSubscribed = customerInfo?.entitlements.all["Pro"]?.isActive == true
        }
        
        if !UserDefaults.standard.bool(forKey: "onboardingCompleted") {
            Superwall.shared.register(placement: "onboarding_paywall")
            completeOnboarding()
        }
        
        loadMessagesCount()
        
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

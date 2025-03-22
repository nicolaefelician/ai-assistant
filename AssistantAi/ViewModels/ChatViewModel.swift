import Foundation
import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    
    @Published var uploadedImages: [UIImage] = []
    @Published var selectedImage: UIImage?
    @Published var showPhotoCameraPicker = false
    @Published var showImageLibraryPicker = false
    @Published var showImages: Bool = false
    @Published var fullScreenImage: UIImage?
    @Published var showFullScreenImage: Bool = false
    
    @Published var showActionSheet: Bool = false
    @Published var showModelPicker = false
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @Published var isWriting: Bool = false
    
    @Published var pickedModel: [String:String?] = ["key": nil, "value": nil]
    
    private var cancellables = Set<AnyCancellable>()
    private var responseTask: Task<Void, Never>?
    
    let apiModel: any ApiModel
    @Published var messages: [ChatMessage]
    var chatHistory: ChatHistoryItem?
    
    @MainActor
    func cancelResponse() {
        responseTask?.cancel()
        isWriting = false
        responseTask = nil
    }
    
    func getShareString() -> String {
        var stringToShare = ""
        
        messages.forEach { message in
            stringToShare += "User: \(message.sendText)\n"
            stringToShare += "AI: \(message.responseText ?? "No response")\n"
            stringToShare += "\n"
        }
        
        return stringToShare
    }
    
    @MainActor
    func sendMessage() async {
        let temp = self.inputText
        self.inputText = ""
        
        var streamText = ""
        
        let images = self.uploadedImages.map { return $0.toBase64() ?? "" }
        
        let chatMessage = ChatMessage(id: UUID(), sendText: temp, responseIcon: apiModel.image, images: images)
        messages.append(chatMessage)
        self.showImages = false
        self.isWriting = true
        
        responseTask = Task {
            do {
                let stream = try await apiModel.getChatResponse(message: temp, history: messages.dropLast(), images: images, version: (pickedModel["value"] ?? "gpt-4o-mini") ?? "gpt-4o-mini")
                
                for try await line in stream {
                    if Task.isCancelled { break }
                    streamText += line
                    chatMessage.responseText = streamText
                    self.messages[self.messages.count - 1] = chatMessage
                }
                self.uploadedImages.removeAll()
                stateProvider.sendMessage()
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    print("User cancelled the task.")
                } else {
                    chatMessage.responseError = "Unexpected issue occurred while processing your request. Please try again later."
                }
            }
            
            self.messages[self.messages.count - 1] = chatMessage
            self.isWriting = false
            
            if let history = self.chatHistory {
                let index = stateProvider.chatHistory.firstIndex(of: history)!
                history.messages = messages
                self.chatHistory = history
                stateProvider.chatHistory[index] = history
            } else {
                stateProvider.chatHistory.append(ChatHistoryItem(id: UUID(), messages: messages, apiModelType: apiModel.modelType))
                self.chatHistory = stateProvider.chatHistory.last
            }
            stateProvider.saveChatHistory()
        }
    }
    
    init(apiModel: any ApiModel, chatHistory: ChatHistoryItem?) {
        self.apiModel = apiModel
        self.chatHistory = chatHistory
        self.messages = chatHistory?.messages ?? []
        
        $selectedImage.sink { newImage in
            guard let image = newImage else { return }
            
            self.uploadedImages.append(image)
            self.showImages = true
        }
        .store(in: &cancellables)
        
        $fullScreenImage.sink { newImage in
            if newImage == nil { return }
            
            self.showFullScreenImage = true
        }
        .store(in: &cancellables)
    }
}

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
    
    @Published var showActionSheet: Bool = false
    @Published var showModelPicker = false
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @Published var pickedModel: [String:String?] = ["key": nil, "value": nil]
    
    private var cancellables = Set<AnyCancellable>()
    
    let apiModel: any ApiModel
    @Published var messages: [ChatMessage]
    var chatHistory: ChatHistoryItem?
    
    func getShareString() -> String {
        var stringToShare = ""
        
        messages.forEach { message in
            stringToShare += "User: \(message.sendText)\n"
            stringToShare += "AI: \(message.responseText ?? "No response")\n"
            stringToShare += "\n"
        }
        
        return stringToShare
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = self.messages.last?.id else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
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
        
        do {
            let stream = try await apiModel.getChatResponse(message: temp, history: messages.dropLast(), images: images, version: (pickedModel["value"] ?? "gpt-4o-mini") ?? "gpt-4o-mini")
            
            for try await line in stream {
                if Task.isCancelled { break }
                streamText += line
                chatMessage.responseText = streamText
                self.messages[self.messages.count - 1] = chatMessage
            }
            self.uploadedImages.removeAll()
        } catch {
            print("Caught an error: \(error)")
        }
        
        self.messages[self.messages.count - 1] = chatMessage
        
        if var history = self.chatHistory {
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
    }
}

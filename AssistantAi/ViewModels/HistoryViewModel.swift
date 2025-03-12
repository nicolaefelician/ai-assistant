import Foundation
import Combine
import SwiftUI

final class HistoryViewModel: ObservableObject {
    @Published var showActionSheet = false
    @Published var selectedHistoryId: UUID? = nil
    @Published var newTitle: String = ""
    @Published var showTitleInputSheet = false
    @Published var inputText: String = ""
    @Published var filteredChatHistories: [ChatHistoryItem] = []
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $inputText.sink { newText in
            if newText.isEmpty {
                self.filteredChatHistories = self.stateProvider.chatHistory
                return
            }
            
            self.filteredChatHistories = self.stateProvider.chatHistory.filter { history in
                if let title = history.title, title.lowercased().contains(newText.lowercased()) {
                    return true
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMMM yyyy"
                let dateString = dateFormatter.string(from: history.date)
                
                return dateString.lowercased().contains(newText.lowercased())
            }
        }
        .store(in: &cancellables)
    }
}

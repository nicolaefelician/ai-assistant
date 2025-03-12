import Foundation

final class ChatHistoryItem: Codable, Identifiable, Hashable, Equatable {
    let id: UUID
    var messages: [ChatMessage]
    let apiModelType: ApiModelType
    var title: String?
    var date: Date
    
    static func == (lhs: ChatHistoryItem, rhs: ChatHistoryItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: UUID, messages: [ChatMessage], apiModelType: ApiModelType, title: String? = nil, date: Date = Date.now) {
        self.id = id
        self.messages = messages
        self.apiModelType = apiModelType
        self.title = title
        self.date = date
    }
}

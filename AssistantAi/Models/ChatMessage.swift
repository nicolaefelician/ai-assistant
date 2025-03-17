import Foundation

final class ChatMessage: Identifiable, Codable, Equatable, Hashable, ObservableObject {
    let id: UUID
    let sendText: String
    @Published var responseText: String?
    @Published var responseError: String?
    let responseIcon: String
    let images: [String]
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: UUID, sendText: String, responseText: String? = nil, responseIcon: String, images: [String], responseError: String? = nil) {
        self.id = id
        self.sendText = sendText
        self.responseText = responseText
        self.responseIcon = responseIcon
        self.images = images
        self.responseError = responseError
    }
    
    enum CodingKeys: String, CodingKey {
        case id, sendText, responseText, responseIcon, images, responseError
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sendText, forKey: .sendText)
        try container.encode(responseText, forKey: .responseText)
        try container.encode(responseIcon, forKey: .responseIcon)
        try container.encode(images, forKey: .images)
        try container.encode(responseError, forKey: .responseError)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.sendText = try container.decode(String.self, forKey: .sendText)
        self.responseText = try container.decodeIfPresent(String.self, forKey: .responseText)
        self.responseIcon = try container.decode(String.self, forKey: .responseIcon)
        self.images = try container.decode([String].self, forKey: .images)
        self.responseError = try container.decodeIfPresent(String.self, forKey: .responseError)
    }
}

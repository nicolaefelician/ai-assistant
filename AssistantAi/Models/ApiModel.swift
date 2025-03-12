import Foundation

protocol ApiModel: Equatable {
    var models: [String: String] { get }
    var modelType: ApiModelType { get }
    var title: String { get }
    var description: String { get }
    var image: String { get }
    
    static var shared: Self { get }
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error>
}

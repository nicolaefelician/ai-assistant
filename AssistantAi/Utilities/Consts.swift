import Foundation

final class Consts {
    static let shared = Consts()
    
    private struct ApiResponse: Decodable {
        let apiKey: String
    }
    
    private init() {}
    
    let apiBaseUrl = "https://ai-assistant-backend-164860087792.us-central1.run.app"
}

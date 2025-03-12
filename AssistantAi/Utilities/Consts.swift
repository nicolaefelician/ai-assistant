import Foundation

final class Consts {
    static let shared = Consts()
    
    private struct ApiResponse: Decodable {
        let apiKey: String
    }
    
    private init() {
        Task { @MainActor in
            guard let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/social-media-finder-4869f.appspot.com/o/key.json?alt=media&token=a761d673-b018-4d12-bd14-ee1a79406b7c") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                let decoded = try JSONDecoder().decode(ApiResponse.self, from: data)
                
                apiKey = decoded.apiKey
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    let apiBaseUrl = "https://ai-assistant-backend-164860087792.us-central1.run.app"
    var apiKey = ""
}

import Foundation
import SwiftUI
import Combine

final class PromptsViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var selectedImage: UIImage?
    @ObservedObject private var stateProvider = StateProvider.shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $selectedImage.sink { newImage in
            guard let image = newImage else { return }
            
            Task { @MainActor in
                self.stateProvider.isBlurred = true
                self.stateProvider.isLoading = true
                
                do {
                    let solved = try await GeminiApi.shared.solveMathProblem(image)
                    
                    self.stateProvider.path.append(.summaryView(text: solved))
                } catch {
                    self.stateProvider.errorMessage = error.localizedDescription
                    self.stateProvider.showError = true
                }
                
                self.stateProvider.isBlurred = false
                self.stateProvider.isLoading = false
            }
        }
        .store(in: &cancellables)
    }
}

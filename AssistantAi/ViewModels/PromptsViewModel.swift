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
                    guard let image = image.toBase64() else { return }
                    
                    let solved = try await ChatGptApi.shared.solveMathProblem(image: image)
                    
                    self.stateProvider.path.append(.summaryView(text: solved))
                    self.stateProvider.completeTask("Math")
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

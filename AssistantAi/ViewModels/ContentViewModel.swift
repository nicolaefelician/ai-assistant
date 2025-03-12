import SwiftUI
import Combine

final class ContentViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    init() {
        $selectedTab
            .sink { _ in
                self.stateProvider.haptics.impactOccurred()
            }
            .store(in: &cancellables)
    }
}

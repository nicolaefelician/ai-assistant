import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject {
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Colors.shared.backgroundColor)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(.white)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(.white)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        let navigationBarStyle = UINavigationBarAppearance()
        
        navigationBarStyle.backgroundColor = UIColor(Colors.shared.backgroundColor)
        navigationBarStyle.shadowColor = nil
        
        UINavigationBar.appearance().standardAppearance = navigationBarStyle
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarStyle
        UINavigationBar.appearance().compactAppearance = navigationBarStyle
    }
}

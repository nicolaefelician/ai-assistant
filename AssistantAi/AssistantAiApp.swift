import SwiftUI
import Firebase
import SuperwallKit
import RevenueCat

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Consts.shared.revenueCatApiKey)
        
        Superwall.configure(apiKey: "pk_b38105b2e3e504e9d8b49ce83261b13f3c1cc7ed18bc2367", purchaseController: purchaseController)
        
        purchaseController.syncSubscriptionStatus()
        
        StateProvider.shared.loadContent()
        
        configureAppearance()
        
        return true
    }
    
    private func configureAppearance() {
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

@main
struct AssistantAiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    var body: some Scene {
        WindowGroup {
            if stateProvider.showOnboarding {
                OnboardingView()
                    .preferredColorScheme(.dark)
            } else {
                ContentView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

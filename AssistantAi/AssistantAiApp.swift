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
        
        return true
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

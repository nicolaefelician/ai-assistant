import SwiftUI
import Firebase

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct AssistantAiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    var body: some Scene {
        WindowGroup {
//            if stateProvider.showOnboarding {
//                OnboardingView()
//                    .preferredColorScheme(.dark)
//            } else {
//                ContentView()
//                    .preferredColorScheme(.dark)
//            }
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

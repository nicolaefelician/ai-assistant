import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    @Environment(\.presentationMode) var presentationMode

    @Environment(\.requestReview) var requestReview
    
    let termsOfUseUrl = "https://docs.google.com/document/d/16LVTshrqpm3vU36OLkzfWrQ3fmqmOBOMOFSt-0opqUA/edit?tab=t.0#heading=h.kprqut1atkhz"
    let privacyPolicyUrl = "https://docs.google.com/document/d/163C1w_touZa_0rsHh-J_MeS9xYKn4gDlmeKD0YB2ujk/edit?tab=t.0#heading=h.cc7frtdbkidv"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button(action: { openUrl(privacyPolicyUrl) }) {
                    SettingsButtonView(title: "Privacy Policy", icon: "lock.shield")
                }

                Button(action: { openUrl(termsOfUseUrl) }) {
                    SettingsButtonView(title: "Terms of Use", icon: "doc.text")
                }

                Button(action: { rateApp() }) {
                    SettingsButtonView(title: "Rate App", icon: "star.fill")
                }

//                Button(action: { shareApp() }) {
//                    SettingsButtonView(title: "Share App", icon: "square.and.arrow.up")
//                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    stateProvider.haptics.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
        }
        .background(Colors.shared.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        requestReview()
    }

//    private func shareApp() {
//        guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") else { return }
//        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true)
//        }
//    }
}

struct SettingsButtonView: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)

            Text(title)
                .foregroundColor(.white)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

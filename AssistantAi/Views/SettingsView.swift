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
                Button(action: { rateApp() }) {
                    SettingsButtonView(title: "Rate App", icon: "star.fill")
                }

                Button(action: { shareApp() }) {
                    SettingsButtonView(title: "Share App", icon: "square.and.arrow.up")
                }
                
                Button(action: { contactUs() }) {
                    SettingsButtonView(title: "Contact us", icon: "ellipsis.message.fill")
                }
                
                Button(action: { openUrl(privacyPolicyUrl) }) {
                    SettingsButtonView(title: "Privacy Policy", icon: "lock.shield")
                }

                Button(action: { openUrl(termsOfUseUrl) }) {
                    SettingsButtonView(title: "Terms of Use", icon: "doc.text")
                }
            }
            .padding()
            .padding(.top, 15)
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
    
    private func contactUs() {
        let email = "feliciannicolae433@gmail.com"
        let subject = "Support Request"
        let body = "Hi, I need help with... (AI Assistant 1.0.6)"
        let mailtoURL = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: mailtoURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Mail app is not available")
            }
        }
    }
    
    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        requestReview()
    }

    private func shareApp() {
        let url = "https://apps.apple.com/us/app/ai-assistant-ask-chat-bot-now/id6743180672"
        stateProvider.stringToShare = url
        stateProvider.isSharing = true
    }
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
                .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 17))

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

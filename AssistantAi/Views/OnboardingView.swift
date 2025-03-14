import SwiftUI

struct OnboardingView: View {
    let backgroundColor: Color = Color(hex: "#16181b")
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @State private var currentPage: Int = 0
    
    private final class OnboardingInfo {
        let title: String
        let subtitle: String
        let image: String
        let buttonText: String
        
        init(title: String, subtitle: String, image: String, buttonText: String) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.buttonText = buttonText
        }
    }
    
    private let onboardingInfos: [OnboardingInfo] = [
        OnboardingInfo(title: "Dive In and Discover", subtitle: "Explore the many ways your AI can make your life easier. Try a few commands and see what's possible.", image: "o1", buttonText: "Continue")
    ]
    
    private func onboardingPage(_ info: OnboardingInfo) -> some View {
        VStack {
            ZStack {
                Image(info.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 435)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(height: 435)
                    .frame(maxWidth: .infinity)
                    .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 10)
            }
            
            Text(info.title)
                .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 35))
                .foregroundStyle(Colors.shared.lightGreen)
                .padding(.top)
                .padding(.bottom, 11)
            
            Text(info.subtitle)
                .font(.custom(Fonts.shared.interRegular, size: 18))
                .foregroundStyle(.white.opacity(0.56))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                stateProvider.haptics.impactOccurred()
                if currentPage == onboardingInfos.count - 1 {
//                    stateProvider.showOnboarding = false
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }) {
                Text(info.buttonText)
                    .font(.custom(Fonts.shared.interMedium, size: 21))
                    .foregroundStyle(.white)
                    .padding(.vertical, 19)
                    .padding(.horizontal, 120)
                    .background(Color(hex: "#25272a"))
                    .cornerRadius(13)
            }
            .padding(.bottom, 25)
        }
        .background(backgroundColor)
    }
    
    var body: some View {
        if currentPage == 0 {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                VStack {
                    Image("oicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 145)
                        .padding(.bottom, 30)
                        .padding(.top, 115)
                        .padding(.trailing, 45)
                    
                    Text("Welcome to")
                        .font(.custom(Fonts.shared.interRegular, size: 31))
                        .foregroundColor(Color.white.opacity(0.61))
                    
                    Text("AI Assistant")
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 45))
                        .foregroundStyle(Colors.shared.lightGreen)
                        .padding(.bottom, 20)
                    
                    Text("Streamline your day with personalized AI support. Get tasks done faster and access information instantly.")
                        .font(.custom(Fonts.shared.interRegular, size: 18))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        stateProvider.haptics.impactOccurred()
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Continue")
                            .font(.custom(Fonts.shared.interMedium, size: 21))
                            .foregroundStyle(.white)
                            .padding(.vertical, 19)
                            .padding(.horizontal, 120)
                            .background(Color(hex: "#25272a"))
                            .cornerRadius(13)
                    }
                }
                .padding(.vertical, 70)
            }
        } else {
            TabView(selection: $currentPage) {
                ForEach(onboardingInfos, id: \.title) { info in
                    onboardingPage(info)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .background(backgroundColor)
        }
    }
}

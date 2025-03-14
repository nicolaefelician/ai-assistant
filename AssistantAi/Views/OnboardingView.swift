import SwiftUI
import SuperwallKit

struct OnboardingView: View {
    let backgroundColor: Color = Colors.shared.backgroundColor
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @State private var currentPage: Int = 0
    @State private var showFirstPage: Bool = true
    @State private var showLastPage: Bool = false
    
    @Environment(\.requestReview) var requestReview
    
    private final class OnboardingInfo {
        let title: String
        let subtitle: String
        let image: String
        let buttonText: String
        let topPadding: CGFloat
        let imageHeight: CGFloat
        let horizontalPadding: CGFloat
        let shadowPadding: CGFloat
        
        init(title: String, subtitle: String, image: String, buttonText: String, topPadding: CGFloat, imageHeight: CGFloat, horizontalPadding: CGFloat, shadowPadding: CGFloat) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.buttonText = buttonText
            self.topPadding = topPadding
            self.imageHeight = imageHeight
            self.horizontalPadding = horizontalPadding
            self.shadowPadding = shadowPadding
        }
    }
    
    private let onboardingInfos: [OnboardingInfo] = [
        OnboardingInfo(title: "Dive In and Discover", subtitle: "Explore the many ways your AI can make your life easier. Try a few commands and see what's possible.", image: "o1", buttonText: "Continue", topPadding: 35, imageHeight: 435, horizontalPadding: 0, shadowPadding: 110),
        OnboardingInfo(title: "Your Tasks - Simplified", subtitle: "Let our AI handle the details, so you can focus on what matters most.", image: "o2", buttonText: "Continue", topPadding: 35, imageHeight: 435, horizontalPadding: 0, shadowPadding: 110),
        OnboardingInfo(title: "Unlimited AI Assistance", subtitle: "Discover endless services from image generation to math solving.", image: "o3", buttonText: "Continue", topPadding: 0, imageHeight: 535, horizontalPadding: 25, shadowPadding: 190),
    ]
    
    private func onboardingPage(_ info: OnboardingInfo) -> some View {
        VStack {
            ZStack {
                Image(info.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: info.imageHeight)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 25)
                    .padding(.top, -15)
                    .padding(.horizontal)
                
                LinearGradient(
                    gradient: Gradient(colors: info.image == "o3" ? [
                        backgroundColor,
                        backgroundColor,
                        backgroundColor,
                        backgroundColor.opacity(0.8),
                        backgroundColor.opacity(0.6),
                        backgroundColor.opacity(0.4),
                        backgroundColor.opacity(0.2),
                        Color.clear,
                    ] : [
                        backgroundColor,
                        backgroundColor.opacity(0.9),
                        backgroundColor.opacity(0.6),
                        backgroundColor.opacity(0.4),
                        backgroundColor.opacity(0.2),
                        Color.clear,
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .offset(y: info.shadowPadding)
            }
            
            Text(info.title)
                .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 33))
                .foregroundStyle(Colors.shared.lightGreen)
                .padding(.top, info.topPadding == 0 ? 0 : 30)
                .padding(.bottom, 5)
            
            Text(info.subtitle)
                .font(.custom(Fonts.shared.interRegular, size: 16))
                .foregroundStyle(.white.opacity(0.56))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                stateProvider.haptics.impactOccurred()
                if currentPage == onboardingInfos.count - 1 {
                    showLastPage = true
                } else {
                    currentPage += 1
                }
            }) {
                Text(info.buttonText)
                    .font(.custom(Fonts.shared.interMedium, size: 21))
                    .foregroundStyle(.white)
                    .padding(.vertical, 19)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#25272a"))
                    .cornerRadius(13)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 20)
        }
        .ignoresSafeArea(edges: .top)
        .padding(.top, info.topPadding)
        .background(backgroundColor)
    }
    
    var body: some View {
        if showFirstPage {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                Color.black.opacity(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                        .padding(.bottom, 15)
                        .padding(.top, 160)
                    
                    Text("Welcome to")
                        .font(.custom(Fonts.shared.interRegular, size: 31))
                        .foregroundColor(Color.white.opacity(0.61))
                    
                    Text("AI Assistant")
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 45))
                        .foregroundStyle(Colors.shared.lightGreen)
                        .padding(.bottom, 20)
                    
                    Text("Streamline your day with personalized AI support. Get tasks done faster and access information instantly.")
                        .font(.custom(Fonts.shared.interRegular, size: 16))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 35)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        stateProvider.haptics.impactOccurred()
                        showFirstPage = false
                    }) {
                        Text("Continue")
                            .font(.custom(Fonts.shared.interMedium, size: 21))
                            .foregroundStyle(.black)
                            .padding(.vertical, 19)
                            .frame(maxWidth: .infinity)
                            .background(Colors.shared.lightGreen)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.vertical, 25)
            }
        } else if showLastPage {
            VStack {
                ZStack {
                    Image("o4")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 435)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            backgroundColor,
                            Color.clear
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .offset(y: 110)
                }
                
                Image("reviews")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 180)
                
                Spacer()
                
                Button(action: {
                    stateProvider.haptics.impactOccurred()
                    stateProvider.completeOnboarding()
                    Superwall.shared.register(placement: "campaign_trigger")
                    requestReview()
                }) {
                    Text("Get Started")
                        .font(.custom(Fonts.shared.interMedium, size: 21))
                        .foregroundStyle(.white)
                        .padding(.vertical, 19)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#25272a"))
                        .cornerRadius(13)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 15)
            .background(backgroundColor)
        } else {
            TabView(selection: $currentPage) {
                onboardingPage(onboardingInfos[currentPage])
            }
            .ignoresSafeArea(edges: .top)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(backgroundColor)
        }
    }
}

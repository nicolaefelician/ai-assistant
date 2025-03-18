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
        let shadowPadding: CGFloat
        
        init(title: String, subtitle: String, image: String, buttonText: String, topPadding: CGFloat, imageHeight: CGFloat, shadowPadding: CGFloat) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.buttonText = buttonText
            self.topPadding = topPadding
            self.imageHeight = imageHeight
            self.shadowPadding = shadowPadding
        }
    }
    
    private final class ReviewInfo {
        let title: String
        let stars: Int
        let text: String
        
        init(title: String, stars: Int, text: String) {
            self.title = title
            self.stars = stars
            self.text = text
        }
    }
    
    private let reviewInfos: [ReviewInfo] = [
        ReviewInfo(title: "Worth Every Penny", stars: 4, text: "Overall, a solid product with excellent features. A few minor tweaks would make it perfect! It works as expected and is very reliable. A little expensive, but definitely worth it!"),
        ReviewInfo(title: "Exceptional Quality", stars: 5, text: "The product exceeded my expectations in every way. The build quality is fantastic, and the performance is top-notch. Highly recommended!"),
        ReviewInfo(title: "Game-Changer", stars: 5, text: "This has completely transformed my workflow. It’s easy to use, highly efficient, and delivers results beyond what I imagined."),
        ReviewInfo(title: "Almost Perfect", stars: 4, text: "I love using this! Just a small issue with [specific feature], but everything else is flawless. The concept is great, and it works well most of the time."),
        ReviewInfo(title: "Superb Performance", stars: 5, text: "I’ve tried many alternatives, but this one stands out! Fast, smooth, and incredibly user-friendly. It’s an absolute must-have."),
        ReviewInfo(title: "Very Useful", stars: 4, text: "A great app with many useful features. I wish there were a bit more customization, but otherwise, it's fantastic."),
        ReviewInfo(title: "Highly Recommend", stars: 5, text: "An amazing experience! The interface is intuitive, and the results are outstanding. Well worth the investment."),
        ReviewInfo(title: "Reliable and Efficient", stars: 4, text: "A great balance between functionality and ease of use. Works flawlessly most of the time. Just needs a tiny bit of polish!")
    ]
    
    private let iOSOnboardingInfos: [OnboardingInfo] = [
        OnboardingInfo(title: "Dive In and Discover", subtitle: "Explore the many ways your AI can make your life easier. Try a few commands and see what's possible.", image: "o1", buttonText: "Continue", topPadding: 1, imageHeight: 450, shadowPadding: 110),
        OnboardingInfo(title: "Your Tasks - Simplified", subtitle: "Let our AI handle the details effortlessly, allowing you to stay focused on what matters most and achieve your goals with ease.", image: "o2", buttonText: "Continue", topPadding: 7, imageHeight: 450, shadowPadding: 125),
        OnboardingInfo(title: "Unlimited AI Assistance", subtitle: "Discover endless services from image generation to math solving.", image: "o3", buttonText: "Continue", topPadding: -40, imageHeight: 600, shadowPadding: 220),
    ]
    
    private let iPadOnboardingInfos: [OnboardingInfo] = [
        OnboardingInfo(title: "Dive In and Discover", subtitle: "Explore the many ways your AI can make your life easier. Try a few commands and see what's possible.", image: "o1", buttonText: "Continue", topPadding: 30, imageHeight: 675, shadowPadding: 250),
        OnboardingInfo(title: "Your Tasks - Simplified", subtitle: "Let our AI handle the details, so you can focus on what matters most.", image: "o2", buttonText: "Continue", topPadding: 30, imageHeight: 675, shadowPadding: 250),
        OnboardingInfo(title: "Unlimited AI Assistance", subtitle: "Discover endless services from image generation to math solving.", image: "o3", buttonText: "Continue", topPadding: -30, imageHeight: 800, shadowPadding: 300),
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
                    .padding(.top, info.topPadding)
                
                LinearGradient(
                    gradient: Gradient(colors: info.image == "o3" ? [
                        backgroundColor,
                        backgroundColor,
                        backgroundColor,
                        backgroundColor,
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
                .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 50 : 33))
                .foregroundStyle(Colors.shared.lightGreen)
                .padding(.bottom, 5)
                .padding(.top, info.topPadding / 2)
            
            Text(info.subtitle)
                .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 22 : 16))
                .foregroundStyle(.white.opacity(0.56))
                .multilineTextAlignment(.center)
                .padding(.horizontal, stateProvider.isIpad ? 90 : 35)
            
            Spacer()
            
            Button(action: {
                stateProvider.haptics.impactOccurred()
                withAnimation {
                    if currentPage == iOSOnboardingInfos.count - 1 {
                        showLastPage = true
                    } else {
                        currentPage += 1
                    }
                }
            }) {
                Text(info.buttonText)
                    .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 24 : 21))
                    .foregroundStyle(.white)
                    .padding(.vertical, stateProvider.isIpad ? 24 : 17)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#25272a"))
                    .cornerRadius(13)
                    .padding(.horizontal, stateProvider.isIpad ? 90 : 40)
            }
            .padding(.bottom, stateProvider.isIpad ? 40 : 20)
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
                        .frame(width: stateProvider.isIpad ? 180 : 120, height: stateProvider.isIpad ? 180 : 120)
                        .cornerRadius(20)
                        .padding(.bottom, 15)
                        .padding(.top, stateProvider.isIpad ? 230 :  160)
                    
                    Text("Welcome to")
                        .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 32 : 28))
                        .foregroundColor(Color.white.opacity(0.61))
                    
                    Text("AI Assistant")
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 60 : 45))
                        .foregroundStyle(Colors.shared.lightGreen)
                        .padding(.bottom, 20)
                    
                    Text("Streamline your day with personalized AI support. Get tasks done faster and access information instantly.")
                        .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 24 : 18))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, stateProvider.isIpad ? 100 : 35)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        stateProvider.haptics.impactOccurred()
                        withAnimation {
                            showFirstPage = false
                        }
                    }) {
                        Text("Continue")
                            .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 24 : 21))
                            .foregroundStyle(.black)
                            .padding(.vertical, stateProvider.isIpad ? 24 : 17)
                            .frame(maxWidth: .infinity)
                            .background(Colors.shared.lightGreen)
                            .cornerRadius(20)
                            .padding(.horizontal, stateProvider.isIpad ? 100 : 40)
                    }
                }
                .padding(.vertical, stateProvider.isIpad ? 300 : 30)
            }
        } else if showLastPage {
            VStack(spacing: 0) {
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            ForEach(reviewInfos, id: \.title) { review in
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top, spacing: 6) {
                                        Text(review.title)
                                            .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 20))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        ForEach(0..<review.stars, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                                .foregroundStyle(.yellow)
                                        }
                                        
                                        if review.stars != 5 {
                                            Image(systemName: "star")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                                .foregroundStyle(.yellow.opacity(0.4))
                                        }
                                    }
                                    
                                    Text(review.text)
                                        .font(.custom(Fonts.shared.interRegular, size: 14))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(18)
                                .background(Color(hex: "#025F33"))
                                .cornerRadius(14)
                            }
                        }
                        .padding(.top, stateProvider.isIpad ? 15 : 0)
                        .padding(.bottom, 90)
                    }
                    .frame(height: stateProvider.isIpad ? 650 : 435)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, stateProvider.isIpad ? 60 : 24)
                    
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
                    .offset(y: stateProvider.isIpad ? 225 : 120)
                    .allowsHitTesting(false)
                }
                
                Text("Loved by millions")
                    .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 50 : 33))
                    .foregroundStyle(Colors.shared.lightGreen)
                    .padding(.top, 15)
                
                Image("reviews")
                    .resizable()
                    .scaledToFit()
                    .frame(height: stateProvider.isIpad ? 280 : 170)
                    .padding(.top, stateProvider.isIpad ? -45 : -20)
                
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
                        .padding(.vertical, stateProvider.isIpad ? 24 : 17)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#25272a"))
                        .cornerRadius(13)
                        .padding(.horizontal, stateProvider.isIpad ? 90 : 40)
                }
                .padding(.bottom, stateProvider.isIpad ? 40 : 20)
            }
            .padding(.top, 15)
            .background(backgroundColor)
        } else {
            TabView(selection: $currentPage) {
                onboardingPage(stateProvider.isIpad ? iPadOnboardingInfos[currentPage] : iOSOnboardingInfos[currentPage])
            }
            .ignoresSafeArea(edges: .top)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(backgroundColor)
        }
    }
}

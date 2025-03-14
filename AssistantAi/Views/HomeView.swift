import Foundation
import SwiftUI
import SuperwallKit

struct HomeView: View {
    private struct EliteToolItem {
        struct BadgeInfo {
            let text: String
            let icon: String
            let color: Color
        }
        
        let title: String
        let icon: String
        let iconRadius: Int
        let description: String
        let badgeInfo: BadgeInfo?
        let footerText: String?
        let onTap: () -> Void
    }
    
    private struct PromptItem {
        let prompt: String
        let image: String
        let category: PromptItemCategory
    }
    
    private enum PromptItemCategory: String, CaseIterable {
        case dating = "💖 Dating & Romance"
        case finance = "💰 Finance & Advice"
        case future = "🔮 Future Predictions"
        case health = "🏥 Health & Wellness"
        case education = "📚 Education & Learning"
        case productivity = "🚀 Productivity & Growth"
        case tech = "🤖 Technology & AI"
    }
    
    private let popularPrompts: [PromptItem] = [
        PromptItem(prompt: "What are the best first-date conversation starters?", image: "💬", category: .dating),
        PromptItem(prompt: "How can I make my online dating profile more attractive?", image: "📸", category: .dating),
        PromptItem(prompt: "Create a romantic date night plan on a budget.", image: "🌹", category: .dating),
        PromptItem(prompt: "How do I keep a long-distance relationship exciting?", image: "📞", category: .dating),
        PromptItem(prompt: "Write a heartfelt message for an anniversary.", image: "💌", category: .dating),
        PromptItem(prompt: "What are some creative date ideas for introverts?", image: "🎨", category: .dating),
        PromptItem(prompt: "How do I know if my date is really interested in me?", image: "💘", category: .dating),
        PromptItem(prompt: "What are some fun icebreaker questions for a first date?", image: "❄️", category: .dating),
        PromptItem(prompt: "How can I build confidence when talking to someone I like?", image: "😎", category: .dating),
        PromptItem(prompt: "Give me tips for planning a surprise romantic gesture.", image: "🎁", category: .dating),
        
        PromptItem(prompt: "What are the top investment opportunities in 2025?", image: "📈", category: .finance),
        PromptItem(prompt: "How can I save money while living in a big city?", image: "🏙️", category: .finance),
        PromptItem(prompt: "Best side hustles to start in 2025 for passive income.", image: "💼", category: .finance),
        PromptItem(prompt: "How to negotiate a higher salary during a job interview?", image: "🤑", category: .finance),
        PromptItem(prompt: "Explain cryptocurrency for beginners in simple terms.", image: "🪙", category: .finance),
        PromptItem(prompt: "How can I build a solid financial plan for my future?", image: "📊", category: .finance),
        PromptItem(prompt: "What are the best budgeting tips for beginners?", image: "💰", category: .finance),
        PromptItem(prompt: "How do I start investing with a small amount of money?", image: "📉", category: .finance),
        PromptItem(prompt: "What are the pros and cons of real estate investing?", image: "🏡", category: .finance),
        PromptItem(prompt: "How can I improve my credit score quickly?", image: "💳", category: .finance),
        
        PromptItem(prompt: "What will everyday life look like in 2050?", image: "🚀", category: .future),
        PromptItem(prompt: "How will AI change relationships in the next decade?", image: "🤖", category: .future),
        PromptItem(prompt: "What are the biggest technological breakthroughs expected by 2030?", image: "🔬", category: .future),
        PromptItem(prompt: "Will space tourism be affordable for everyone by 2040?", image: "🛸", category: .future),
        PromptItem(prompt: "How will climate change impact the global economy by 2050?", image: "🌍", category: .future),
        PromptItem(prompt: "What will human jobs look like in an AI-driven world?", image: "🤖", category: .future),
        PromptItem(prompt: "How will cities evolve with smart technology by 2050?", image: "🏙️", category: .future),
        PromptItem(prompt: "Will humans ever achieve immortality through science?", image: "🧬", category: .future),
        PromptItem(prompt: "What are the chances of discovering alien life in the next 50 years?", image: "👽", category: .future),
        PromptItem(prompt: "How will space colonization affect human civilization?", image: "🛰️", category: .future),
        
        PromptItem(prompt: "What are the best daily habits for a healthier lifestyle?", image: "🛏️", category: .health),
        PromptItem(prompt: "How can I improve my sleep quality naturally?", image: "🌙", category: .health),
        PromptItem(prompt: "What are some easy and healthy meal prep ideas?", image: "🥗", category: .health),
        PromptItem(prompt: "How can I reduce stress and anxiety effectively?", image: "🧘", category: .health),
        PromptItem(prompt: "What are the best exercises for boosting energy levels?", image: "🏃‍♂️", category: .health),
        PromptItem(prompt: "What are the best ways to stay motivated to exercise?", image: "💪", category: .health),
        PromptItem(prompt: "How can I build a balanced diet that fits my lifestyle?", image: "🍏", category: .health),
        PromptItem(prompt: "What are some simple mindfulness techniques for beginners?", image: "🧠", category: .health),
        PromptItem(prompt: "How can I strengthen my immune system naturally?", image: "🛡️", category: .health),
        PromptItem(prompt: "What are effective ways to maintain good posture?", image: "🪑", category: .health),
        
        PromptItem(prompt: "What are the most effective study techniques for better retention?", image: "🧠", category: .education),
        PromptItem(prompt: "How can I learn a new language quickly?", image: "🗣️", category: .education),
        PromptItem(prompt: "What are the best online courses for career development?", image: "💻", category: .education),
        PromptItem(prompt: "How can I improve my writing skills?", image: "✍️", category: .education),
        PromptItem(prompt: "What are the most useful skills to learn in 2025?", image: "🎯", category: .education),
        PromptItem(prompt: "How can I stay focused while studying for long hours?", image: "⏳", category: .education),
        PromptItem(prompt: "What are the best books to read for personal growth?", image: "📖", category: .education),
        PromptItem(prompt: "How can I improve my public speaking skills?", image: "🎤", category: .education),
        PromptItem(prompt: "What are some fun ways to teach kids math?", image: "➗", category: .education),
        PromptItem(prompt: "How can I become a better problem solver?", image: "🧩", category: .education),
        
        PromptItem(prompt: "What are the best morning routines for a productive day?", image: "🌅", category: .productivity),
        PromptItem(prompt: "How can I overcome procrastination and stay focused?", image: "⏳", category: .productivity),
        PromptItem(prompt: "What are some time management strategies for busy professionals?", image: "⏰", category: .productivity),
        PromptItem(prompt: "How can I set and achieve long-term goals effectively?", image: "🎯", category: .productivity),
        PromptItem(prompt: "What are the best habits for personal growth and success?", image: "📈", category: .productivity),
        PromptItem(prompt: "How can I balance work and personal life more effectively?", image: "⚖️", category: .productivity),
        PromptItem(prompt: "What are the top apps for boosting productivity?", image: "📱", category: .productivity),
        PromptItem(prompt: "How can I develop a growth mindset?", image: "🧠", category: .productivity),
        PromptItem(prompt: "What are the benefits of journaling for productivity?", image: "📖", category: .productivity),
        PromptItem(prompt: "How can I stay motivated and avoid burnout?", image: "🔥", category: .productivity),
        
        PromptItem(prompt: "How will AI impact jobs in the next 10 years?", image: "🤖", category: .tech),
        PromptItem(prompt: "What are the latest breakthroughs in AI research?", image: "🧠", category: .tech),
        PromptItem(prompt: "How can I start learning AI and machine learning?", image: "📚", category: .tech),
        PromptItem(prompt: "What are the ethical concerns surrounding AI development?", image: "⚖️", category: .tech),
        PromptItem(prompt: "How will quantum computing change the world?", image: "💻", category: .tech),
        PromptItem(prompt: "What are the best AI tools for increasing productivity?", image: "🚀", category: .tech),
        PromptItem(prompt: "How does blockchain technology work?", image: "🔗", category: .tech),
        PromptItem(prompt: "What is the future of robotics in everyday life?", image: "🤖", category: .tech),
        PromptItem(prompt: "How can I protect my data from cyber threats?", image: "🔐", category: .tech),
        PromptItem(prompt: "What are the best programming languages for AI development?", image: "💡", category: .tech)
    ]
    
    private let assistants: [any ApiModel] = [
        ChatGptApi.shared,
        ClaudeApi.shared,
        GeminiApi.shared,
        QwenApi.shared,
        GrokApi.shared
    ]
    
    private let tools: [EliteToolItem] = [
        EliteToolItem(
            title: "AI Image Generator",
            icon: "image-gen",
            iconRadius: 30,
            description: "Generate stunning AI-powered images from text prompts.",
            badgeInfo: .init(text: "Trending", icon: "star.fill", color: .blue),
            footerText: "Developed on SD3.5"
        ) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showImageGeneration = true
            }
        },
        //        EliteToolItem(
        //            title: "Voice Chat",
        //            icon: "mic",
        //            iconRadius: 30,
        //            description: "Engage in real-time conversations with AI using voice input.",
        //            badgeInfo: .init(text: "New", icon: "flame.fill", color: .green),
        //            footerText: nil
        //        ) {
        //
        //        },
        EliteToolItem(
            title: "YouTube Summary",
            icon: "youtube",
            iconRadius: 30,
            description: "Summarize YouTube videos instantly with AI-powered insights.",
            badgeInfo: .init(text: "Popular", icon: "chart.bar.fill", color: .orange),
            footerText: nil
        ) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showYoutubeSummary = true
            }
        },
        EliteToolItem(
            title: "Text to Speech",
            icon: "tts",
            iconRadius: 30,
            description: "Convert any text into natural-sounding AI-generated speech.",
            badgeInfo: nil,
            footerText: "Powered by Whisper"
        ) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showTextToSpeach = true
            }
        },
    ]
    
    private func promptCard(_ prompt: PromptItem) -> some View {
        Button(action: {
            stateProvider.haptics.impactOccurred()
            stateProvider.path.append(.chatView(prompt: prompt.prompt))
        }) {
            HStack {
                Text(prompt.prompt)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text(prompt.image)
                    .font(.system(size: 22))
            }
            .padding()
            .background(Colors.shared.cardColor)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
    
    private func assistantCard(_ assistant: any ApiModel) -> some View {
        Button(action: {
            stateProvider.haptics.impactOccurred()
            stateProvider.path.append(.chatView(modelType: assistant.modelType))
        }) {
            VStack(spacing: 13) {
                HStack(alignment: .center, spacing: 10) {
                    Image(assistant.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                    
                    Text(assistant.title)
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 16))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                
                Text(assistant.description)
                    .font(.custom(Fonts.shared.interRegular, size: 13))
                    .foregroundStyle(.gray)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 220, height: 120)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 17)
                    .fill(Colors.shared.cardColor)
                    .shadow(radius: 5)
            )
        }
    }
    
    private func eliteToolCard(_ item: EliteToolItem) -> some View {
        Button(action: {
            stateProvider.haptics.impactOccurred()
            if stateProvider.isSubscribed {
                item.onTap()
            } else {
                Superwall.shared.register(placement: "campaign_trigger")
            }
        }) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(item.icon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(Double(item.iconRadius))
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        if let badge = item.badgeInfo {
                            HStack(spacing: 5) {
                                Image(systemName: badge.icon)
                                Text(badge.text)
                                    .font(.custom(Fonts.shared.interRegular, size: 13))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(badge.color)
                            .clipShape(Capsule())
                        }
                    }
                    
                    Text(item.title)
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 18))
                        .foregroundColor(.white)
                    
                    Text(item.description)
                        .font(.custom(Fonts.shared.interRegular, size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                
                Spacer()
                
                if let footer = item.footerText {
                    HStack {
                        Text(footer)
                            .font(.custom(Fonts.shared.interMedium, size: 13))
                            .bold()
                            .foregroundColor(.black)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(RoundedCornerShape(radius: 15, corners: [.bottomLeft, .bottomRight]))
                }
            }
            .frame(width: 210, height: 180)
            .background(Colors.shared.cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ObservedObject private var stateProvider = StateProvider.shared
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedCategory: PromptItemCategory = .dating
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if !stateProvider.isSubscribed {
                    FreePremiumCard()
                        .padding(.top, 20)
                        .padding(.horizontal, 14)
                }
                
                Text("Elite Tools")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding(.top, 20)
                    .padding(.leading, 14)
                    .onAppear {
                        AnalyticsManager.shared.logEvent(name: "app_launch")
                    }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 14)
                            .foregroundStyle(.clear)
                        HStack {
                            ForEach(tools, id: \.title) { tool in
                                eliteToolCard(tool)
                            }
                        }
                        Rectangle()
                            .frame(width: 14)
                            .foregroundStyle(.clear)
                    }
                }
                
                Text("Assistants")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding(.top, 20)
                    .padding(.leading, 14)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 14)
                            .foregroundStyle(.clear)
                        HStack {
                            ForEach(assistants, id: \.title) { assistant in
                                assistantCard(assistant)
                            }
                        }
                        Rectangle()
                            .frame(width: 14)
                            .foregroundStyle(.clear)
                    }
                }
                
                Text("Popular Prompts")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding(.top, 20)
                    .padding(.leading, 14)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: 14)
                            .foregroundStyle(.clear)
                        ForEach(Array(PromptItemCategory.allCases), id: \.rawValue) { tool in
                            Button(action: {
                                stateProvider.haptics.impactOccurred()
                                selectedCategory = tool
                            }) {
                                HStack {
                                    Text(tool.rawValue)
                                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 16))
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .background(selectedCategory == tool ? Colors.shared.darkGreen.opacity(0.4) : Colors.shared.cardColor)
                                .cornerRadius(11)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 11)
                                        .stroke( selectedCategory == tool ? Colors.shared.lightGreen : Color(hex: "#36373a"), lineWidth: 1)
                                )
                                .padding(.trailing, 8)
                            }
                        }
                        Rectangle()
                            .frame(width: 14)
                            .foregroundStyle(.clear)
                    }
                    .padding(.vertical, 2)
                    .padding(.bottom, 8)
                }
                
                VStack(alignment: .leading) {
                    ForEach(popularPrompts.filter { $0.category == selectedCategory } , id: \.prompt) { prompt in
                        promptCard(prompt)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 25)
            }
        }
        .onAppear {
            stateProvider.stringToShare = ""
            stateProvider.imageToShare = nil
        }
        .frame(maxWidth: .infinity)
        .background(Colors.shared.backgroundColor)
    }
}

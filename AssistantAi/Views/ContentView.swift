import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @ObservedObject private var stateProvider = StateProvider.shared
    
    var body: some View {
        ZStack {
            NavigationStack(path: $stateProvider.path) {
                TabView(selection: $viewModel.selectedTab) {
                    HomeView()
                        .tabItem {
                            VStack {
                                Image(viewModel.selectedTab == 0 ? "chat" : "chat-1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Chat")
                                    .font(.custom(Fonts.shared.interRegular, size: 14))
                            }
                        }
                        .tag(0)
                    
                    PromptsView()
                        .tabItem {
                            VStack {
                                Image(viewModel.selectedTab == 1 ? "prompts" : "prompts-1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Tasks for AI")
                                    .font(.custom(Fonts.shared.interRegular, size: 14))
                            }
                        }
                        .tag(1)
                    
                    HistoryView()
                        .tabItem {
                            VStack {
                                Image(viewModel.selectedTab == 2 ? "history" : "history-1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("History")
                                    .font(.custom(Fonts.shared.interRegular, size: 14))
                            }
                        }
                        .tag(2)
                }
                .accentColor(.white)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("AI Assistant")
                            .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 28))
                            .foregroundStyle(.white)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            stateProvider.haptics.impactOccurred()
                            stateProvider.path.append(.settingsView)
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundStyle(Colors.shared.lightGreen)
                        }
                    }
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .settingsView: SettingsView()
                    case .chatView(let prompt, let modelType, let chatHistory): ChatView(prompt: prompt, modelType: modelType, chatHistory: chatHistory)
                    case .summaryView(let text, let isLyrics): SummaryView(text: text, isLyrics: isLyrics)
                    case .imageDataView(let image): ImageDataView(image: image)
                    case .audioDataView(let audioData): AudioDataView(audioFilePath: audioData)
                    }
                }
            }
            .blur(radius: stateProvider.isBlurred ? 5 : 0)
            .sheet(isPresented: $stateProvider.isSharing) {
                ShareView(activityItems: stateProvider.imageToShare != nil ? [stateProvider.imageToShare!] : [stateProvider.stringToShare])
            }
            
            if stateProvider.isBlurred {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
                    .foregroundColor(Colors.shared.backgroundColor)
                    .opacity(0.5)
                    .onTapGesture {}
            }
            
            if stateProvider.isLoading {
                VStack {
                    ProgressView()
                    
                    Text("Loading...")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.shared.interMedium, size: 18))
                }
            }
            
            YoutubeSummaryCard()
            
            ImageGenerationPopup()
            
            LyricsGenerationPopup()
            
            PDFSummaryCard()
            
            TextToSpeechCard()
            
            CustomAlertView()
        }
    }
}

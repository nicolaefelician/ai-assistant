import SwiftUI

struct YoutubeSummaryCard: View {
    @State private var videoURL: String = ""
    
    @ObservedObject private var stateProvider = StateProvider.shared

    var body: some View {
        if stateProvider.showYoutubeSummary {
            ZStack {
                Color.black.opacity(0.01)
                    .onTapGesture {
                        withAnimation {
                            stateProvider.showYoutubeSummary = false
                            stateProvider.isBlurred = false
                        }
                    }
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Text("YouTube Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                stateProvider.showYoutubeSummary = false
                                stateProvider.isBlurred = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        TextField("Enter YouTube link...", text: $videoURL)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                        
                        Button(action: {
                            stateProvider.haptics.impactOccurred()
                            if let pasteboardText = UIPasteboard.general.string {
                                videoURL = pasteboardText
                            }
                        }) {
                            Image("paste")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button(action: {
                        Task { @MainActor in
                            withAnimation {
                                stateProvider.showYoutubeSummary = false
                                stateProvider.isLoading = true
                            }
                            
                            do {
                                let summary = try await GeminiApi.shared.getYoutubeSummary(videoURL)
                                
                                stateProvider.path.append(.summaryView(text: summary))
                            } catch {
                                withAnimation {
                                    stateProvider.errorMessage = error.localizedDescription
                                    stateProvider.showError = false
                                }
                            }
                            
                            withAnimation {
                                stateProvider.isLoading = false
                                stateProvider.isBlurred = false
                            }
                        }
                    }) {
                        Text("Get Summary")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(videoURL.isEmpty ? Color.gray : Colors.shared.lightGreen)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(videoURL.isEmpty)
                }
                .padding()
                .frame(width: 320)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .onAppear {
                videoURL = ""
            }
            .transition(.opacity)
            .animation(.easeInOut, value: stateProvider.showYoutubeSummary)
        }
    }
}

import SwiftUI

struct LyricsGenerationPopup: View {
    @State private var selectedStyle = "Pop"
    @State private var lyricsPrompt = ""
    @ObservedObject private var stateProvider = StateProvider.shared
    
    private let musicStyles = [
        "Pop", "Rock", "Rap", "Jazz", "Country", "Classical", "EDM", "R&B", "Reggae", "Metal"
    ]
    
    var body: some View {
        if stateProvider.showLyricsGeneration {
            ZStack {
                Color.black.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            stateProvider.showLyricsGeneration = false
                            stateProvider.isBlurred = false
                        }
                    }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Generate Song Lyrics 🎶")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                stateProvider.showLyricsGeneration = false
                                stateProvider.isBlurred = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Style")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Picker("Select Style", selection: $selectedStyle) {
                            ForEach(musicStyles, id: \.self) { style in
                                Text(style).tag(style)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Enter Lyrics Idea")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Describe your song idea...", text: $lyricsPrompt)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        Task { @MainActor in
                            withAnimation {
                                stateProvider.showLyricsGeneration = false
                                stateProvider.isLoading = true
                            }
                            
                            do {
                                let lyrics = try await GeminiApi.shared.generateLyrics(lyricsPrompt, style: selectedStyle)
                                
                                stateProvider.path.append(.summaryView(text: lyrics))
                            } catch {
                                withAnimation {
                                    stateProvider.errorMessage = error.localizedDescription
                                    stateProvider.showError = false
                                }
                            }
                            
                            withAnimation {
                                stateProvider.isBlurred = false
                                stateProvider.isLoading = false
                            }
                        }
                    }) {
                        Text("Generate Lyrics")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(lyricsPrompt.isEmpty ? Color.gray : Colors.shared.lightGreen)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(lyricsPrompt.isEmpty)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
            }
        }
    }
}

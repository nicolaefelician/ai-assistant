import SwiftUI
import AVFoundation

struct TextToSpeechCard: View {
    @State private var textInput: String = ""
    @State private var selectedVoice: GenerationVoice = GenerationVoice(name: "alloy")
    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying: Bool = false

    @ObservedObject private var stateProvider = StateProvider.shared

    private let voices: [GenerationVoice] = [
        GenerationVoice(name: "alloy"),
        GenerationVoice(name: "ash"),
        GenerationVoice(name: "coral"),
        GenerationVoice(name: "echo"),
        GenerationVoice(name: "fable"),
        GenerationVoice(name: "onyx"),
        GenerationVoice(name: "nova"),
        GenerationVoice(name: "sage"),
        GenerationVoice(name: "shimmer")
    ]

    private struct GenerationVoice: Hashable {
        let name: String
        var audioURL: URL {
            return URL(string: "https://cdn.openai.com/API/docs/audio/\(name).wav")!
        }
    }

    var body: some View {
        if stateProvider.showTextToSpeach {
            ZStack {
                Color.black.opacity(0.01)
                    .onTapGesture {
                        withAnimation {
                            stateProvider.showTextToSpeach = false
                            stateProvider.isBlurred = false
                        }
                    }
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Text("Text-to-Speech")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                stateProvider.showTextToSpeach = false
                                stateProvider.isBlurred = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }

                    TextField("Enter text to convert to speech...", text: $textInput)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    VStack(alignment: .leading) {
                        Text("Select Voice")
                            .font(.headline)
                            .foregroundColor(.white)

                        ZStack {
                            Picker("Voice", selection: $selectedVoice) {
                                ForEach(voices, id: \.self) { voice in
                                    Text(voice.name.capitalized).tag(voice)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    stateProvider.haptics.impactOccurred()
                                    if isPlaying {
                                        stopAudio()
                                    } else {
                                        playVoicePreview(voice: selectedVoice)
                                    }
                                }) {
                                    if isPlaying {
                                        Image(systemName: "stop.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(.trailing, 13)
                                    } else {
                                        Image(systemName: "microphone.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                            .padding(.trailing, 13)
                                    }
                                }
                            }
                        }
                    }

                    Button(action: {
                        Task { @MainActor in
                            withAnimation {
                                stateProvider.showTextToSpeach = false
                                stateProvider.isLoading = true
                            }
                            
                            do {
                                let text = try await ChatGptApi.shared.generateSpeach(textInput, voice: selectedVoice.name)
                                
                                stateProvider.path.append(.audioDataView(audioPath: text))
                            } catch {
                                withAnimation {
                                    stateProvider.errorMessage = error.localizedDescription
                                    stateProvider.showError = true
                                }
                            }
                            
                            withAnimation {
                                stateProvider.isLoading = false
                                stateProvider.isBlurred = false
                            }
                        }
                    }) {
                        Text("Generate Speech")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(textInput.isEmpty ? Color.gray : Colors.shared.lightGreen)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(textInput.isEmpty)
                }
                .padding()
                .frame(width: 320)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .onAppear {
                textInput = ""
            }
            .transition(.opacity)
            .animation(.easeInOut, value: stateProvider.showTextToSpeach)
        }
    }

    private func playVoicePreview(voice: GenerationVoice) {
        let player = AVPlayer(url: voice.audioURL)
        player.play()
        self.audioPlayer = player
        self.isPlaying = true
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            self.isPlaying = false
        }
    }
    
    private func stopAudio() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
    }
}

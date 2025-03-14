import SwiftUI
import AVFoundation

final class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onPlaybackEnded: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onPlaybackEnded?()
    }
}

struct AudioDataView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @State private var audioPlayer: AVAudioPlayer?
    private let audioDelegate = AudioPlayerDelegate()
    @State private var isPlaying: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let audioFilePath: String
    
    private func shareAudio() {
        let fileURL = URL(fileURLWithPath: audioFilePath)
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func downloadAudio() {
        let fileURL = URL(fileURLWithPath: audioFilePath)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at path: \(fileURL.path)")
            return
        }
        
        let tempDestination = FileManager.default.temporaryDirectory.appendingPathComponent("DownloadedAudio.mp3")
        do {
            if FileManager.default.fileExists(atPath: tempDestination.path) {
                try FileManager.default.removeItem(at: tempDestination)
            }
            
            try FileManager.default.copyItem(at: fileURL, to: tempDestination)
        } catch {
            print("Error preparing file for download: \(error.localizedDescription)")
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [tempDestination])
        documentPicker.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    private func playAudio() {
        let audioURL = URL(fileURLWithPath: audioFilePath)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Audio file not found at \(audioURL.path)")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = audioDelegate
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Audio player error: \(error.localizedDescription)")
            isPlaying = false
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }

    var body: some View {
        VStack {
            Spacer()
            
            Text("Audio Playback")
                .font(.title3)
            
            HStack {
                Button(action: {
                    stateProvider.haptics.impactOccurred()
                    if isPlaying {
                        stopAudio()
                    } else {
                        playAudio()
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 90, height: 90)
                }
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: {
                    downloadAudio()
                }) {
                    HStack {
                        Image(systemName: "arrow.down")
                        Text("Download")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.lightGreen)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    shareAudio()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.lightGreen)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .onAppear {
            audioDelegate.onPlaybackEnded = stopAudio
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
        .background(Colors.shared.backgroundColor)
        .navigationTitle("Audio Data")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

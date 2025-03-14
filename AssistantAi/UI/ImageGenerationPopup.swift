import SwiftUI

struct ImageGenerationPopup: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    @State private var prompt: String = ""
    @State private var selectedAspectRatio: String = "16:9"
    @State private var selectedArtStyle = ArtStyleInfo(title: "Photographic", value: "photographic")
    
    private let aspectRatios = [
        "16:9", "1:1", "21:9", "2:3", "3:2",
        "4:5", "5:4", "9:16", "9:21"
    ]
    
    private final class ArtStyleInfo: Hashable {
        let title: String
        let value: String
        
        static func == (lhs: ArtStyleInfo, rhs: ArtStyleInfo) -> Bool {
            lhs.title == rhs.title &&
            lhs.value == rhs.value
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(value)
        }
        
        init(title: String, value: String) {
            self.title = title
            self.value = value
        }
    }
    
    private let artStylesList: [ArtStyleInfo] = [
        ArtStyleInfo(title: "Analog Film", value: "analog-film"),
        ArtStyleInfo(title: "3D Model", value: "3d-model"),
        ArtStyleInfo(title: "Anime", value: "anime"),
        ArtStyleInfo(title: "Neon Punk", value: "neon-punk"),
        ArtStyleInfo(title: "Origami", value: "origami"),
        ArtStyleInfo(title: "Photographic", value: "photographic"),
        ArtStyleInfo(title: "Pixel Art", value: "pixel-art"),
        ArtStyleInfo(title: "Tile Art", value: "tile-art"),
        ArtStyleInfo(title: "Line Art", value: "line-art"),
        ArtStyleInfo(title: "Low Poly", value: "low-poly"),
        ArtStyleInfo(title: "Isometric", value: "isometric"),
        ArtStyleInfo(title: "Comic", value: "comic"),
        ArtStyleInfo(title: "Digital Art", value: "digital-art"),
    ]
    
    var body: some View {
        if stateProvider.showImageGeneration {
            ZStack {
                Color.black.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            stateProvider.showImageGeneration = false
                            stateProvider.isBlurred = false
                        }
                    }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Generate Image")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                stateProvider.showImageGeneration = false
                                stateProvider.isBlurred = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    TextField("Enter image description...", text: $prompt)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Aspect Ratio")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Aspect Ratio", selection: $selectedAspectRatio) {
                                ForEach(aspectRatios, id: \.self) { ratio in
                                    Text(ratio).tag(ratio)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Art Style")
                                .font(.headline)
                                .foregroundColor(.white)
                            Picker("Art Style", selection: $selectedArtStyle) {
                                ForEach(artStylesList, id: \.title) { style in
                                    Text(style.title).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            Task { @MainActor in
                                withAnimation {
                                    stateProvider.showImageGeneration = false
                                    stateProvider.isLoading = true
                                }
                                
                                do {
//                                    let image = try await StableDiffusionApi.shared.generateImage(prompt, aspectRatio: selectedAspectRatio, style: selectedArtStyle.value)
//                                    
//                                    stateProvider.path.append(.imageDataView(image: image))
                                    throw URLError(.badURL)
                                } catch {
                                    withAnimation {
                                        stateProvider.errorMessage = "Oops! Something went wrong while generating your image. Please try again later."
                                        stateProvider.showError = true
                                    }
                                }
                                
                                withAnimation {
                                    stateProvider.isBlurred = false
                                    stateProvider.isLoading = false
                                }
                            }
                        }) {
                            Text("Generate")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(prompt.isEmpty ? Color.gray : Colors.shared.lightGreen)
                                .cornerRadius(12)
                        }
                        .disabled(prompt.isEmpty)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
            }
        }
    }
}

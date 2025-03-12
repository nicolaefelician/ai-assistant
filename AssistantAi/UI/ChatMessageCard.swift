import SwiftUI

struct ChatMessageCard: View {
    @ObservedObject var chatMessage: ChatMessage
    
    private struct TypingIndicatorView: View {
        @State private var animate = false
        
        var body: some View {
            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animate ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                            value: animate
                        )
                }
            }
            .onAppear {
                animate = true
            }
            .padding(10)
            .background(Colors.shared.cardColor.opacity(0.8))
            .cornerRadius(12)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                if !chatMessage.images.isEmpty {
                    ReversedScrollView {
                        ForEach(Array(chatMessage.images.enumerated()), id: \.offset) { index, image in
                            if let imageData = Data(base64Encoded: image), let image = UIImage(data: imageData) {
                                Button(action: {
                                    
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                }
                
                HStack {
                    Spacer()
                    
                    Text(chatMessage.sendText)
                        .font(.custom(Fonts.shared.interMedium, size: 16))
                        .foregroundStyle(.white)
                        .padding(11)
                        .background(Colors.shared.cardColor)
                        .cornerRadius(11)
                }
                .frame(maxWidth: .infinity)
            }
            
            HStack(alignment: .top, spacing: 16) {
                Image(chatMessage.responseIcon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(16)
                
                if let responseText = chatMessage.responseText {
                    Text(responseText)
                        .font(.custom(Fonts.shared.interRegular, size: 16))
                        .foregroundStyle(.white)
                } else {
                    TypingIndicatorView()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

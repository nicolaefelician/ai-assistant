import SwiftUI
import LaTeXSwiftUI

struct ChatMessageCard: View {
    @ObservedObject var chatMessage: ChatMessage
    @Binding var fullScreenImage: UIImage?
    @Binding var isWriting: Bool
    
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @State private var showCopySuccess: Bool = false
    
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
                                    fullScreenImage = image
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: stateProvider.isIpad ? 150 : 100, height: stateProvider.isIpad ? 150 : 100)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: stateProvider.isIpad ? 150 : 100)
                }
                
                HStack {
                    Spacer()
                    
                    Text(chatMessage.sendText)
                        .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 19 : 17))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .padding(11)
                        .background(Colors.shared.cardColor)
                        .cornerRadius(11)
                }
            }
            
            HStack(alignment: .top, spacing: 13) {
                Image(chatMessage.responseIcon)
                    .resizable()
                    .frame(width: stateProvider.isIpad ? 52 : 38, height: stateProvider.isIpad ? 52 : 38)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 10) {
                    if let responseText = chatMessage.responseText {
                        if isWriting {
                            Text(responseText)
                                .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 19 : 17))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                        } else {
                            LaTeX(responseText)
                                .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 19 : 17))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                                .parsingMode(.onlyEquations)
                                .blockMode(.blockViews)
                        }
                        
                        if !responseText.isEmpty {
                            HStack(spacing: 15) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        showCopySuccess = true
                                    }
                                    
                                    UIPasteboard.general.string = responseText
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            showCopySuccess = false
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: showCopySuccess ? "checkmark.circle.fill" : "doc.on.doc")
                                            .font(.system(size: stateProvider.isIpad ? 18 : 16, weight: .medium))
                                        Text(showCopySuccess ? "Copied!" : "Copy")
                                            .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 16 : 14))
                                    }
                                    .foregroundColor(showCopySuccess ? Colors.shared.lightGreen : .white.opacity(0.85))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Colors.shared.cardColor)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(showCopySuccess ? Colors.shared.lightGreen : Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                
                                Button(action: {
                                    stateProvider.haptics.impactOccurred()
                                    let activityVC = UIActivityViewController(activityItems: [responseText], applicationActivities: nil)
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let rootVC = windowScene.windows.first?.rootViewController {
                                        rootVC.present(activityVC, animated: true, completion: nil)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: stateProvider.isIpad ? 18 : 16, weight: .medium))
                                        Text("Share")
                                            .font(.custom(Fonts.shared.interMedium, size: stateProvider.isIpad ? 16 : 14))
                                    }
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Colors.shared.cardColor)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.top, 8)
                        }
                    } else if let responseError = chatMessage.responseError {
                        Text(responseError)
                            .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 19 : 17))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .padding(10)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                    } else {
                        TypingIndicatorView()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

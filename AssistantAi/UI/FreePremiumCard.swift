import SwiftUI

struct FreePremiumCard: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    
    var body: some View {
        Button(action: {
            stateProvider.haptics.impactOccurred()
        }) {
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
                        Text("Try AI Assistant")
                            .font(.custom(Fonts.shared.interMedium, size: 18))
                        
                        Text("PRO")
                            .font(.custom(Fonts.shared.interMedium, size: 18))
                        
                        Text("for free!")
                            .font(.custom(Fonts.shared.interMedium, size: 18))
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    
                    Text("Tap to claim your offer now.")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.custom(Fonts.shared.interRegular, size: 14))
                }
                .padding(.bottom, 20)
                .padding(.leading, 12)
                .padding(.top, 10)
                
                Spacer()
                
                Image("bot")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 85)
            }
            
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#012D20"),
                        Color(hex: "#048742")
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

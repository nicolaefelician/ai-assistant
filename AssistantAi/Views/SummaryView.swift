import SwiftUI
import LaTeXSwiftUI

struct SummaryView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    let text: String
    let isLyrics: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                LaTeX(text)
                    .frame(maxWidth: .infinity)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.top, 20)
                    .textSelection(.enabled)
                    .parsingMode(.onlyEquations)
                    .blockMode(.blockViews)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    stateProvider.stringToShare = text
                    stateProvider.isSharing = true
                }) {
                    HStack {
                        Image("share")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Share")
                            .font(.custom(Fonts.shared.interRegular, size: 16))
                            .foregroundStyle(.white)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.backgroundColor)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Colors.shared.lightGreen, lineWidth: 1)
                    )
                }
                
                Button(action: {
                    stateProvider.haptics.impactOccurred()
                    UIPasteboard.general.string = text
                }) {
                    HStack {
                        Image("copy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Copy")
                            .font(.custom(Fonts.shared.interRegular, size: 16))
                            .foregroundStyle(.white)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.backgroundColor)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Colors.shared.lightGreen, lineWidth: 1)
                    )
                }
            }
            .padding(.bottom)
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
        .padding(.horizontal)
        .background(Colors.shared.backgroundColor)
        .navigationTitle(isLyrics ? "Lyrics" : "Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

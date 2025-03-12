import SwiftUI

struct SummaryView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    let text: String
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                Text(text)
                    .frame(maxWidth: .infinity)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.top, 20)
                    .textSelection(.enabled)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    stateProvider.stringToShare = text
                    stateProvider.isSharing = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.lightGreen )
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                
                Button(action: {
                    UIPasteboard.general.string = text
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.lightGreen)
                    .cornerRadius(12)
                    .shadow(radius: 5)
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
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

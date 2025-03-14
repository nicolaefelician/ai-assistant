import SwiftUI

struct ImageDataView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    let image: UIImage
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    stateProvider.imageToShare = image
                    stateProvider.isSharing = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.lightGreen)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                
                Button(action: {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        Text("Download")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Colors.shared.darkGreen)
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
        .navigationTitle("Generated Image")
        .navigationBarTitleDisplayMode(.inline)
    }
}

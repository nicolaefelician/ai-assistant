import SwiftUI
import Photos

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
                    let status = PHPhotoLibrary.authorizationStatus()
                    
                    if status == .authorized {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    } else if status == .notDetermined {
                        PHPhotoLibrary.requestAuthorization { newStatus in
                            if newStatus == .authorized {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            } else {
                                print("User denied access to Photos.")
                            }
                        }
                    } else {
                        print("Access to Photos is restricted or denied.")
                    }
                }) {
                    HStack {
                        Image("download")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Download")
                            .font(.custom(Fonts.shared.interRegular, size: 16))
                            .foregroundStyle(.white)
                    }
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
        .navigationTitle("Generated Image")
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            
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
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

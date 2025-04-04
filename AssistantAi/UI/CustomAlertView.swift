import Foundation
import SwiftUI

struct CustomAlertView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    
    var body: some View {
        if stateProvider.showError {
            ZStack {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            stateProvider.showError = false
                        }
                    }
                    .blur(radius: 5)
                
                VStack(spacing: 16) {
                    ZStack {
                        HStack {
                            Spacer()
                            
                            Text("Error")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    stateProvider.showError = false
                                    stateProvider.isBlurred = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Text(stateProvider.errorMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        withAnimation {
                            stateProvider.showError = false
                            stateProvider.isBlurred = false
                        }
                    }) {
                        Text("OK")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Colors.shared.lightGreen)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                .frame(width: 320)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: stateProvider.showError)
        }
    }
}

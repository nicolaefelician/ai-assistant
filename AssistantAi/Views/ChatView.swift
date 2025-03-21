import SwiftUI
import UIKit
import SuperwallKit

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @ObservedObject private var stateProvider = StateProvider.shared
    
    @FocusState var isFocused: Bool
    
    let prompt: String?
    let assistantItem: any ApiModel
    let chatHistory: ChatHistoryItem?
    
    @Environment(\.presentationMode) var presentationMode
    
    init(prompt: String? = nil, modelType: ApiModelType, chatHistory: ChatHistoryItem?) {
        self.prompt = prompt
        let model = getChatAssistant(chatHistory?.apiModelType ?? modelType)
        self.assistantItem = model
        self.chatHistory = chatHistory
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            apiModel: model,
            chatHistory: chatHistory
        ))
    }
    
    private struct ModelPickerView: View {
        @ObservedObject var viewModel: ChatViewModel
        let assistantItem: any ApiModel
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(Array(assistantItem.models.keys), id: \.self) { model in
                        Button(action: {
                            viewModel.pickedModel = ["key": model, "value": assistantItem.models[model] ?? ""]
                            viewModel.showModelPicker = false
                        }) {
                            HStack {
                                Text(model)
                                    .font(.custom(Fonts.shared.interMedium, size: 15))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if viewModel.pickedModel["key"] ?? "" == model {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.green)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select Model")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            viewModel.showModelPicker = false
                        }
                    }
                }
                .toolbarBackground(Color.black, for: .navigationBar)
                .background(Color.black.ignoresSafeArea())
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    if !viewModel.messages.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.messages, id: \.self) { message in
                                ChatMessageCard(chatMessage: message, fullScreenImage: $viewModel.fullScreenImage)
                                    .padding(.bottom, 20)
                            }
                            Rectangle()
                                .frame(height: 15)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.clear)
                                .id("BottomPadding")
                        }
                        .padding(.horizontal, 13)
                    } else {
                        VStack(spacing: 10) {
                            Image(assistantItem.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: stateProvider.isIpad ? 90 : 70, height: stateProvider.isIpad ? 90 : 70)
                                .clipShape(Circle())
                            
                            Text("Chat with \(assistantItem.title)")
                                .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 28 : 19))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(assistantItem.description)
                                .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 19 : 15))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .padding(.horizontal, stateProvider.isIpad ? 60 : 15)
                        .padding(.top, UIScreen.main.bounds.height * (isFocused ? 0.03 : 0.21))
                        .animation(.easeInOut, value: isFocused)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.shared.backgroundColor)
                
                Divider()
                    .padding(.bottom, 11.5)
                
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Menu {
                            Button(action: {
                                viewModel.showImageLibraryPicker = true
                            }) {
                                Label("Attach Photo", systemImage: "photo.on.rectangle.angled")
                            }
                            Button(action: {
                                viewModel.showPhotoCameraPicker = true
                            }) {
                                Label("Take Photo", systemImage: "camera.fill")
                            }
                        } label: {
                            Image(systemName: "photo.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: stateProvider.isIpad ? 30 : 22, weight: .medium))
                                .padding(.top, viewModel.showImages ? 10 : 0)
                        }
                        
                        VStack {
                            if !viewModel.uploadedImages.isEmpty && viewModel.showImages {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(Array(viewModel.uploadedImages.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: stateProvider.isIpad ? 120 : 80, height: stateProvider.isIpad ? 120 : 80)
                                                    .cornerRadius(10)
                                                    .clipped()
                                                
                                                Button(action: {
                                                    viewModel.uploadedImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.gray)
                                                        .background(Color.white.clipShape(Circle()))
                                                }
                                                .offset(x: -5, y: 7)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                }
                                .frame(height: stateProvider.isIpad ? 120 : 80)
                            }
                            
                            TextField("Ask a question", text: $viewModel.inputText, axis: .vertical)
                                .focused($isFocused)
                                .padding(.horizontal, 16)
                                .lineLimit(1...5)
                                .autocorrectionDisabled()
                        }
                        .padding(.vertical, stateProvider.isIpad ? 20 : 13)
                        .background(Colors.shared.cardColor)
                        .cornerRadius(26)
                        .padding(.horizontal, 2.5)
                        
                        if viewModel.isWriting {
                            Button(action: {
                                stateProvider.haptics.impactOccurred()
                                viewModel.cancelResponse()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Colors.shared.darkGreen)
                                        .frame(width: stateProvider.isIpad ? 55 : 40, height: stateProvider.isIpad ? 55 : 40)
                                    
                                    Image(systemName: "stop.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: stateProvider.isIpad ? 26 : 17, height: stateProvider.isIpad ? 26 : 17)
                                        .foregroundStyle(.white)
                                }
                            }
                        } else {
                            Button(action: {
                                stateProvider.haptics.impactOccurred()
                                
                                if viewModel.inputText.isEmpty { return }
                                
                                if stateProvider.messagesCount > 0 || stateProvider.isSubscribed {
                                    Task {
                                        await viewModel.sendMessage()
                                    }
                                    stateProvider.sendMessage()
                                } else {
                                    Superwall.shared.register(placement: "campaign_trigger")
                                }
                                
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo("BottomPadding", anchor: .bottom)
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Colors.shared.darkGreen)
                                        .frame(width: stateProvider.isIpad ? 55 : 40, height: stateProvider.isIpad ? 55 : 40)
                                    
                                    Image("send")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: stateProvider.isIpad ? 30 : 22, height: stateProvider.isIpad ? 30 : 22)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, stateProvider.isIpad ? 60 : 14)
                .padding(.bottom, 11.5)
                .onAppear {
                    proxy.scrollTo("BottomPadding", anchor: .bottom)
                }
            }
            .background(Colors.shared.backgroundColor)
        }
        .sheet(isPresented: $viewModel.showImageLibraryPicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage, isImagePickerPresented: $viewModel.showImageLibraryPicker, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $viewModel.showPhotoCameraPicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage, isImagePickerPresented: $viewModel.showPhotoCameraPicker, sourceType: .camera)
        }
        .fullScreenCover(isPresented: $viewModel.showFullScreenImage) {
            VStack {
                HStack {
                    Button(action: {
                        stateProvider.haptics.impactOccurred()
                        viewModel.showFullScreenImage = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                if let image = viewModel.fullScreenImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Colors.shared.backgroundColor)
        }
        .onAppear {
            if let prompt = prompt {
                viewModel.inputText = prompt
            }
            viewModel.pickedModel = ["key": assistantItem.models.first?.key, "value": assistantItem.models.first?.value]
        }
        .onTapGesture {
            isFocused = false
        }
        .confirmationDialog("Choose Action", isPresented: $viewModel.showActionSheet, titleVisibility: .visible) {
            Button(role: .none) {
                stateProvider.stringToShare = viewModel.getShareString()
                stateProvider.isSharing = true
            } label: {
                Text("Export text")
            }
            
            Button(role: .none) {
                viewModel.showModelPicker = true
            } label: {
                Text("Change model")
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showModelPicker) {
            ModelPickerView(viewModel: viewModel, assistantItem: assistantItem)
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
            
            ToolbarItem(placement: .principal) {
                Text(assistantItem.title)
                    .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 28 : 19))
                    .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    stateProvider.haptics.impactOccurred()
                    viewModel.showActionSheet = true
                }) {
                    Image("more")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                }
            }
        }
    }
}

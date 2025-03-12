import SwiftUI
import UIKit

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
                ScrollView {
                    if !viewModel.messages.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.messages, id: \.self) { message in
                                ChatMessageCard(chatMessage: message)
                                    .padding(.bottom, 20)
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(.clear)
                                .id("BottomPadding")
                        }
                        .padding(.horizontal, 13)
                    } else {
                        VStack(spacing: 10) {
                            Image(assistantItem.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                            
                            Text("Start a conversation with \(assistantItem.title)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(assistantItem.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .padding(.horizontal, 20)
                        .padding(.top, UIScreen.main.bounds.height * (isFocused ? 0.03 : 0.18))
                        .animation(.easeInOut, value: isFocused)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.shared.backgroundColor)
                
                VStack(spacing: 0) {
                    if !viewModel.uploadedImages.isEmpty && viewModel.showImages {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(Array(viewModel.uploadedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
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
                        .frame(height: 80)
                        .padding(.top, 10)
                    }
                    
                    HStack {
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
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .font(.system(size: 19, weight: .medium))
                        }
                        
                        
                        TextField("Ask a question", text: $viewModel.inputText, axis: .vertical)
                            .focused($isFocused)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 7)
                            .background(Colors.shared.cardColor)
                            .lineLimit(1...5)
                            .autocorrectionDisabled()
                        
                        Button(action: {
                            stateProvider.haptics.impactOccurred()
                            if viewModel.inputText.isEmpty { return }
                            
                            viewModel.scrollToBottom(proxy: proxy)
                            Task {
                                await viewModel.sendMessage()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Colors.shared.lightGreen)
                                    .frame(width: 40, height: 40)
                                
                                Image("send")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Colors.shared.cardColor)
                .clipShape(RoundedCornerShape(radius: 30, corners: .allCorners))
                .overlay(
                    RoundedCornerShape(radius: 30, corners: .allCorners)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 13)
                .padding(.bottom, 13)
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
            
            Button("Cancel", role: .cancel) { }
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
                    .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 19))
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

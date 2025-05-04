import SwiftUI

struct HistoryView: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    @StateObject private var viewModel = HistoryViewModel()
    
    private func historyCard(_ historyItem: ChatHistoryItem) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text(historyItem.title ?? historyItem.messages.last?.responseText ?? "No title")
                    .font(.custom(Fonts.shared.interRegular, size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                
                Text(historyItem.date, style: .date)
                    .font(.custom(Fonts.shared.interRegular, size: 15))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                stateProvider.haptics.impactOccurred()
                viewModel.selectedHistoryId = historyItem.id
                viewModel.showActionSheet = true
            }) {
                Image("dots")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 21, height: 21)
            }
        }
        .padding()
        .background(Colors.shared.cardColor)
        .cornerRadius(10)
    }
    
    var body: some View {
        ScrollView {
            if stateProvider.chatHistory.isEmpty {
                VStack(spacing: 16) {
                    Image("message")
                        .resizable()
                        .scaledToFit()
                        .frame(width: stateProvider.isIpad ? 120 : 80, height: stateProvider.isIpad ? 120 : 80)
                    
                    Text("No Chat History")
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 30 : 21))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Start a conversation and your chat history will appear here.")
                        .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 20 : 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, stateProvider.isIpad ? 70 : 43)
                }
                .padding(.top, UIScreen.main.bounds.height * 0.27)
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    if !stateProvider.isSubscribed {
                        FreePremiumCard()
                            .padding(.bottom, 10)
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        TextField("Search by title or date", text: $viewModel.inputText)
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(Colors.shared.cardColor)
                    .cornerRadius(16)
                    
                    HStack {
                        Text("History")
                            .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 35 : 25))
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    if viewModel.filteredChatHistories.isEmpty && !viewModel.inputText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: stateProvider.isIpad ? 60 : 40, height: stateProvider.isIpad ? 60 : 40)
                                .foregroundColor(.gray)
                            
                            Text("No Results Found")
                                .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 28 : 21))
                                .foregroundColor(.white)
                            
                            Text("Try searching with different keywords or browse your chat history.")
                                .font(.custom(Fonts.shared.interRegular, size: stateProvider.isIpad ? 18 : 15))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, stateProvider.isIpad ? 40 : 20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, stateProvider.isIpad ? 40 : 30)
                        .background(Colors.shared.cardColor)
                        .cornerRadius(16)
                    } else {
                        VStack(spacing: 13) {
                            ForEach(viewModel.filteredChatHistories.sorted { $0.date > $1.date }) { historyItem in
                                Button(action: {
                                    stateProvider.haptics.impactOccurred()
                                    stateProvider.path.append(.chatView(modelType: historyItem.apiModelType, chatHistory: historyItem))
                                }) {
                                    historyCard(historyItem)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, stateProvider.isIpad ? 60 : 14)
                .padding(.vertical, 20)
                .confirmationDialog("Choose Action", isPresented: $viewModel.showActionSheet, titleVisibility: .visible) {
                    Button(role: .none) {
                        viewModel.showActionSheet = false
                        viewModel.showTitleInputSheet = true
                    } label: {
                        Text("Change Title")
                    }
                    
                    Button(role: .destructive) {
                        guard let id = viewModel.selectedHistoryId else { return }
                        stateProvider.chatHistory.removeAll { $0.id == id }
                        stateProvider.saveChatHistory()
                        viewModel.filteredChatHistories = stateProvider.chatHistory
                        viewModel.showActionSheet = false
                    } label: {
                        Label("Delete Chat", systemImage: "trash")
                    }
                    
                    Button("Cancel", role: .cancel) { }
                }
                .onAppear {
                    viewModel.filteredChatHistories = stateProvider.chatHistory
                }
            }
        }
        .background(Colors.shared.backgroundColor)
        .alert("Enter new title", isPresented: $viewModel.showTitleInputSheet) {
            TextField("New title", text: $viewModel.newTitle)
            Button("Save") {
                if let id = viewModel.selectedHistoryId,
                   let index = stateProvider.chatHistory.firstIndex(where: { $0.id == id }) {
                    stateProvider.chatHistory[index].title = viewModel.newTitle
                    stateProvider.saveChatHistory()
                }
                viewModel.showTitleInputSheet = false
            }
            Button("Cancel", role: .cancel) {
                viewModel.showTitleInputSheet = false
            }
        }
    }
}

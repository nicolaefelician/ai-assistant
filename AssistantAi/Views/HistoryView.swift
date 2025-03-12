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
                        .frame(width: 80, height: 80)
                    
                    Text("No Chat History")
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 21))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Start a conversation and your chat history will appear here.")
                        .font(.custom(Fonts.shared.interRegular, size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 43)
                }
                .padding(.top, UIScreen.main.bounds.height * 0.27)
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    HStack {
                        Image("search")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 29, height: 29)
                        
                        TextField("Search by title or date", text: $viewModel.inputText)
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(Colors.shared.cardColor)
                    .cornerRadius(16)
                    
                    HStack {
                        Text("History")
                            .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 25))
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
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
                    .onAppear {
                        viewModel.filteredChatHistories = stateProvider.chatHistory
                    }
                }
                .padding(.horizontal, 14)
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
                        viewModel.showActionSheet = false
                    } label: {
                        Label("Delete Chat", systemImage: "trash")
                    }
                    
                    Button("Cancel", role: .cancel) { }
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

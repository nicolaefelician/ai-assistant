import SwiftUI
import SuperwallKit

struct PromptsView: View {
    @StateObject private var viewModel = PromptsViewModel()
    @ObservedObject private var stateProvider = StateProvider.shared
    
    private var filteredTasks: [[AiTask]] {
        let query = viewModel.inputText.lowercased()
        
        if query.isEmpty {
            return [firstTasksColumn, secondTasksColumn]
        }
        
        let filteredFirst = firstTasksColumn.filter { task in
            task.title.lowercased().contains(query) || task.subTitle.lowercased().contains(query)
        }
        
        let filteredSecond = secondTasksColumn.filter { task in
            task.title.lowercased().contains(query) || task.subTitle.lowercased().contains(query)
        }
        
        return [filteredFirst, filteredSecond]
    }
    
    private let firstTasksColumn: [AiTask] = [
        AiTask(title: "YouTube", subTitle: "Summarise YouTube videos", image: "youtube_icon", backgroundColor: Color.red, cardHeight: 200, position: .bottom) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showYoutubeSummary = true
            }
        },
        AiTask(title: "Interview", subTitle: "Complete an interview", image: "interview_icon", backgroundColor: Color.orange, cardHeight: 107, position: .rightBottom) {
            let prompt = """
                Job Title:
                Expected Salary:
                Years of Experience:
                Key Skills:
                Preferred Work Environment:
                Why are you a good fit for this role?:
            """
            StateProvider.shared.path.append(.chatView(prompt: prompt, modelType: .recruiter))
        },
        AiTask(title: "Coding", subTitle: "AI coding assistant", image: "coding_icon", backgroundColor: Color.green, cardHeight: 107, position: .right) {
            StateProvider.shared.path.append(.chatView(modelType: .coding))
        },
        AiTask(title: "Story", subTitle: "Generate stories", image: "book", backgroundColor: Color.blue, cardHeight: 107, position: .right) {
            StateProvider.shared.path.append(.chatView(modelType: .storyTelling))
        },
        AiTask(title: "PDF", subTitle: "Document summary", image: "pdf", backgroundColor: Color(hex: "#ffaf32"), cardHeight: 107, position: .right) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showPdfSummary = true
            }
        },
    ]
    
    private let secondTasksColumn: [AiTask] = [
        AiTask(title: "Image", subTitle: "Generate image", image: "image_icon", backgroundColor: Color.green, cardHeight: 107, position: .rightBottom) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showImageGeneration = true
            }
        },
        AiTask(title: "Math", subTitle: "Snap a picture and solve math equations instantly", image: "math_icon", backgroundColor: Color.indigo, cardHeight: 225, position: .bottom) {
            StateProvider.shared.showPhotoCamera = true
        },
        AiTask(title: "Insights", subTitle: "Invest with insight", image: "insights_icon", backgroundColor: Color.brown, cardHeight: 107, position: .rightBottom) {
            StateProvider.shared.path.append(.chatView(modelType: .invest))
        },
        AiTask(title: "Creativity", subTitle: "Compose lyrics to the style of your choice", image: "creativity_icon", backgroundColor: Color.blue, cardHeight: 200, position: .bottom) {
            withAnimation {
                StateProvider.shared.isBlurred = true
                StateProvider.shared.showLyricsGeneration = true
            }
        },
    ]
    
    private func taskCard(_ task: AiTask) -> some View {
        Button(action: {
            stateProvider.haptics.impactOccurred()
            if stateProvider.isSubscribed || task.title == "Insights" || task.title == "Story" || task.title == "Coding" {
                task.onTap()
            } else if stateProvider.isTaskCompleted(task) {
                Superwall.shared.register(placement: "campaign_trigger")
            } else {
                task.onTap()
            }
        }) {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(task.title)
                            .font(.custom(Fonts.shared.instrumentSansSemiBold, size: 21))
                            .foregroundStyle(.white)
                        
                        Text(task.subTitle)
                            .font(.custom(Fonts.shared.interRegular, size: 17))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, task.position == .bottom ? 10 : 0)
                    
                    Spacer()
                    
                    if task.position == .rightTop || task.position == .rightBottom || task.position == .right {
                        VStack(alignment: .trailing) {
                            if task.position == .rightBottom {
                                Spacer()
                            }
                            
                            Image(task.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: stateProvider.isIpad ? 100 : 70, height: stateProvider.isIpad ? 130 : 90)
                            
                            if task.position == .rightTop {
                                Spacer()
                            }
                        }
                    }
                }
                
                if task.position == .bottom {
                    Spacer()
                    
                    Image(task.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: stateProvider.isIpad ? 180 : 150, height: stateProvider.isIpad ? 120 : 88)
                        .padding(.bottom, 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: task.cardHeight)
            .padding(.leading, stateProvider.isIpad ? 25 : 10)
            .background(task.backgroundColor)
            .cornerRadius(14)
            .fullScreenCover(isPresented: $stateProvider.showPhotoCamera) {
                ImagePicker(selectedImage: $viewModel.selectedImage, isImagePickerPresented: $stateProvider.showPhotoCamera, sourceType: .camera)
            }
        }
    }
    
    var body: some View {
        ScrollView {
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
                    
                    TextField("Search task", text: $viewModel.inputText)
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Colors.shared.cardColor)
                .cornerRadius(16)
                
                HStack {
                    Text("Tasks")
                        .font(.custom(Fonts.shared.instrumentSansSemiBold, size: stateProvider.isIpad ? 35 : 25))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(filteredTasks[0], id: \.title) { task in
                            taskCard(task)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 10) {
                        ForEach(filteredTasks[1], id: \.title) { task in
                            taskCard(task)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, stateProvider.isIpad ? 70 : 14)
            .padding(.vertical, 20)
        }
        .background(Colors.shared.backgroundColor)
    }
}

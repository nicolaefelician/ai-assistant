import SwiftUI
import UniformTypeIdentifiers

struct PDFSummaryCard: View {
    @ObservedObject private var stateProvider = StateProvider.shared
    @State private var selectedPdfUrl: URL?
    @State private var pdfFileData: Data?
    @State private var isDocumentPickerPresented = false

    var body: some View {
        if stateProvider.showPdfSummary {
            ZStack {
                Color.black.opacity(0.01)
                    .onTapGesture {
                        withAnimation {
                            stateProvider.showPdfSummary = false
                            stateProvider.isBlurred = false
                        }
                    }
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Text("PDF Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                stateProvider.showPdfSummary = false
                                stateProvider.isBlurred = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        isDocumentPickerPresented.toggle()
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.headline)
                            Text(selectedPdfUrl == nil ? "Select a PDF file" : selectedPdfUrl?.lastPathComponent ?? "Selected PDF")
                                .lineLimit(1)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .fileImporter(isPresented: $isDocumentPickerPresented, allowedContentTypes: [.pdf]) { result in
                        switch result {
                        case .success(let url):
                            if url.startAccessingSecurityScopedResource() {
                                defer { url.stopAccessingSecurityScopedResource() }
                                pdfFileData = try? Data(contentsOf: url)
                                selectedPdfUrl = url
                            } else {
                                stateProvider.isBlurred = false
                                stateProvider.showPdfSummary = false
                                stateProvider.errorMessage = "Failed to get permission to access file."
                                stateProvider.showError = true
                            }
                        case .failure:
                            stateProvider.isBlurred = false
                            stateProvider.showPdfSummary = false
                            stateProvider.errorMessage = "Failed to get permission to access file."
                            stateProvider.showError = true
                        }
                    }

                    Button(action: {
                        Task { @MainActor in
                            guard let pdfData = pdfFileData else { return }
                            
                            withAnimation {
                                stateProvider.showPdfSummary = false
                                stateProvider.isLoading = true
                            }
 
                            do {
                                let summary = try await GeminiApi.shared.getPDFSummary(pdfData: pdfData)
                                
                                stateProvider.path.append(.summaryView(text: summary))
                            } catch {
                                withAnimation {
                                    stateProvider.errorMessage = "Couldn't summarize the PDF. Make sure the file is valid and try again."
                                    stateProvider.showError = true
                                }
                            }
                            
                            self.selectedPdfUrl = nil
                            self.pdfFileData = nil
                            
                            withAnimation {
                                stateProvider.isLoading = false
                                stateProvider.isBlurred = false
                            }
                        }
                    }) {
                        Text("Get Summary")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedPdfUrl == nil ? Color.gray : Colors.shared.lightGreen)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(selectedPdfUrl == nil)
                }
                .padding()
                .frame(width: 320)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: stateProvider.showPdfSummary)
        }
    }
}

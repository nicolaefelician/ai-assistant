import Foundation
import UIKit
import FirebaseVertexAI
import PDFKit

final class GeminiApi: ApiModel, Hashable {
    var models: [String: String] = [
        "Gemini 2.0 Flash": "gemini-2.0-flash",
        "Gemini 2.0 Flash Lite": "gemini-2.0-flash-lite",
        "Gemini 1.5 Pro": "gemini-1.5-pro",
        "Gemini 1.5 Flash": "gemini-1.5-flash"
    ]
    
    var modelType: ApiModelType = .gemini
    var title: String = "Gemini"
    var description: String = "Google's Gemini AI, based on the latest deep learning models, offers advanced reasoning and multimodal capabilities."
    var image: String = "gemini"
    
    static var shared: GeminiApi = GeminiApi()
    
    static func == (lhs: GeminiApi, rhs: GeminiApi) -> Bool {
        return lhs.modelType == rhs.modelType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(modelType)
        hasher.combine(description)
    }
    
    func getYoutubeSummary(_ url: String) async throws -> String {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        
        let video = FileDataPart(uri: url, mimeType: "video/mp4")
        
        let prompt = "You are an advanced AI assistant skilled in summarizing multimedia content. Your task is to watch and analyze the provided YouTube video and generate a clear, concise, and accurate summary of its content. Focus on capturing the main ideas, key points, and any important details while ignoring filler or irrelevant information. Ensure the summary is easy to understand and provides valuable insights to someone who has not watched the video."
        
        let contentStream = try await model.generateContent(video, prompt)
        
        let filteredText = contentStream.text?.replacingOccurrences(of: "**", with: "")
        
        return filteredText ?? ""
    }
    
    private func cleanResponseText(_ text: String) -> String {
        var cleanedText = text
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^\\*\\s", with: "• ", options: .regularExpression)
        
        return cleanedText
    }
    
    private let vertex = VertexAI.vertexAI()
    
    private func extractTextFromPDF(pdfData: Data) -> String {
        guard let pdfDocument = PDFDocument(data: pdfData) else { return "" }
        
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex), let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
        }
        
        return extractedText
    }
    
    func getPDFSummary(pdfData: Data) async throws -> String {
        let model = vertex.generativeModel(modelName: "gemini-2.0-flash")
        
        let prompt = "You are an AI assistant specialized in summarizing documents. Your task is to generate a concise, structured, and easy-to-read summary of the provided PDF content."
        
        let fullText = extractTextFromPDF(pdfData: pdfData)
        
        let data = try await model.generateContent("\(prompt) \n\n PDF Text: \n\n \(fullText)")
        
        return cleanResponseText(data.text ?? "")
    }
    
    func getChatResponse(message: String, history: [ChatMessage], images: [String], version: String) async throws -> AsyncThrowingStream<String, Error> {
        let model = vertex.generativeModel(modelName: version)
        
        let uiImages = images.compactMap { base64String -> UIImage? in
            if let imageData = Data(base64Encoded: base64String) {
                return UIImage(data: imageData)
            }
            return nil
        }
        
        let contentStream: AsyncThrowingStream<GenerateContentResponse, Error>
        if uiImages.isEmpty {
            contentStream = try model.generateContentStream(message)
        } else if uiImages.count == 1 {
            contentStream = try model.generateContentStream(uiImages[0], message)
        } else if uiImages.count == 2 {
            contentStream = try model.generateContentStream(uiImages[0], uiImages[1], message)
        } else {
            contentStream = try model.generateContentStream(uiImages[0], uiImages[1], uiImages[2], message)
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                for try await line in contentStream {
                    if let text = line.text {
                        continuation.yield(cleanResponseText(text))
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func generateLyrics(_ prompt: String, style: String, mood: String) async throws -> String {
        let model = vertex.generativeModel(modelName: "gemini-2.0-flash")
        
        let systemPrompt = """
        You are an elite AI lyrics composer, skilled in crafting poetic and meaningful lyrics across all music genres.

        You create song lyrics in any style (Pop, Rock, Rap, Jazz, Country, Classical), matching the selected **style** and **mood**.

        🎯 Your output must:
        - Contain **only the lyrics**, properly structured (verses, chorus, bridge)
        - Match the given **theme**, **mood**, and **style**
        - Be **clear, rhythmic, and readable**
        - Include **creative metaphors and storytelling**
        - Never include explanations, suggestions, or follow-up questions

        ✅ Example styles:
        - **Pop Song** – Catchy hooks, emotional content
        - **Rap Song** – Strong rhyme schemes and flow
        - **Jazz Song** – Expressive, poetic, and smooth
        - **Rock Song** – Energetic, vivid, and rebellious

        ⚠️ Important:
        Respond **only with the lyrics text**. Do not add anything before or after. No commentary, no emojis, no "Here's your lyrics" text.

        Start with a strong hook and stay consistent in tone throughout.

        """
        
        let data = try await model.generateContent(systemPrompt, prompt, "Style: \(style)", "Mood: \(mood)")
        
        return cleanResponseText(data.text ?? "")
    }
}

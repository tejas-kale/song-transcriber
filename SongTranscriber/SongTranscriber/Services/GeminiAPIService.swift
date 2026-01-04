//
//  GeminiAPIService.swift
//  SongTranscriber
//
//  Created by Claude
//

import Foundation

enum GeminiAPIError: Error {
    case invalidURL
    case invalidResponse
    case apiKeyNotSet
    case transcriptionFailed(String)
}

class GeminiAPIService {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"

    init() {
        // Load API key from environment or configuration
        // In production, use a secure method to store the API key
        if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
            self.apiKey = key
        } else if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String {
            self.apiKey = key
        } else {
            self.apiKey = ""
        }
    }

    func transcribeSong(audioURL: URL, language: String) async throws -> TranscriptionResult {
        guard !apiKey.isEmpty else {
            throw GeminiAPIError.apiKeyNotSet
        }

        // Step 1: Upload the audio file
        let fileURI = try await uploadFile(audioURL: audioURL)

        // Step 2: Request transcription using Gemini Flash
        let transcription = try await requestTranscription(fileURI: fileURI, language: language)

        return transcription
    }

    private func uploadFile(audioURL: URL) async throws -> String {
        guard let url = URL(string: "\(baseURL)/files?key=\(apiKey)") else {
            throw GeminiAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let audioData = try Data(contentsOf: audioURL)
        let boundary = "Boundary-\(UUID().uuidString)"

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw GeminiAPIError.invalidResponse
        }

        struct FileUploadResponse: Codable {
            struct File: Codable {
                let uri: String
            }
            let file: File
        }

        let uploadResponse = try JSONDecoder().decode(FileUploadResponse.self, from: data)
        return uploadResponse.file.uri
    }

    private func requestTranscription(fileURI: String, language: String) async throws -> TranscriptionResult {
        guard let url = URL(string: "\(baseURL)/models/gemini-2.0-flash-exp:generateContent?key=\(apiKey)") else {
            throw GeminiAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Please transcribe the lyrics of this song in \(language).
        Provide the transcription in the following JSON format:
        {
            "title": "Song Title",
            "lyrics": "Complete lyrics with line breaks"
        }

        If you cannot detect the song title, use "Unknown Song".
        Maintain the structure and formatting of the lyrics as they appear in the song.
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "fileData": [
                                "mimeType": "audio/m4a",
                                "fileUri": fileURI
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "topK": 32,
                "topP": 1,
                "maxOutputTokens": 8192
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw GeminiAPIError.invalidResponse
        }

        struct GeminiResponse: Codable {
            struct Candidate: Codable {
                struct Content: Codable {
                    struct Part: Codable {
                        let text: String?
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let firstCandidate = geminiResponse.candidates.first,
              let textResponse = firstCandidate.content.parts.first?.text else {
            throw GeminiAPIError.transcriptionFailed("No response from API")
        }

        // Parse the JSON response
        return try parseTranscriptionResponse(textResponse)
    }

    private func parseTranscriptionResponse(_ responseText: String) throws -> TranscriptionResult {
        // Extract JSON from markdown code blocks if present
        var jsonString = responseText
        if let jsonStart = responseText.range(of: "```json"),
           let jsonEnd = responseText.range(of: "```", range: jsonStart.upperBound..<responseText.endIndex) {
            jsonString = String(responseText[jsonStart.upperBound..<jsonEnd.lowerBound])
        } else if let jsonStart = responseText.range(of: "{"),
                  let jsonEnd = responseText.range(of: "}", options: .backwards) {
            jsonString = String(responseText[jsonStart.lowerBound...jsonEnd.upperBound])
        }

        let data = jsonString.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8)!
        return try JSONDecoder().decode(TranscriptionResult.self, from: data)
    }
}

struct TranscriptionResult: Codable {
    let title: String
    let lyrics: String
}

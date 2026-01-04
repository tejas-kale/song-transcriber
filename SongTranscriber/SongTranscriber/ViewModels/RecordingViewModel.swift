//
//  RecordingViewModel.swift
//  SongTranscriber
//
//  Created by Claude
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class RecordingViewModel {
    let audioService = AudioRecordingService()
    let geminiService = GeminiAPIService()

    var selectedLanguage = "English"
    var isTranscribing = false
    var transcriptionError: String?
    var hasRecording = false

    var recordingState: RecordingState = .idle

    enum RecordingState {
        case idle
        case recording
        case recorded
        case transcribing
        case transcribed(Song)
        case error(String)
    }

    let supportedLanguages = [
        "English",
        "Spanish",
        "French",
        "German",
        "Italian",
        "Portuguese",
        "Japanese",
        "Korean",
        "Chinese",
        "Hindi",
        "Arabic"
    ]

    func requestPermissions() async -> Bool {
        return await audioService.requestMicrophonePermission()
    }

    func startRecording() {
        audioService.startRecording()
        recordingState = .recording
        hasRecording = false
    }

    func stopRecording() {
        audioService.stopRecording()
        recordingState = .recorded
        hasRecording = true
    }

    func transcribeRecording(modelContext: ModelContext) async {
        guard let audioURL = audioService.currentRecordingURL else {
            recordingState = .error("No recording found")
            return
        }

        recordingState = .transcribing

        do {
            let result = try await geminiService.transcribeSong(
                audioURL: audioURL,
                language: selectedLanguage
            )

            let song = Song(
                title: result.title,
                lyrics: result.lyrics,
                language: selectedLanguage,
                audioFileName: audioURL.lastPathComponent
            )

            modelContext.insert(song)
            try modelContext.save()

            recordingState = .transcribed(song)
        } catch {
            let errorMessage: String
            if let geminiError = error as? GeminiAPIError {
                switch geminiError {
                case .apiKeyNotSet:
                    errorMessage = "API key not configured. Please add your Gemini API key."
                case .invalidURL:
                    errorMessage = "Invalid API URL"
                case .invalidResponse:
                    errorMessage = "Invalid response from Gemini API"
                case .transcriptionFailed(let message):
                    errorMessage = "Transcription failed: \(message)"
                }
            } else {
                errorMessage = error.localizedDescription
            }
            recordingState = .error(errorMessage)
        }
    }

    func reset() {
        if let url = audioService.currentRecordingURL {
            audioService.deleteRecording(url: url)
        }
        recordingState = .idle
        hasRecording = false
    }

    func playRecording() {
        guard let url = audioService.currentRecordingURL else { return }
        audioService.playRecording(url: url)
    }

    func stopPlaying() {
        audioService.stopPlaying()
    }
}

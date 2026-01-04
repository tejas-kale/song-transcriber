//
//  RecordingView.swift
//  SongTranscriber
//
//  Created by Claude
//

import SwiftUI
import SwiftData

struct RecordingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = RecordingViewModel()
    @State private var showingPermissionAlert = false
    @State private var navigateToSong: Song?

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Language Selection
                if case .idle = viewModel.recordingState {
                    languageSelectionSection
                }

                Spacer()

                // Recording Status
                recordingStatusSection

                Spacer()

                // Action Buttons
                actionButtonsSection

                Spacer()
            }
            .padding()
            .navigationTitle("Song Transcriber")
            .navigationDestination(item: $navigateToSong) { song in
                SongDetailView(song: song)
            }
            .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
                Button("OK") { }
            } message: {
                Text("Please grant microphone access in Settings to record songs.")
            }
            .task {
                let hasPermission = await viewModel.requestPermissions()
                if !hasPermission {
                    showingPermissionAlert = true
                }
            }
        }
    }

    private var languageSelectionSection: some View {
        VStack(spacing: 15) {
            Text("Select Language")
                .font(.headline)

            Picker("Language", selection: $viewModel.selectedLanguage) {
                ForEach(viewModel.supportedLanguages, id: \.self) { language in
                    Text(language).tag(language)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
    }

    private var recordingStatusSection: some View {
        VStack(spacing: 20) {
            switch viewModel.recordingState {
            case .idle:
                Image(systemName: "mic.circle")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                Text("Ready to Record")
                    .font(.title2)
                    .fontWeight(.medium)

            case .recording:
                VStack(spacing: 15) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.red)
                        .symbolEffect(.pulse)

                    Text("Recording...")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text(viewModel.audioService.formattedRecordingTime)
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                }

            case .recorded:
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)

                    Text("Recording Complete")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text(viewModel.audioService.formattedRecordingTime)
                        .font(.system(.title3, design: .monospaced))
                }

            case .transcribing:
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(2)

                    Text("Transcribing with Gemini...")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top)
                }

            case .transcribed(let song):
                VStack(spacing: 15) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)

                    Text("Transcription Complete!")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text(song.title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

            case .error(let message):
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.red)

                    Text("Error")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            switch viewModel.recordingState {
            case .idle:
                Button(action: viewModel.startRecording) {
                    Label("Start Recording", systemImage: "record.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }

            case .recording:
                Button(action: viewModel.stopRecording) {
                    Label("Stop Recording", systemImage: "stop.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }

            case .recorded:
                VStack(spacing: 10) {
                    HStack(spacing: 15) {
                        Button(action: {
                            if viewModel.audioService.isPlaying {
                                viewModel.stopPlaying()
                            } else {
                                viewModel.playRecording()
                            }
                        }) {
                            Label(
                                viewModel.audioService.isPlaying ? "Stop" : "Play",
                                systemImage: viewModel.audioService.isPlaying ? "stop.circle" : "play.circle"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }

                        Button(action: viewModel.reset) {
                            Label("Discard", systemImage: "trash")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    }

                    Button(action: {
                        Task {
                            await viewModel.transcribeRecording(modelContext: modelContext)
                        }
                    }) {
                        Label("Transcribe Song", systemImage: "waveform.and.magnifyingglass")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                }

            case .transcribing:
                EmptyView()

            case .transcribed(let song):
                VStack(spacing: 10) {
                    Button(action: {
                        navigateToSong = song
                    }) {
                        Label("View Transcription", systemImage: "doc.text.magnifyingglass")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }

                    Button(action: viewModel.reset) {
                        Label("Record Another Song", systemImage: "plus.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                }

            case .error:
                VStack(spacing: 10) {
                    Button(action: {
                        Task {
                            await viewModel.transcribeRecording(modelContext: modelContext)
                        }
                    }) {
                        Label("Retry Transcription", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }

                    Button(action: viewModel.reset) {
                        Label("Start Over", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    RecordingView()
        .modelContainer(for: Song.self, inMemory: true)
}

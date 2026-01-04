//
//  JournalListView.swift
//  SongTranscriber
//
//  Created by Claude
//

import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Song.recordingDate, order: .reverse) private var allSongs: [Song]

    @State private var searchText = ""
    @State private var selectedSong: Song?

    private var filteredSongs: [Song] {
        if searchText.isEmpty {
            return allSongs
        } else {
            return allSongs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.lyrics.localizedCaseInsensitiveContains(searchText) ||
                song.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
                song.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredSongs.isEmpty {
                    emptyStateView
                } else {
                    songListView
                }
            }
            .navigationTitle("Song Journal")
            .searchable(text: $searchText, prompt: "Search by title, tags, or notes")
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Songs", systemImage: "music.note.list")
        } description: {
            if searchText.isEmpty {
                Text("Record and transcribe your first song to get started")
            } else {
                Text("No songs found matching '\(searchText)'")
            }
        }
    }

    private var songListView: some View {
        List {
            ForEach(filteredSongs) { song in
                NavigationLink(destination: SongDetailView(song: song)) {
                    SongRowView(song: song)
                }
            }
            .onDelete(perform: deleteSongs)
        }
    }

    private func deleteSongs(at offsets: IndexSet) {
        for index in offsets {
            let song = filteredSongs[index]

            // Delete associated audio file if it exists
            if let audioFileName = song.audioFileName {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioURL = documentsPath.appendingPathComponent(audioFileName)
                try? FileManager.default.removeItem(at: audioURL)
            }

            modelContext.delete(song)
        }
    }
}

struct SongRowView: View {
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(song.title)
                    .font(.headline)

                Spacer()

                Text(song.language)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }

            if !song.lyrics.isEmpty {
                Text(song.lyrics.prefix(100) + (song.lyrics.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text(song.displayDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if !song.tags.isEmpty {
                    Spacer()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(song.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                            if song.tags.count > 3 {
                                Text("+\(song.tags.count - 3)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Song.self, configurations: config)

    let sampleSong = Song(
        title: "Sample Song",
        lyrics: "These are some sample lyrics for the preview",
        language: "English",
        tags: ["rock", "preview", "sample"],
        notes: "This is a preview note"
    )
    container.mainContext.insert(sampleSong)

    return JournalListView()
        .modelContainer(container)
}

//
//  ContentView.swift
//  SongTranscriber
//
//  Created by Claude
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            RecordingView()
                .tabItem {
                    Label("Record", systemImage: "waveform.circle.fill")
                }

            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Song.self, inMemory: true)
}

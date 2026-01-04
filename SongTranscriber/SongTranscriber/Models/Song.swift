//
//  Song.swift
//  SongTranscriber
//
//  Created by Claude
//

import Foundation
import SwiftData

@Model
final class Song {
    var id: UUID
    var title: String
    var lyrics: String
    var language: String
    var tags: [String]
    var notes: String
    var recordingDate: Date
    var audioFileName: String?

    init(
        title: String = "Untitled Song",
        lyrics: String = "",
        language: String = "English",
        tags: [String] = [],
        notes: String = "",
        audioFileName: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.lyrics = lyrics
        self.language = language
        self.tags = tags
        self.notes = notes
        self.recordingDate = Date()
        self.audioFileName = audioFileName
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: recordingDate)
    }

    var tagsString: String {
        tags.joined(separator: ", ")
    }
}

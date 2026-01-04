//
//  SongDetailView.swift
//  SongTranscriber
//
//  Created by Claude
//

import SwiftUI
import SwiftData

struct SongDetailView: View {
    @Bindable var song: Song
    @State private var editedTitle: String = ""
    @State private var editedNotes: String = ""
    @State private var newTag: String = ""
    @State private var isEditingTitle = false
    @State private var showingShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title Section
                titleSection

                // Metadata Section
                metadataSection

                // Tags Section
                tagsSection

                // Notes Section
                notesSection

                // Lyrics Section
                lyricsSection
            }
            .padding()
        }
        .navigationTitle("Song Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [createShareText()])
        }
        .onAppear {
            editedTitle = song.title
            editedNotes = song.notes
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isEditingTitle {
                HStack {
                    TextField("Song Title", text: $editedTitle)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)

                    Button("Save") {
                        song.title = editedTitle
                        isEditingTitle = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                HStack {
                    Text(song.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: { isEditingTitle = true }) {
                        Image(systemName: "pencil")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(song.language, systemImage: "globe")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(8)

                Spacer()

                Label(song.displayDate, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)

            // Add Tag Field
            HStack {
                TextField("Add a tag", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addTag)

                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            // Tag List
            if !song.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(song.tags, id: \.self) { tag in
                        TagView(tag: tag) {
                            removeTag(tag)
                        }
                    }
                }
            } else {
                Text("No tags yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)

            TextEditor(text: $editedNotes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: editedNotes) { oldValue, newValue in
                    song.notes = newValue
                }

            if editedNotes.isEmpty {
                Text("Add your thoughts or memories about this song")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .offset(y: -110)
                    .padding(.leading, 12)
                    .allowsHitTesting(false)
            }
        }
    }

    private var lyricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lyrics")
                .font(.headline)

            Text(song.lyrics)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }

    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmedTag.isEmpty, !song.tags.contains(trimmedTag) else { return }

        song.tags.append(trimmedTag)
        newTag = ""
    }

    private func removeTag(_ tag: String) {
        song.tags.removeAll { $0 == tag }
    }

    private func createShareText() -> String {
        var text = "🎵 \(song.title)\n\n"
        text += "Language: \(song.language)\n"
        text += "Date: \(song.displayDate)\n\n"

        if !song.tags.isEmpty {
            text += "Tags: \(song.tags.map { "#\($0)" }.joined(separator: " "))\n\n"
        }

        if !song.notes.isEmpty {
            text += "Notes:\n\(song.notes)\n\n"
        }

        text += "Lyrics:\n\(song.lyrics)"

        return text
    }
}

struct TagView: View {
    let tag: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .foregroundStyle(.blue)
        .cornerRadius(12)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Song.self, configurations: config)

    let sampleSong = Song(
        title: "Sample Song",
        lyrics: "Verse 1:\nThis is a sample song\nWith some lyrics to show\n\nChorus:\nHow the detail view looks\nWith all its features on display",
        language: "English",
        tags: ["rock", "sample", "demo"],
        notes: "This is a sample note for the preview"
    )
    container.mainContext.insert(sampleSong)

    return NavigationStack {
        SongDetailView(song: sampleSong)
    }
    .modelContainer(container)
}

# Song Transcriber

An iOS app that records songs and transcribes their lyrics using Google's Gemini 3 Flash model.

## Features

- 🎤 **Audio Recording**: Record songs with a beautiful, intuitive interface
- 🌍 **Multi-language Support**: Transcribe songs in 11 different languages
- 🤖 **AI-Powered Transcription**: Uses Gemini 3 Flash for accurate lyrics transcription
- 📚 **Song Journal**: Save all your transcribed songs with automatic title detection
- 🏷️ **Tags & Notes**: Add custom tags and personal notes to each song as memory markers
- 🔍 **Powerful Search**: Search songs by title, lyrics, tags, or notes
- 📱 **Native iOS Design**: Built with SwiftUI following iOS best practices
- 💾 **Local Storage**: All data stored securely using SwiftData

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Google Gemini API key

## Project Structure

```
SongTranscriber/
├── SongTranscriber/
│   ├── App/
│   │   └── SongTranscriberApp.swift          # App entry point
│   ├── Models/
│   │   └── Song.swift                        # SwiftData model for songs
│   ├── Services/
│   │   ├── AudioRecordingService.swift       # Audio recording with AVFoundation
│   │   └── GeminiAPIService.swift            # Gemini API integration
│   ├── ViewModels/
│   │   └── RecordingViewModel.swift          # Recording workflow logic
│   ├── Views/
│   │   ├── ContentView.swift                 # Main tab navigation
│   │   ├── RecordingView.swift               # Recording interface
│   │   ├── JournalListView.swift             # Song list with search
│   │   └── SongDetailView.swift              # Song details with editing
│   ├── Assets.xcassets/
│   └── Info.plist
└── SongTranscriber.xcodeproj/
```

## Setup Instructions

### 1. Get a Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### 2. Configure the API Key

You have two options to configure your Gemini API key:

#### Option A: Environment Variable (Recommended for Testing)
```bash
# In Xcode, go to Product > Scheme > Edit Scheme
# Select "Run" > "Arguments" tab
# Add an environment variable:
# Name: GEMINI_API_KEY
# Value: your-api-key-here
```

#### Option B: Info.plist (Not Recommended for Production)
1. Open `Info.plist`
2. Add a new row:
   - Key: `GEMINI_API_KEY`
   - Type: String
   - Value: your-api-key-here

**Note**: For production apps, use a secure backend service to handle API keys.

### 3. Open the Project

1. Clone this repository
2. Navigate to the project directory
3. Open `SongTranscriber.xcodeproj` in Xcode
4. Select your development team in "Signing & Capabilities"
5. Build and run on a device or simulator

### 4. Grant Permissions

On first launch, the app will request microphone permission. Grant access to enable recording functionality.

## How to Use

### Recording a Song

1. Open the app and go to the "Record" tab
2. Select the language of the song you want to transcribe
3. Tap "Start Recording" and play the song
4. Tap "Stop Recording" when done
5. Preview your recording with the "Play" button (optional)
6. Tap "Transcribe Song" to send it to Gemini

### Managing Your Journal

1. Go to the "Journal" tab to see all your transcribed songs
2. Use the search bar to find songs by title, lyrics, tags, or notes
3. Tap any song to view its details

### Adding Tags and Notes

1. Open a song from the journal
2. Tap the text field under "Tags" to add custom tags
3. Add personal notes or memories in the "Notes" section
4. Edit the song title by tapping the pencil icon
5. Share the song using the share button in the top-right

### Deleting Songs

1. In the Journal view, swipe left on any song
2. Tap "Delete" to remove it permanently

## Technical Details

### Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Audio Framework**: AVFoundation
- **Networking**: URLSession with async/await
- **iOS Version**: 17.0+ (uses latest SwiftData and SwiftUI features)

### Key Technologies

- **SwiftData**: Modern data persistence with automatic CloudKit syncing capability
- **@Observable**: New observation framework for better performance
- **Async/Await**: Modern Swift concurrency for API calls
- **AVAudioRecorder**: High-quality audio recording with AAC compression
- **Gemini 3 Flash**: Fast, accurate AI transcription with multimodal support

### API Integration

The app uses Google's Gemini 3 Flash model through the Generative Language API:

1. **File Upload**: Audio files are uploaded to Gemini's file API
2. **Transcription**: The file URI is sent to the model with a prompt
3. **Response Parsing**: JSON response is parsed for title and lyrics

### Data Model

```swift
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
}
```

## Supported Languages

- English
- Spanish
- French
- German
- Italian
- Portuguese
- Japanese
- Korean
- Chinese
- Hindi
- Arabic

## Privacy & Security

- All recordings are stored locally on the device
- Audio files are only uploaded to Gemini for transcription
- No data is shared with third parties
- Microphone access is only used for recording

## Troubleshooting

### "API key not configured" Error

Make sure you've added your Gemini API key following the setup instructions above.

### Recording Not Working

1. Check that microphone permissions are granted in Settings > Privacy > Microphone
2. Make sure you're running on a physical device (simulator has limited audio support)

### Transcription Fails

1. Verify your API key is valid
2. Check your internet connection
3. Ensure the recording contains clear audio
4. Try recording a shorter clip (under 2 minutes works best)

### Build Errors

1. Make sure you're using Xcode 15.0 or later
2. Set deployment target to iOS 17.0 or later
3. Select a valid development team in signing settings

## Future Enhancements

Potential features for future versions:

- [ ] Export lyrics to PDF or text file
- [ ] Cloud sync with iCloud
- [ ] Playlist organization
- [ ] Audio playback with synchronized lyrics display
- [ ] Offline transcription using on-device models
- [ ] Chord detection and music theory analysis
- [ ] Social sharing features
- [ ] Dark mode customization
- [ ] Widget for quick recording access
- [ ] Apple Watch companion app

## Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to open an issue if you find a bug or have a feature request.

## License

MIT License - feel free to use this code for learning or personal projects.

## Acknowledgments

- Built with SwiftUI and SwiftData
- Powered by Google Gemini 3 Flash
- Icons from SF Symbols
- Inspired by the need to capture and preserve song lyrics

## Contact

For questions or support, please open an issue on GitHub.

---

**Note**: This app requires an active internet connection for transcription. Make sure you have a valid Gemini API key before running the app.

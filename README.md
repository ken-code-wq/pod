# Pod - AI-Powered Audio Transcription App

An intelligent Flutter application that records, transcribes, and enables AI-powered conversations about your audio.

## App Overview

Pod allows users to:
1. Record audio clips
2. Automatically transcribe recordings
3. Save transcriptions as documents
4. Chat with AI about individual or multiple transcriptions
5. Manage their library of transcriptions

## Development Plan

### 1. Project Setup (Week 1)
- Initialize Flutter project structure
- Configure required dependencies
- Set up state management solution
- Create basic UI wireframes

### 2. Audio Recording (Week 1)
- Implement audio recording functionality
- Add recording controls (start, pause, resume, stop)
- Display recording status and duration
- Handle permissions for microphone access

### 3. Speech-to-Text Implementation (Week 2)
- Integrate speech recognition package
- Convert recorded audio to text
- Display transcription progress
- Implement error handling for transcription failures

### 4. Document Management (Week 2-3)
- Create data models for transcriptions
- Set up local database for storing transcriptions
- Implement CRUD operations for transcriptions
- Add functionality to organize transcriptions

### 5. Gemini AI Integration (Week 3)
- Connect to Gemini API
- Implement conversation interface
- Enable single and multi-document AI queries
- Format and display AI responses

### 6. User Interface (Week 4)
- Design and implement final UI
- Create smooth transitions between app sections
- Ensure responsive design across devices
- Add dark/light mode support

### 7. Testing & Refinement (Week 4)
- Conduct unit and integration tests
- Perform usability testing
- Fix bugs and optimize performance
- Prepare for deployment

## Required Packages

- **Audio Recording**: `record` (^5.0.1)
  - High-quality audio recording with support for various formats

- **Speech-to-Text**: `google_speech` (^2.2.0) 
  - Uses Google's Speech-to-Text API for accurate transcription
  - Alternative: `speech_to_text` (^6.5.1) for on-device processing

- **Local Storage**: `isar` (^3.1.0)
  - Fast NoSQL database for Flutter
  - Alternative: `sqflite` (^2.3.2) for SQL-based storage

- **Gemini AI**: `google_generative_ai` (^0.2.0)
  - Official Gemini API package

- **State Management**: `flutter_bloc` (^8.1.3)
  - Predictable state management
  - Alternative: `provider` (^6.1.1) for simpler state management

- **UI Components**: 
  - `flutter_markdown` (^0.6.18) for rendering AI responses
  - `lottie` (^2.7.0) for animations

- **Utilities**:
  - `path_provider` (^2.1.2) for file system access
  - `permission_handler` (^11.1.0) for managing permissions
  - `intl` (^0.19.0) for localization

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Set up your Gemini API key (see Configuration section)
4. Run the app with `flutter run`

## Configuration

Create a `.env` file in the project root with your API key:
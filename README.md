# AI-Powered Workout Plan Generator

A Flutter application demonstrating the integration of Google's GenUI framework with Firebase AI to create dynamically generated workout plans.

## About

This project showcases how to leverage **Generative UI** to create adaptive, AI-driven user interfaces. Instead of hardcoded templates, the application generates workout plan UIs on-the-fly based on user requests, demonstrating the power of combining AI content generation with dynamic UI rendering.

## Features

- **Conversational Interface**: Simple text-based input for workout requests
- **AI-Powered Generation**: Firebase AI creates personalized bodyweight workout plans
- **Dynamic UI**: GenUI framework generates unique interfaces for each workout plan
- **Bodyweight Focus**: Specialized in creating 3-5 exercise routines using only bodyweight movements
- **Cross-Platform**: Supports Android, iOS, and Web

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **GenUI** (`^0.5.1`) - Google's generative UI framework
- **Firebase AI** - AI content generation backend
- **Firebase Core** - Backend integration and configuration
- **Dart SDK** - 3.11.0-93.1.beta

## Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase account with AI capabilities enabled
- Dart 3.11.0 or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd devfest_ak
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
- Ensure your Firebase project is set up in `firebase_options.dart`
- Firebase AI must be enabled for your project

4. Run the application:
```bash
flutter run
```

## Usage

1. Launch the application
2. Type a workout request in the text field (e.g., "Give me an upper body workout")
3. Press the send button
4. Watch as the AI generates a custom workout plan with dynamic UI
5. Continue the conversation to refine or request new workout plans

## Project Structure

```
lib/
├── main.dart              # Main application entry point
└── firebase_options.dart  # Firebase configuration
```

## How It Works

1. User enters a workout request
2. Request is sent to GenUI conversation handler
3. Firebase AI processes the request using a specialized system prompt
4. AI generates workout plan content (exercises, sets, reps)
5. GenUI dynamically creates and renders the appropriate UI
6. New surface is displayed in the conversation view

## Learn More

- [GenUI Documentation](https://pub.dev/packages/genui)
- [Firebase AI Documentation](https://firebase.google.com/docs/genkit)
- [Flutter Documentation](https://docs.flutter.dev/)

## License

This project is created for DevFest Akure demonstration purposes.

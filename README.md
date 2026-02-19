# green

A Flutter game package powered by [Game Framework](https://github.com/xraph/flutter-game-framework).

## Features

- Unity integration
- Cross-platform support (android, ios)
- Bidirectional communication between Flutter and game engine
- Easy game engine lifecycle management

## Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Unity Editor
- Game Framework CLI: `dart pub global activate game_cli`

### Development Workflow

1. **Open the game project**
   ```bash
   # Open unity_project/ in Unity Editor
   ```

2. **Export game builds**
   ```bash
   game export unity --platform android,ios
   ```

3. **Sync exported files to Flutter**
   ```bash
   game sync unity --platform android,ios
   ```

4. **Run the example app**
   ```bash
   cd example
   flutter run
   ```

## Usage

```dart
import 'package:green/green.dart';

// Use the convenience wrapper
GreenWidget(
  onEngineCreated: (controller) {
    // Send messages to game engine
    controller.sendMessage('Hello from Flutter!');
  },
  onMessage: (message) {
    // Receive messages from game engine
    print('Received: ${message.data}');
  },
)

// Or use GameWidget directly
GameWidget(
  engineType: GameEngineType.unity,
  config: const GameEngineConfig(
    androidPlatformViewMode: AndroidPlatformViewMode.virtualDisplay,
    runImmediately: true,
  ),
)
```

## Publishing

When ready to publish:

1. Update `version` in `pubspec.yaml`
2. Remove `publish_to: 'none'` from `pubspec.yaml`
3. Run: `game publish`

## License

MIT

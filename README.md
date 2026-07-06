# Field Tracker

A Flutter mobile app for field activity tracking (location, geofencing, background tracking, local storage and sync). Built with Flutter + BLoC, Dio, Geolocator, background geolocation, Hive, and code generation (freezed/json_serializable).

## Features
- Background location tracking and geofencing
- Offline storage (Hive )
- Background tasks (workmanager)
- Secure storage for credentials
- Clean architecture with dependency injection (injectable + get_it)
- Routing with go_router
- Code generation for models (freezed, json_serializable)

## Requirements
- Flutter SDK >= 3.12.1
- Android Studio / Xcode (for device/emulator)
- Platform-specific setup for background location and notifications (see platform notes below)

## Quick start — Development

1. Clone
   git clone https://github.com/bonyyamin/field_track.git
   cd field_track

2. Add environment file (not committed)
   - Create a `.env` at project root with at least:
     BASE_URL=https://api.example.com

   - Ensure `.env` is in `.gitignore` (do not commit credentials). If missing, add:
     .env

3. Install packages
   flutter pub get

4. Run code generation (freezed, json_serializable, drift, etc.)
   flutter pub run build_runner build --delete-conflicting-outputs

5. Run on device/emulator
   flutter run -d <device-id>

6. Build release
   - Android: flutter build apk --release
   - iOS: flutter build ios --release

## Configuration (.env)
- This project uses flutter_dotenv. Create a `.env` file (root) and populate keys used by the app:
  BASE_URL=https://api.example.com
  // Add any other keys used in your app (API tokens, feature flags, etc.)

Do NOT commit `.env`. Add it to `.gitignore`:
.env

## Platform notes / Permissions
- Android
  - Add background location and foreground location permissions in AndroidManifest.xml.
  - Configure WorkManager, foreground service notification for long-running background tracking.
  - Update target SDK and manifest entries per package docs (flutter_background_geolocation, geolocator).
- iOS
  - Add NSLocationWhenInUseUsageDescription / NSLocationAlwaysAndWhenInUseUsageDescription keys to Info.plist.
  - Enable background modes: Location updates, Background fetch, Remote notifications (if needed).
- Follow each plugin's README for full platform setup (especially background geolocation and geofencing).


## Common dev commands
- flutter pub get
- flutter pub run build_runner build --delete-conflicting-outputs
- flutter analyze
- flutter test
- flutter run
- flutter build apk / ios / web

## Contributing
- Fork the repo, create a branch, open a PR.
- Run code generation and tests before submitting.
- Describe breaking changes and migration steps if needed.

## Troubleshooting
- Codegen errors: run build_runner with --delete-conflicting-outputs.
- Missing platform permissions: check AndroidManifest.xml and Info.plist entries.
- Background tasks not running on Android 12+: ensure foreground service notification and proper manifest setup.
# Weather App Sarmad

A robust Flutter weather application built with Clean Architecture, BLoC state management, and functional programming principles.

## Project Overview

- **Main Technologies:** Flutter, Dart, BLoC (Cubit), GetIt, fpdart, Http.
- **Key Features:** Current weather data, multi-day forecasts, location-based weather (GPS), and city-based search.
- **Architecture:** Clean Architecture (Domain, Data, Presentation layers) organized by features.

## Architecture & Structure

The project follows a feature-driven Clean Architecture:

- **`lib/core`**: Contains cross-cutting concerns like error handling (`Failures`, `Exceptions`), constants (API keys, endpoints), theme data, and common utilities.
- **`lib/features/weather`**: The primary feature containing:
  - **`domain`**: Entities, Repositories (abstract), and Use Cases. This layer is independent of any other layer.
  - **`data`**: Repository implementations, Data Sources (Remote/Local), and Models (DTOs with JSON serialization).
  - **`presentation`**: UI components (Widgets, Pages) and state management (Cubits).
- **`lib/dependency_injection.dart`**: Centralized service locator setup using `GetIt`.

## Building and Running

### Prerequisites
- Flutter SDK (Check `pubspec.yaml` for version: `^3.10.8`)
- Dart SDK

### Key Commands
- **Install Dependencies:** `flutter pub get`
- **Run the App:** `flutter run`
- **Run Tests:** `flutter test`
- **Build Android:** `flutter build apk`
- **Build iOS:** `flutter build ios` (Requires macOS and Xcode)

## Development Conventions

- **State Management:** Use `Cubit` for managing feature states.
- **Error Handling:** Use the `fpdart` `Either` type to handle success and failure cases in repositories and use cases.
- **Dependency Injection:** Register all services, data sources, repositories, and cubits in `lib/dependency_injection.dart`.
- **Naming Conventions:**
  - Entities: `EntityName` (e.g., `WeatherEntity`)
  - Models: `ModelName` (e.g., `WeatherModel`)
  - Repositories: `RepositoryName` (abstract) and `RepositoryNameImpl`.
- **Assets:** SVG icons are preferred (using `flutter_svg`).
- **Coding Style:** Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

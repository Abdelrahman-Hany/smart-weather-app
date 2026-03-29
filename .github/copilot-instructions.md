# Copilot Instructions — weather_app_sarmad

## Architecture

Clean Architecture, feature-driven. Multiple features (`weather`, `auth`, `premium`, `ai_recommendation`) with three layers:

```
lib/
  core/          # Cross-cutting: error handling, constants, theme, utils
  features/
    weather/
    auth/
    premium/
    ai_recommendation/
      domain/    # Entities, abstract Repositories, UseCases (no framework deps)
      data/      # Models (extend entities), DataSources, RepositoryImpls
      presentation/  # Cubit + state, Screens, Widgets
  dependency_injection.dart   # GetIt service locator (sl)
  main.dart
```

## Key Conventions

- **Entities vs Models**: Domain entities are pure Dart with `const` constructors. Data models `extend` their entity and add `factory fromJson` / `toJson`. Never put serialization in entities.
- **UseCase base**: `abstract interface class UseCase<SuccessType, Params>` returning `Future<Either<Failures, SuccessType>>`. Use `NoParams` for parameterless cases. Pure-computation use cases (e.g., `ComputeDailyForecast`) may skip `UseCase` and return values directly.
- **Error flow**: Data sources throw `ServerException` → repositories catch and return `Left(Failures(...))` via fpdart `Either<Failures, T>`. `ErrorHandler.handle(e)` is the catch-all for unknown exceptions. Use `.fold()` in cubits to consume `Either`.
- **Repositories**: Abstract contracts in `domain/repositories/`, concrete `*Impl` classes in `data/repositories/`. Register against the abstract type in DI: `sl.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(...))`.
- **Data sources**: Concrete classes only (no abstract interfaces). `WeatherRemoteDataSource` uses injectable `http.Client`; `LocationStorageService` wraps `SharedPreferences`; `GeoLocationService` wraps `geolocator`.
- **State management**: `flutter_bloc` with mixed lifetimes. `WeatherCubit` and `AiRecommendationCubit` are registered as **factory**; `AuthCubit` and `PremiumCubit` are **lazy singletons**.
- **DI registration order** in `dependency_injection.dart`: External → Data Sources → Repositories → Use Cases → Cubits.
- **Utility classes**: Private-constructor pattern `ClassName._()` for static-only classes (`ApiConstants`, `AppTheme`, `WeatherUtils`, `ErrorHandler`).
- **Theme**: Material 3, `colorSchemeSeed: Color(0xFF4285F4)`. Both light/dark defined in `core/theme/app_theme.dart`; app forces `ThemeMode.light`.
- **API secrets**: Stored in `core/secrets/app_secrets.dart` as `static const`. URL builders live in `core/constants/api_constants.dart`.

## Critical Initialization Order

1. Call `WidgetsFlutterBinding.ensureInitialized()` then `Firebase.initializeApp()` in `main()`.
2. Call `await initDependencies()` before resolving anything from `sl`.
3. Initialize auth stream immediately: `final authCubit = sl<AuthCubit>()..init()`.
4. Initialize premium after auth is known:

- At startup if user is already authenticated.
- On future auth transitions via `BlocListener<AuthCubit, AuthState>`.

## Adding a New Feature

1. Create `lib/features/<name>/domain/` with entities, repository interface, and use cases.
2. Create `lib/features/<name>/data/` with models extending entities, data sources, and repository impl.
3. Create `lib/features/<name>/presentation/` with cubit (+ state), screens, and widgets.
4. Register all new dependencies in `dependency_injection.dart` following the existing layered order.
5. Provide the cubit via `BlocProvider` in the widget tree.

## File & Naming Patterns

| Element      | Convention                        | Example                                        |
| ------------ | --------------------------------- | ---------------------------------------------- |
| Files        | `snake_case.dart`                 | `weather_remote_datasource.dart`               |
| Entities     | `*Entity`                         | `WeatherEntity`                                |
| Models       | `*Model extends *Entity`          | `WeatherModel`                                 |
| Repositories | `*Repository` / `*RepositoryImpl` | `WeatherRepository` / `WeatherRepositoryImpl`  |
| Use cases    | verb phrase class + `*Params`     | `GetCurrentWeather`, `GetCurrentWeatherParams` |
| Screens      | `*_screen.dart`                   | `home_screen.dart`                             |
| Cubits       | `*_cubit.dart` / `*_state.dart`   | `weather_cubit.dart` / `weather_state.dart`    |

## Build & Run

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device
flutter run --release    # Run release mode
flutter analyze          # Static analysis and lints
flutter test             # Run tests
flutter build apk        # Android release
flutterfire configure    # Regenerate Firebase options
```

SDK constraint: `^3.10.8` (Dart 3.x features like sealed classes and patterns are available).

## Environment & Pitfalls

- `lib/core/secrets/app_secrets.dart` currently contains API keys, including a Stripe secret key (`sk_test_...`). Do not move this pattern into production code.
- Firebase config is generated in `lib/firebase_options.dart`. If Firebase project changes, rerun `flutterfire configure`.
- Keep `AuthCubit` and `PremiumCubit` initialization behavior in sync with `main.dart`; this flow is required for premium state correctness.
- `build/` and `.dart_tool/` are generated artifacts; do not edit or commit them.

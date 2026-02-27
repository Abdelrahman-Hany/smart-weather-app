import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/saved_location.dart';

enum WeatherStatus { initial, loading, loaded, error }

/// Weather data for a single location.
class LocationWeatherData extends Equatable {
  final SavedLocation location;
  final WeatherStatus status;
  final WeatherEntity? weather;
  final List<ForecastEntity> forecast;
  final List<DailyForecast> dailyForecast;
  final String errorMessage;

  const LocationWeatherData({
    required this.location,
    this.status = WeatherStatus.loading,
    this.weather,
    this.forecast = const [],
    this.dailyForecast = const [],
    this.errorMessage = '',
  });

  bool get isNight {
    if (weather == null) return false;
    final now = DateTime.now();
    return now.isBefore(weather!.sunrise) || now.isAfter(weather!.sunset);
  }

  List<ForecastEntity> get hourlyForecast {
    final now = DateTime.now();
    return forecast.where((f) => f.dateTime.isAfter(now)).take(8).toList();
  }

  LocationWeatherData copyWith({
    SavedLocation? location,
    WeatherStatus? status,
    WeatherEntity? weather,
    List<ForecastEntity>? forecast,
    List<DailyForecast>? dailyForecast,
    String? errorMessage,
  }) {
    return LocationWeatherData(
      location: location ?? this.location,
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    location.id,
    location.label,
    status,
    weather,
    forecast,
    dailyForecast,
    errorMessage,
  ];
}

/// Global state holding all locations' weather data.
class WeatherState extends Equatable {
  final List<LocationWeatherData> locations;
  final int activeIndex;
  final bool isInitializing;
  final bool isGpsLoading;

  /// Transient error message from GPS attempts, shown as a snackbar.
  final String? gpsError;

  const WeatherState({
    this.locations = const [],
    this.activeIndex = 0,
    this.isInitializing = true,
    this.isGpsLoading = false,
    this.gpsError,
  });

  /// Current active location's data (or null if none).
  LocationWeatherData? get activeLocationData {
    if (locations.isEmpty || activeIndex >= locations.length) return null;
    return locations[activeIndex];
  }

  /// Overall status based on initialization and active location.
  WeatherStatus get currentStatus {
    if (isInitializing) return WeatherStatus.loading;
    final data = activeLocationData;
    if (data == null) return WeatherStatus.initial;
    return data.status;
  }

  WeatherState copyWith({
    List<LocationWeatherData>? locations,
    int? activeIndex,
    bool? isInitializing,
    bool? isGpsLoading,
    String? gpsError,
    bool clearGpsError = false,
  }) {
    return WeatherState(
      locations: locations ?? this.locations,
      activeIndex: activeIndex ?? this.activeIndex,
      isInitializing: isInitializing ?? this.isInitializing,
      isGpsLoading: isGpsLoading ?? this.isGpsLoading,
      gpsError: clearGpsError ? null : (gpsError ?? this.gpsError),
    );
  }

  @override
  List<Object?> get props => [
    locations,
    activeIndex,
    isInitializing,
    isGpsLoading,
    gpsError,
  ];
}

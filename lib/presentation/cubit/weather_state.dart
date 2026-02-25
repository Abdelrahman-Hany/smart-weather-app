import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherEntity? weather;
  final List<ForecastEntity> forecast;
  final List<DailyForecast> dailyForecast;
  final String errorMessage;
  final String searchCity;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast = const [],
    this.dailyForecast = const [],
    this.errorMessage = '',
    this.searchCity = '',
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

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherEntity? weather,
    List<ForecastEntity>? forecast,
    List<DailyForecast>? dailyForecast,
    String? errorMessage,
    String? searchCity,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      errorMessage: errorMessage ?? this.errorMessage,
      searchCity: searchCity ?? this.searchCity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    weather,
    forecast,
    dailyForecast,
    errorMessage,
    searchCity,
  ];
}

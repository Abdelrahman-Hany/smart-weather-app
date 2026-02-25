import '../../domain/entities/forecast_entity.dart';

class ForecastModel extends ForecastEntity {
  const ForecastModel({
    required super.dateTime,
    required super.temperature,
    required super.tempMin,
    required super.tempMax,
    required super.humidity,
    required super.description,
    required super.mainCondition,
    required super.icon,
    required super.windSpeed,
    required super.windDeg,
    required super.pop,
    required super.clouds,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      description: json['weather'][0]['description'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDeg: json['wind']['deg'] as int? ?? 0,
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
      clouds: json['clouds']?['all'] as int? ?? 0,
    );
  }
}

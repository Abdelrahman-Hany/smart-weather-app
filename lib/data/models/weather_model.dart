import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.humidity,
    required super.pressure,
    required super.windSpeed,
    required super.windDeg,
    required super.description,
    required super.mainCondition,
    required super.icon,
    required super.visibility,
    required super.clouds,
    required super.sunrise,
    required super.sunset,
    required super.dateTime,
    required super.lat,
    required super.lon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      country: json['sys']?['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      pressure: json['main']['pressure'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDeg: json['wind']['deg'] as int? ?? 0,
      description: json['weather'][0]['description'] ?? '',
      mainCondition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      visibility: json['visibility'] as int? ?? 10000,
      clouds: json['clouds']?['all'] as int? ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] as int) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] as int) * 1000,
      ),
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
    );
  }
}

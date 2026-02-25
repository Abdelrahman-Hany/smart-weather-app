class WeatherEntity {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String mainCondition;
  final String icon;
  final int visibility;
  final int clouds;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime dateTime;
  final double lat;
  final double lon;

  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.visibility,
    required this.clouds,
    required this.sunrise,
    required this.sunset,
    required this.dateTime,
    required this.lat,
    required this.lon,
  });
}

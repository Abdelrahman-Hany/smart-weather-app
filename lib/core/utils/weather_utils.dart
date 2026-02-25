import 'package:flutter/material.dart';

class WeatherUtils {
  WeatherUtils._();

  static IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.cloud_rounded;
    }
  }

  static List<Color> getWeatherGradient(
    String condition, {
    bool isNight = false,
  }) {
    if (isNight) {
      return [
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
        const Color(0xFF0F3460),
      ];
    }

    switch (condition.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF4FC3F7),
          const Color(0xFF29B6F6),
          const Color(0xFF039BE5),
        ];
      case 'clouds':
        return [
          const Color(0xFF90A4AE),
          const Color(0xFF78909C),
          const Color(0xFF607D8B),
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF546E7A),
          const Color(0xFF455A64),
          const Color(0xFF37474F),
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF37474F),
          const Color(0xFF263238),
          const Color(0xFF1A237E),
        ];
      case 'snow':
        return [
          const Color(0xFFCFD8DC),
          const Color(0xFFB0BEC5),
          const Color(0xFF90A4AE),
        ];
      default:
        return [
          const Color(0xFF4FC3F7),
          const Color(0xFF29B6F6),
          const Color(0xFF039BE5),
        ];
    }
  }

  static String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  static String getUvIndexLevel(double uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  static String windDirectionFromDegrees(int degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((degrees / 22.5) + 0.5).floor() % 16;
    return directions[index];
  }
}

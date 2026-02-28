/// Pure helper functions for human-readable weather descriptions.
///
/// Used by the home screen to summarise detail-card values.
class WeatherDescriptions {
  const WeatherDescriptions._();

  static String humidityLabel(int humidity) {
    if (humidity < 30) return 'Low';
    if (humidity < 60) return 'Comfortable';
    if (humidity < 80) return 'Humid';
    return 'Very humid';
  }

  static String visibilityLabel(int visibility) {
    if (visibility >= 10000) return 'Clear';
    if (visibility >= 5000) return 'Moderate';
    if (visibility >= 1000) return 'Low';
    return 'Very low';
  }

  static String cloudLabel(int clouds) {
    if (clouds < 20) return 'Clear sky';
    if (clouds < 50) return 'Partly cloudy';
    if (clouds < 80) return 'Mostly cloudy';
    return 'Overcast';
  }

  static String feelsLikeLabel(double temp, double feelsLike) {
    final diff = feelsLike - temp;
    if (diff.abs() < 2) return 'Similar to actual';
    if (diff > 0) return 'Warmer than actual';
    return 'Cooler than actual';
  }
}

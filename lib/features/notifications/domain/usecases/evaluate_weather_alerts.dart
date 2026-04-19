import 'package:weather_app_sarmad/features/notifications/domain/entities/weather_alert_notification_entity.dart';
import 'package:weather_app_sarmad/features/weather/domain/entities/weather_entity.dart';

class EvaluateWeatherAlerts {
  WeatherAlertNotificationEntity? call({
    required WeatherEntity? previousWeather,
    required WeatherEntity currentWeather,
  }) {
    String _normalize(String? value) {
      return (value ?? '').trim().toLowerCase();
    }

    int _notificationId(String city, String kind) {
      return '${city.toLowerCase()}_$kind'.hashCode;
    }

    bool _isSnow(String condition) {
      return _normalize(condition) == 'snow';
    }

    bool _isRainOrStorm(String condition) {
      final c = _normalize(condition);
      return c == 'rain' || c == 'drizzle' || c == 'thunderstorm';
    }

    bool _isSevere(String mainCondition, double tempC, double windMps) {
      return _isRainOrStorm(mainCondition) ||
          _isSnow(mainCondition) ||
          windMps >= 10.8 ||
          tempC >= 35 ||
          tempC <= 2;
    }

    final previousCondition = _normalize(previousWeather?.mainCondition);
    final currentCondition = _normalize(currentWeather.mainCondition);

    final previousIsSevere = previousWeather == null
        ? false
        : _isSevere(
            previousWeather.mainCondition,
            previousWeather.temperature,
            previousWeather.windSpeed,
          );

    final currentIsSevere = _isSevere(
      currentWeather.mainCondition,
      currentWeather.temperature,
      currentWeather.windSpeed,
    );

    if (!currentIsSevere) {
      return null;
    }

    final changedToNewCondition = previousCondition != currentCondition;
    final enteredSevereNow = !previousIsSevere && currentIsSevere;

    if (!changedToNewCondition && !enteredSevereNow) {
      return null;
    }

    final city = currentWeather.cityName;
    final temp = currentWeather.temperature;
    final windKmh = (currentWeather.windSpeed * 3.6).toStringAsFixed(
      0,
    ); // Convert m/s to km/h

    if (_isRainOrStorm(currentWeather.mainCondition)) {
      return WeatherAlertNotificationEntity(
        id: _notificationId(city, 'rain'),
        title: 'Rain Alert in $city',
        body: 'Rainy conditions detected. Consider an umbrella.',
        payload: 'weather:rain', 
      );
    }

    if(_isSnow(currentWeather.mainCondition)) {
      return WeatherAlertNotificationEntity(
        id: _notificationId(city, 'snow'),
        title: 'Snow Alert in $city',
        body: 'Snow conditions detected. Dress warm and stay safe.',
        payload: 'weather:snow', 
      );
    }
     if (currentWeather.windSpeed >= 10.8) {
      return WeatherAlertNotificationEntity(
        id: _notificationId(city, 'wind'),
        title: 'High Wind in $city',
        body: 'Wind is around $windKmh km/h. Take care outdoors.',
        payload: 'weather:wind',
      );
    }

    if (currentWeather.temperature >= 35) {
      return WeatherAlertNotificationEntity(
        id: _notificationId(city, 'heat'),
        title: 'Heat Alert in $city',
        body: 'Temperature is $temp°C. Stay hydrated.',
        payload: 'weather:heat',
      );
    }

    if (currentWeather.temperature <= 2) {
      return WeatherAlertNotificationEntity(
        id: _notificationId(city, 'cold'),
        title: 'Cold Alert in $city',
        body: 'Temperature is $temp°C. Keep warm.',
        payload: 'weather:cold',
      );
    }

    return null;
  }
}

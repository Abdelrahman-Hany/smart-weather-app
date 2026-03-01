import '../secrets/app_secrets.dart';

class ApiConstants {
  ApiConstants._();

  static const String _apiKey = AppSecrets.openWeatherMapApiKey;
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String iconUrl = 'https://openweathermap.org/img/wn';

  static String currentWeather(double lat, double lon) =>
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';

  static String forecast(double lat, double lon) =>
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';

  static String currentWeatherByCity(String city) =>
      '$baseUrl/weather?q=$city&appid=$_apiKey&units=metric';

  static String forecastByCity(String city) =>
      '$baseUrl/forecast?q=$city&appid=$_apiKey&units=metric';

  static String weatherIcon(String iconCode, {int size = 4}) =>
      '$iconUrl/$iconCode@${size}x.png';
}

class ApiConstants {
  ApiConstants._();

  static const String apiKey = '0ff3422a96c1fc0d31e6142fe6642200';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String iconUrl = 'https://openweathermap.org/img/wn';

  static String currentWeather(double lat, double lon) =>
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

  static String forecast(double lat, double lon) =>
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

  static String currentWeatherByCity(String city) =>
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric';

  static String forecastByCity(String city) =>
      '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric';

  static String weatherIcon(String iconCode, {int size = 4}) =>
      '$iconUrl/$iconCode@${size}x.png';
}

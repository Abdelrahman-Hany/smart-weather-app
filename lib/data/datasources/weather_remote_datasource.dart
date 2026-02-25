import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    final url = ApiConstants.currentWeather(lat, lon);
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<WeatherModel> getCurrentWeatherByCity(String city) async {
    final url = ApiConstants.currentWeatherByCity(city);
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<List<ForecastModel>> getForecast(double lat, double lon) async {
    final url = ApiConstants.forecast(lat, lon);
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List;
      return list.map((item) => ForecastModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }

  Future<List<ForecastModel>> getForecastByCity(String city) async {
    final url = ApiConstants.forecastByCity(city);
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List;
      return list.map((item) => ForecastModel.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }
}

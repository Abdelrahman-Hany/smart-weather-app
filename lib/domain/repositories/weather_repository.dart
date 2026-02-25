import '../entities/weather_entity.dart';
import '../entities/forecast_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentWeather(double lat, double lon);
  Future<WeatherEntity> getCurrentWeatherByCity(String city);
  Future<List<ForecastEntity>> getForecast(double lat, double lon);
  Future<List<ForecastEntity>> getForecastByCity(String city);
}

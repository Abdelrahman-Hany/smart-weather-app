import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeather {
  final WeatherRepository repository;

  GetCurrentWeather(this.repository);

  Future<WeatherEntity> call({double? lat, double? lon, String? city}) {
    if (city != null) {
      return repository.getCurrentWeatherByCity(city);
    }
    return repository.getCurrentWeather(lat!, lon!);
  }
}

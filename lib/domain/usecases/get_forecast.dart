import '../entities/forecast_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecast {
  final WeatherRepository repository;

  GetForecast(this.repository);

  Future<List<ForecastEntity>> call({double? lat, double? lon, String? city}) {
    if (city != null) {
      return repository.getForecastByCity(city);
    }
    return repository.getForecast(lat!, lon!);
  }
}

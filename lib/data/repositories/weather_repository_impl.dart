import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeatherEntity> getCurrentWeather(double lat, double lon) {
    return remoteDataSource.getCurrentWeather(lat, lon);
  }

  @override
  Future<WeatherEntity> getCurrentWeatherByCity(String city) {
    return remoteDataSource.getCurrentWeatherByCity(city);
  }

  @override
  Future<List<ForecastEntity>> getForecast(double lat, double lon) {
    return remoteDataSource.getForecast(lat, lon);
  }

  @override
  Future<List<ForecastEntity>> getForecastByCity(String city) {
    return remoteDataSource.getForecastByCity(city);
  }
}

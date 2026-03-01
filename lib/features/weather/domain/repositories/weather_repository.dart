import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/forecast_entity.dart';
import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<Either<Failures, WeatherEntity>> getCurrentWeather(
    double lat,
    double lon,
  );
  Future<Either<Failures, WeatherEntity>> getCurrentWeatherByCity(String city);
  Future<Either<Failures, List<ForecastEntity>>> getForecast(
    double lat,
    double lon,
  );
  Future<Either<Failures, List<ForecastEntity>>> getForecastByCity(String city);
}

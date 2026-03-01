import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeatherParams {
  final double? lat;
  final double? lon;
  final String? city;

  const GetCurrentWeatherParams({this.lat, this.lon, this.city});
}

class GetCurrentWeather
    implements UseCase<WeatherEntity, GetCurrentWeatherParams> {
  final WeatherRepository repository;

  GetCurrentWeather(this.repository);

  @override
  Future<Either<Failures, WeatherEntity>> call(GetCurrentWeatherParams params) {
    if (params.city != null) {
      return repository.getCurrentWeatherByCity(params.city!);
    }
    return repository.getCurrentWeather(params.lat!, params.lon!);
  }
}

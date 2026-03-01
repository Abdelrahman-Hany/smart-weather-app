import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/forecast_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecastParams {
  final double? lat;
  final double? lon;
  final String? city;

  const GetForecastParams({this.lat, this.lon, this.city});
}

class GetForecast implements UseCase<List<ForecastEntity>, GetForecastParams> {
  final WeatherRepository repository;

  GetForecast(this.repository);

  @override
  Future<Either<Failures, List<ForecastEntity>>> call(
    GetForecastParams params,
  ) {
    if (params.city != null) {
      return repository.getForecastByCity(params.city!);
    }
    return repository.getForecast(params.lat!, params.lon!);
  }
}

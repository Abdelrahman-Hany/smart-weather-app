import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, WeatherEntity>> getCurrentWeather(
    double lat,
    double lon,
  ) async {
    try {
      final result = await remoteDataSource.getCurrentWeather(lat, lon);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, WeatherEntity>> getCurrentWeatherByCity(
    String city,
  ) async {
    try {
      final result = await remoteDataSource.getCurrentWeatherByCity(city);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, List<ForecastEntity>>> getForecast(
    double lat,
    double lon,
  ) async {
    try {
      final result = await remoteDataSource.getForecast(lat, lon);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, List<ForecastEntity>>> getForecastByCity(
    String city,
  ) async {
    try {
      final result = await remoteDataSource.getForecastByCity(city);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}

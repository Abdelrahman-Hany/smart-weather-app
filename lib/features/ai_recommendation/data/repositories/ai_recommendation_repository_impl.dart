import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../../domain/entities/clothing_recommendation_entity.dart';
import '../../domain/repositories/ai_recommendation_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRecommendationRepositoryImpl implements AiRecommendationRepository {
  final AiRemoteDataSource _dataSource;

  AiRecommendationRepositoryImpl({required AiRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failures, ClothingRecommendationEntity>> getRecommendations({
    required WeatherEntity weather,
  }) async {
    try {
      final result = await _dataSource.getRecommendations(weather: weather);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}

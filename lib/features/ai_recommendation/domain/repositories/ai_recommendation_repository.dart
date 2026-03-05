import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/clothing_recommendation_entity.dart';

abstract class AiRecommendationRepository {
  /// Get AI-powered clothing recommendations based on weather data.
  Future<Either<Failures, ClothingRecommendationEntity>> getRecommendations({
    required WeatherEntity weather,
  });
}

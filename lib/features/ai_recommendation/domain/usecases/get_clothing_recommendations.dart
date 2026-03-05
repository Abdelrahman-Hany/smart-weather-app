import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/clothing_recommendation_entity.dart';
import '../repositories/ai_recommendation_repository.dart';

class GetClothingRecommendationsParams {
  final WeatherEntity weather;

  const GetClothingRecommendationsParams({required this.weather});
}

class GetClothingRecommendations
    implements
        UseCase<
          ClothingRecommendationEntity,
          GetClothingRecommendationsParams
        > {
  final AiRecommendationRepository repository;
  const GetClothingRecommendations(this.repository);

  @override
  Future<Either<Failures, ClothingRecommendationEntity>> call(
    GetClothingRecommendationsParams params,
  ) {
    return repository.getRecommendations(weather: params.weather);
  }
}

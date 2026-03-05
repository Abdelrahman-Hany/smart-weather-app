import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../weather/domain/entities/weather_entity.dart';
import '../../domain/usecases/get_clothing_recommendations.dart';
import 'ai_recommendation_state.dart';

class AiRecommendationCubit extends Cubit<AiRecommendationState> {
  final GetClothingRecommendations _getClothingRecommendations;

  AiRecommendationCubit({
    required GetClothingRecommendations getClothingRecommendations,
  }) : _getClothingRecommendations = getClothingRecommendations,
       super(const AiRecommendationState());

  Future<void> getRecommendations(WeatherEntity weather) async {
    emit(
      state.copyWith(status: AiRecommendationStatus.loading, clearError: true),
    );

    final result = await _getClothingRecommendations(
      GetClothingRecommendationsParams(weather: weather),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AiRecommendationStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (recommendation) => emit(
        state.copyWith(
          status: AiRecommendationStatus.loaded,
          recommendation: recommendation,
        ),
      ),
    );
  }

  void reset() {
    emit(const AiRecommendationState());
  }
}

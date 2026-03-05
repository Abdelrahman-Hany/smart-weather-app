import 'package:equatable/equatable.dart';

import '../../domain/entities/clothing_recommendation_entity.dart';

enum AiRecommendationStatus { initial, loading, loaded, error }

class AiRecommendationState extends Equatable {
  final AiRecommendationStatus status;
  final ClothingRecommendationEntity? recommendation;
  final String? errorMessage;

  const AiRecommendationState({
    this.status = AiRecommendationStatus.initial,
    this.recommendation,
    this.errorMessage,
  });

  AiRecommendationState copyWith({
    AiRecommendationStatus? status,
    ClothingRecommendationEntity? recommendation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiRecommendationState(
      status: status ?? this.status,
      recommendation: recommendation ?? this.recommendation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, recommendation?.summary, errorMessage];
}

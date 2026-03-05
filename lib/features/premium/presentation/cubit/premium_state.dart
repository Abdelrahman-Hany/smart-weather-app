import 'package:equatable/equatable.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/premium_repository.dart';

enum PremiumStatus { unknown, loading, free, premium, error }

class PremiumState extends Equatable {
  final PremiumStatus status;
  final SubscriptionEntity? subscription;
  final List<ProductInfo> products;
  final String? errorMessage;
  final bool isPurchasing;

  const PremiumState({
    this.status = PremiumStatus.unknown,
    this.subscription,
    this.products = const [],
    this.errorMessage,
    this.isPurchasing = false,
  });

  bool get isPremium =>
      status == PremiumStatus.premium &&
      subscription != null &&
      subscription!.isActive;

  PremiumState copyWith({
    PremiumStatus? status,
    SubscriptionEntity? subscription,
    List<ProductInfo>? products,
    String? errorMessage,
    bool clearError = false,
    bool? isPurchasing,
  }) {
    return PremiumState(
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      products: products ?? this.products,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPurchasing: isPurchasing ?? this.isPurchasing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    subscription?.isPremium,
    products,
    errorMessage,
    isPurchasing,
  ];
}

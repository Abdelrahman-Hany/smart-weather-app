import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/premium_repository.dart';

class PurchasePremiumParams {
  final String userId;
  final String productId;
  final String purchaseToken;

  const PurchasePremiumParams({
    required this.userId,
    required this.productId,
    required this.purchaseToken,
  });
}

class PurchasePremium
    implements UseCase<SubscriptionEntity, PurchasePremiumParams> {
  final PremiumRepository repository;
  const PurchasePremium(this.repository);

  @override
  Future<Either<Failures, SubscriptionEntity>> call(
    PurchasePremiumParams params,
  ) {
    return repository.activatePremium(
      userId: params.userId,
      productId: params.productId,
      purchaseToken: params.purchaseToken,
    );
  }
}

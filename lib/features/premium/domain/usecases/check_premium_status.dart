import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/premium_repository.dart';

class CheckPremiumStatus implements UseCase<SubscriptionEntity, String> {
  final PremiumRepository repository;
  const CheckPremiumStatus(this.repository);

  @override
  Future<Either<Failures, SubscriptionEntity>> call(String userId) {
    return repository.checkPremiumStatus(userId);
  }
}

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';

abstract class PremiumRepository {
  /// Check if a user has premium access.
  Future<Either<Failures, SubscriptionEntity>> checkPremiumStatus(
    String userId,
  );

  /// Activate premium for user after successful purchase.
  Future<Either<Failures, SubscriptionEntity>> activatePremium({
    required String userId,
    required String productId,
    required String purchaseToken,
  });

  /// Restore previous purchases.
  Future<Either<Failures, SubscriptionEntity>> restorePurchases(String userId);

  /// Fetch available products from the store.
  Future<Either<Failures, List<ProductInfo>>> getAvailableProducts();
}

/// Minimal product info from the store.
class ProductInfo {
  final String id;
  final String title;
  final String description;
  final String price;

  const ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });
}

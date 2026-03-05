import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_datasource.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumDataSource _dataSource;

  PremiumRepositoryImpl({required PremiumDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failures, SubscriptionEntity>> checkPremiumStatus(
    String userId,
  ) async {
    try {
      final result = await _dataSource.checkPremiumStatus(userId);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, SubscriptionEntity>> activatePremium({
    required String userId,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final result = await _dataSource.activatePremium(
        userId: userId,
        productId: productId,
        purchaseToken: purchaseToken,
      );
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, SubscriptionEntity>> restorePurchases(
    String userId,
  ) async {
    try {
      final result = await _dataSource.restorePurchases(userId);
      return right(result);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, List<ProductInfo>>> getAvailableProducts() async {
    try {
      final products = _dataSource.getAvailableProducts();
      return right(products);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}

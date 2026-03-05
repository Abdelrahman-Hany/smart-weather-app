import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../data/datasources/premium_datasource.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/check_premium_status.dart';
import '../../domain/usecases/purchase_premium.dart';
import 'premium_state.dart';

class PremiumCubit extends Cubit<PremiumState> {
  final CheckPremiumStatus _checkPremiumStatus;
  final PurchasePremium _purchasePremium;
  final PremiumDataSource _premiumDataSource;

  String? _currentUserId;

  PremiumCubit({
    required CheckPremiumStatus checkPremiumStatus,
    required PurchasePremium purchasePremium,
    required PremiumRepository premiumRepository,
    required PremiumDataSource premiumDataSource,
  }) : _checkPremiumStatus = checkPremiumStatus,
       _purchasePremium = purchasePremium,
       _premiumDataSource = premiumDataSource,
       super(const PremiumState());

  /// Initialize premium checking and load products.
  void init(String userId) {
    _currentUserId = userId;
    checkStatus(userId);
    loadProducts();
  }

  /// Check current premium status.
  Future<void> checkStatus(String userId) async {
    _currentUserId = userId;
    emit(state.copyWith(status: PremiumStatus.loading, clearError: true));
    final result = await _checkPremiumStatus(userId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PremiumStatus.free,
          errorMessage: failure.message,
        ),
      ),
      (subscription) => emit(
        state.copyWith(
          status: subscription.isActive
              ? PremiumStatus.premium
              : PremiumStatus.free,
          subscription: subscription,
        ),
      ),
    );
  }

  /// Load available products (locally defined, no store query).
  void loadProducts() {
    final products = _premiumDataSource.getAvailableProducts();
    emit(state.copyWith(products: products));
  }

  /// Initiate a Stripe purchase.
  Future<void> purchase(String productId) async {
    if (_currentUserId == null) return;
    emit(state.copyWith(isPurchasing: true, clearError: true));
    try {
      // Launch Stripe Payment Sheet and get paymentIntent ID
      final paymentIntentId = await _premiumDataSource.processPayment(
        productId,
      );

      // Payment succeeded — activate premium in Firestore
      final result = await _purchasePremium(
        PurchasePremiumParams(
          userId: _currentUserId!,
          productId: productId,
          purchaseToken: paymentIntentId,
        ),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(isPurchasing: false, errorMessage: failure.message),
        ),
        (subscription) => emit(
          state.copyWith(
            status: PremiumStatus.premium,
            subscription: subscription,
            isPurchasing: false,
          ),
        ),
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // User dismissed the payment sheet
        emit(state.copyWith(isPurchasing: false));
      } else {
        emit(
          state.copyWith(
            isPurchasing: false,
            errorMessage: e.error.localizedMessage ?? 'Payment failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isPurchasing: false,
          errorMessage: 'Purchase failed: $e',
        ),
      );
    }
  }

  /// Restore previous purchases by checking Firestore.
  Future<void> restorePurchases() async {
    if (_currentUserId == null) return;
    emit(state.copyWith(isPurchasing: true, clearError: true));
    try {
      final sub = await _premiumDataSource.restorePurchases(_currentUserId!);
      emit(
        state.copyWith(
          status: sub.isActive ? PremiumStatus.premium : PremiumStatus.free,
          subscription: sub,
          isPurchasing: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPurchasing: false,
          errorMessage: 'Failed to restore purchases.',
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _premiumDataSource.dispose();
    return super.close();
  }
}

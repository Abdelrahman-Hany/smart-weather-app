import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/secrets/app_secrets.dart';
import '../../domain/repositories/premium_repository.dart';
import '../models/subscription_model.dart';

/// Handles Stripe payment flow and Firestore premium status storage.
class PremiumDataSource {
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  static const String _premiumMonthlyId = 'weather_premium_monthly';
  static const String _premiumYearlyId = 'weather_premium_yearly';

  /// Product definitions (Stripe test mode doesn't require store products).
  static const List<ProductInfo> _products = [
    ProductInfo(
      id: _premiumMonthlyId,
      title: 'Monthly',
      description: 'Premium access for 1 month',
      price: '\$2.99',
    ),
    ProductInfo(
      id: _premiumYearlyId,
      title: 'Yearly',
      description: 'Premium access for 1 year — best value',
      price: '\$19.99',
    ),
  ];

  /// Amount in cents for each product.
  static const Map<String, int> _priceInCents = {
    _premiumMonthlyId: 299,
    _premiumYearlyId: 1999,
  };

  PremiumDataSource({FirebaseFirestore? firestore, http.Client? httpClient})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _httpClient = httpClient ?? http.Client();

  /// Check premium status from Firestore.
  Future<SubscriptionModel> checkPremiumStatus(String userId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(userId)
          .get();
      if (!doc.exists || doc.data() == null) {
        return SubscriptionModel.free(userId);
      }
      final sub = SubscriptionModel.fromJson(doc.data()!);
      // Check if expired
      if (sub.expiresAt != null && DateTime.now().isAfter(sub.expiresAt!)) {
        await _firestore.collection('subscriptions').doc(userId).update({
          'isPremium': false,
        });
        return SubscriptionModel.free(userId);
      }
      return sub;
    } catch (e) {
      throw ServerException('Failed to check premium status: $e');
    }
  }

  /// Create a Stripe PaymentIntent via the Stripe API.
  ///
  /// NOTE: In production, this call MUST happen on a backend server
  /// (e.g. Firebase Cloud Function) to keep the secret key secure.
  /// Using it client-side here is acceptable only for Stripe **test mode**.
  Future<Map<String, dynamic>> _createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${AppSecrets.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'amount=$amount&currency=$currency&payment_method_types[]=card',
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'Stripe error: ${response.statusCode} ${response.body}',
        );
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create payment intent: $e');
    }
  }

  /// Launch Stripe Payment Sheet and process the payment.
  /// Returns the PaymentIntent ID on success.
  Future<String> processPayment(String productId) async {
    final amount = _priceInCents[productId];
    if (amount == null) {
      throw const ServerException('Unknown product');
    }

    // 1. Create PaymentIntent
    final paymentIntent = await _createPaymentIntent(
      amount: amount,
      currency: 'usd',
    );
    final clientSecret = paymentIntent['client_secret'] as String;
    final paymentIntentId = paymentIntent['id'] as String;

    // 2. Initialize the Payment Sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Weather Premium',
      ),
    );

    // 3. Present the Payment Sheet (throws on cancel)
    await Stripe.instance.presentPaymentSheet();

    return paymentIntentId;
  }

  /// Activate premium in Firestore after successful Stripe payment.
  Future<SubscriptionModel> activatePremium({
    required String userId,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final isYearly = productId == _premiumYearlyId;
      final expiresAt = DateTime.now().add(
        isYearly ? const Duration(days: 365) : const Duration(days: 30),
      );

      final model = SubscriptionModel(
        userId: userId,
        isPremium: true,
        expiresAt: expiresAt,
        productId: productId,
        purchaseToken: purchaseToken,
      );

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .set(model.toJson());

      return model;
    } catch (e) {
      throw ServerException('Failed to activate premium: $e');
    }
  }

  /// Restore purchases by re-checking Firestore status.
  Future<SubscriptionModel> restorePurchases(String userId) async {
    return checkPremiumStatus(userId);
  }

  /// Return locally defined products (no store query needed).
  List<ProductInfo> getAvailableProducts() {
    return _products;
  }

  void dispose() {
    // No streams to cancel with Stripe.
  }
}

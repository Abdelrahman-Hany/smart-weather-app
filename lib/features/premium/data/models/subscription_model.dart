import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.userId,
    required super.isPremium,
    super.expiresAt,
    super.productId,
    super.purchaseToken,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      userId: json['userId'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int)
          : null,
      productId: json['productId'] as String?,
      purchaseToken: json['purchaseToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isPremium': isPremium,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'productId': productId,
      'purchaseToken': purchaseToken,
    };
  }

  factory SubscriptionModel.free(String userId) {
    return SubscriptionModel(userId: userId, isPremium: false);
  }
}

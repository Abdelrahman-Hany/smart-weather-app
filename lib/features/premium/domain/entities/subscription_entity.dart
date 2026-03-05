class SubscriptionEntity {
  final String userId;
  final bool isPremium;
  final DateTime? expiresAt;
  final String? productId;
  final String? purchaseToken;

  const SubscriptionEntity({
    required this.userId,
    required this.isPremium,
    this.expiresAt,
    this.productId,
    this.purchaseToken,
  });

  bool get isExpired {
    if (expiresAt == null) return !isPremium;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => isPremium && !isExpired;
}

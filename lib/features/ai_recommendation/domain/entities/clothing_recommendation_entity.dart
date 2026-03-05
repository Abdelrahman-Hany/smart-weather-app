/// Represents a single clothing item recommendation.
class ClothingItem {
  final String name;
  final String category;
  final String reason;
  final String? imageSearchQuery;

  const ClothingItem({
    required this.name,
    required this.category,
    required this.reason,
    this.imageSearchQuery,
  });
}

/// Represents a shopping link for a recommended item.
class ShoppingLink {
  final String storeName;
  final String url;
  final String? price;

  const ShoppingLink({required this.storeName, required this.url, this.price});
}

/// Full recommendation from AI for current weather conditions.
class ClothingRecommendationEntity {
  final String summary;
  final List<ClothingItem> items;
  final List<String> tips;
  final Map<String, List<ShoppingLink>> shoppingLinks;

  const ClothingRecommendationEntity({
    required this.summary,
    required this.items,
    this.tips = const [],
    this.shoppingLinks = const {},
  });
}

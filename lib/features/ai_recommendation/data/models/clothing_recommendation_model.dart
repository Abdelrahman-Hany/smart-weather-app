import 'dart:convert';

import '../../domain/entities/clothing_recommendation_entity.dart';

class ClothingRecommendationModel extends ClothingRecommendationEntity {
  const ClothingRecommendationModel({
    required super.summary,
    required super.items,
    super.tips,
    super.shoppingLinks,
  });

  /// Parse the structured JSON response from Gemini.
  factory ClothingRecommendationModel.fromGeminiResponse(String response) {
    try {
      // Extract JSON from response (Gemini may wrap it in markdown code blocks)
      String jsonStr = response;
      final jsonMatch = RegExp(
        r'```json\s*([\s\S]*?)\s*```',
      ).firstMatch(response);
      if (jsonMatch != null) {
        jsonStr = jsonMatch.group(1)!;
      } else {
        // Try to find raw JSON
        final startIdx = response.indexOf('{');
        final endIdx = response.lastIndexOf('}');
        if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
          jsonStr = response.substring(startIdx, endIdx + 1);
        }
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final summary =
          json['summary'] as String? ?? 'Weather-based outfit recommendation';

      final itemsList =
          (json['items'] as List<dynamic>?)?.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return ClothingItem(
              name: itemMap['name'] as String? ?? 'Clothing item',
              category: itemMap['category'] as String? ?? 'General',
              reason: itemMap['reason'] as String? ?? '',
              imageSearchQuery: itemMap['searchQuery'] as String?,
            );
          }).toList() ??
          [];

      final tips =
          (json['tips'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
          [];

      // Generate shopping links from items
      final shoppingLinks = <String, List<ShoppingLink>>{};
      for (final item in itemsList) {
        final query = Uri.encodeComponent(item.imageSearchQuery ?? item.name);
        shoppingLinks[item.name] = [
          ShoppingLink(
            storeName: 'Amazon',
            url: 'https://www.amazon.com/s?k=$query',
          ),
          ShoppingLink(
            storeName: 'Google Shopping',
            url: 'https://www.google.com/search?tbm=shop&q=$query',
          ),
          ShoppingLink(
            storeName: 'ASOS',
            url: 'https://www.asos.com/search/?q=$query',
          ),
          ShoppingLink(
            storeName: 'Zara',
            url: 'https://www.zara.com/us/en/search?searchTerm=$query',
          ),
        ];
      }

      return ClothingRecommendationModel(
        summary: summary,
        items: itemsList,
        tips: tips,
        shoppingLinks: shoppingLinks,
      );
    } catch (e) {
      // Fallback: treat the entire response as a summary
      return ClothingRecommendationModel(
        summary: response,
        items: const [],
        tips: const [],
        shoppingLinks: const {},
      );
    }
  }
}

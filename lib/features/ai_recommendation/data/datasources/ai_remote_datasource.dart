import 'package:google_generative_ai/google_generative_ai.dart' hide ServerException;

import '../../../../core/error/exceptions.dart';
import '../../../../core/secrets/app_secrets.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../models/clothing_recommendation_model.dart';

/// Communicates with Gemini AI to generate clothing recommendations.
class AiRemoteDataSource {
  late final GenerativeModel _model;

  AiRemoteDataSource() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: AppSecrets.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<ClothingRecommendationModel> getRecommendations({
    required WeatherEntity weather,
  }) async {
    try {
      final prompt = _buildPrompt(weather);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw const ServerException('AI returned an empty response');
      }

      return ClothingRecommendationModel.fromGeminiResponse(text);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('AI recommendation failed: ${e.toString()}');
    }
  }

  String _buildPrompt(WeatherEntity weather) {
    return '''
You are a professional fashion advisor and weather expert. Based on the following weather conditions, recommend appropriate clothing items.

**Current Weather:**
- Location: ${weather.cityName}, ${weather.country}
- Temperature: ${weather.temperature.round()}°C (Feels like: ${weather.feelsLike.round()}°C)
- Condition: ${weather.mainCondition} - ${weather.description}
- Humidity: ${weather.humidity}%
- Wind Speed: ${weather.windSpeed} m/s
- Visibility: ${(weather.visibility / 1000).toStringAsFixed(1)} km
- Cloudiness: ${weather.clouds}%

**Instructions:**
1. Recommend 4-6 clothing items suitable for these conditions
2. Consider layering if temperature varies significantly from feels-like
3. Account for rain/snow/wind protection if needed
4. Provide practical, purchasable items (not abstract concepts)
5. Include a search query for each item that would work well on shopping sites

**Respond in this exact JSON format:**
{
  "summary": "Brief 1-2 sentence summary of what to wear today",
  "items": [
    {
      "name": "Item name (e.g., Waterproof Rain Jacket)",
      "category": "Category (Outerwear/Top/Bottom/Footwear/Accessory)",
      "reason": "Why this item is needed for the current weather",
      "searchQuery": "Shopping search query for this specific item"
    }
  ],
  "tips": [
    "Additional weather-specific tip 1",
    "Additional weather-specific tip 2"
  ]
}
''';
  }
}

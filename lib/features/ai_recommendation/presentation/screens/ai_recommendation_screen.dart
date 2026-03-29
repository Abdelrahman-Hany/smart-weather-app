import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../../domain/entities/clothing_recommendation_entity.dart';
import '../cubit/ai_recommendation_cubit.dart';
import '../cubit/ai_recommendation_state.dart';

/// Expects `AiRecommendationCubit` to be provided above in the widget tree.
class AiRecommendationScreen extends StatelessWidget {
  final WeatherEntity weather;

  const AiRecommendationScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiOutfitAdvisor),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<AiRecommendationCubit>()
                .getRecommendations(weather),
            tooltip: l10n.regenerate,
          ),
        ],
      ),
      body: BlocBuilder<AiRecommendationCubit, AiRecommendationState>(
        builder: (context, state) {
          switch (state.status) {
            case AiRecommendationStatus.initial:
            case AiRecommendationStatus.loading:
              return _buildLoading(context);
            case AiRecommendationStatus.loaded:
              return _buildLoaded(context, state.recommendation!);
            case AiRecommendationStatus.error:
              return _buildError(
                context,
                state.errorMessage ?? l10n.unknownError,
              );
          }
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather summary card
          _buildWeatherSummary(context),
          const SizedBox(height: 24),

          // AI thinking indicator
          Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.aiAnalyzingWeather,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.preparingRecommendations,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Shimmer placeholders
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    ClothingRecommendationEntity recommendation,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather summary
          _buildWeatherSummary(context),
          const SizedBox(height: 20),

          // AI Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.5),
                  colorScheme.secondaryContainer.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.summary,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Clothing items
          Text(
            context.l10n.recommendedOutfit,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...recommendation.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildClothingCard(context, item, recommendation),
            ),
          ),

          // Tips
          if (recommendation.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.weatherTips,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recommendation.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildClothingCard(
    BuildContext context,
    ClothingItem item,
    ClothingRecommendationEntity recommendation,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final links = recommendation.shoppingLinks[item.name] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      item.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: _getCategoryColor(item.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // Shopping links
            if (links.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                context.l10n.shopThisItem,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: links.map((link) {
                  return ActionChip(
                    avatar: Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      link.storeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                      ),
                    ),
                    backgroundColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    side: BorderSide.none,
                    onPressed: () => _launchUrl(link.url),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.thermostat, color: colorScheme.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.round()}°C in ${weather.cityName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  context.l10n.weatherSummaryDetails(
                    weather.description,
                    weather.feelsLike.round(),
                    weather.windSpeed,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.oopsSomethingWrong,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context
                  .read<AiRecommendationCubit>()
                  .getRecommendations(weather),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'outerwear':
        return Icons.checkroom;
      case 'top':
        return Icons.dry_cleaning;
      case 'bottom':
        return Icons.straighten;
      case 'footwear':
        return Icons.ice_skating;
      case 'accessory':
        return Icons.watch;
      default:
        return Icons.checkroom;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'outerwear':
        return Colors.blue;
      case 'top':
        return Colors.teal;
      case 'bottom':
        return Colors.indigo;
      case 'footwear':
        return Colors.brown;
      case 'accessory':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

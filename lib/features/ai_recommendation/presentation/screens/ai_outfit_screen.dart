import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../dependency_injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../premium/presentation/cubit/premium_cubit.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../cubit/ai_recommendation_cubit.dart';
import '../widgets/premium_gate_widget.dart';
import 'ai_recommendation_screen.dart';

/// The main entry point for the AI feature.
/// Wraps with a premium gate — only premium users see recommendations.
class AiOutfitScreen extends StatelessWidget {
  final WeatherEntity weather;

  const AiOutfitScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final premiumState = context.watch<PremiumCubit>().state;

    final hasAccess = authState.isFullAccount && premiumState.isPremium;

    if (!hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.aiOutfitAdvisor),
          backgroundColor: Colors.transparent,
        ),
        body: const PremiumGate(child: SizedBox.shrink()),
      );
    }

    // Premium user — show the actual recommendation screen
    return BlocProvider(
      create: (_) => sl<AiRecommendationCubit>()..getRecommendations(weather),
      child: _RecommendationScaffold(weather: weather),
    );
  }
}

class _RecommendationScaffold extends StatelessWidget {
  final WeatherEntity weather;
  const _RecommendationScaffold({required this.weather});

  @override
  Widget build(BuildContext context) {
    return AiRecommendationScreen(weather: weather);
  }
}

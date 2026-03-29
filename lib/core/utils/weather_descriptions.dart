import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// Pure helper functions for human-readable weather descriptions.
///
/// Used by the home screen to summarise detail-card values.
class WeatherDescriptions {
  const WeatherDescriptions._();

  static String humidityLabel(BuildContext context, int humidity) {
    final l10n = context.l10n;
    if (humidity < 30) return l10n.humidityLow;
    if (humidity < 60) return l10n.humidityComfortable;
    if (humidity < 80) return l10n.humidityHumid;
    return l10n.humidityVeryHumid;
  }

  static String visibilityLabel(BuildContext context, int visibility) {
    final l10n = context.l10n;
    if (visibility >= 10000) return l10n.visibilityClear;
    if (visibility >= 5000) return l10n.visibilityModerate;
    if (visibility >= 1000) return l10n.visibilityLow;
    return l10n.visibilityVeryLow;
  }

  static String cloudLabel(BuildContext context, int clouds) {
    final l10n = context.l10n;
    if (clouds < 20) return l10n.cloudClearSky;
    if (clouds < 50) return l10n.cloudPartlyCloudy;
    if (clouds < 80) return l10n.cloudMostlyCloudy;
    return l10n.cloudOvercast;
  }

  static String feelsLikeLabel(
    BuildContext context,
    double temp,
    double feelsLike,
  ) {
    final l10n = context.l10n;
    final diff = feelsLike - temp;
    if (diff.abs() < 2) return l10n.feelsSimilar;
    if (diff > 0) return l10n.feelsWarmer;
    return l10n.feelsCooler;
  }
}

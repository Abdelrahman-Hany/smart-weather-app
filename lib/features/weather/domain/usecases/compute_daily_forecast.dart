import '../entities/forecast_entity.dart';

/// Pure domain use-case that aggregates hourly [ForecastEntity] items
/// into a list of [DailyForecast] summaries (up to 7 days).
class ComputeDailyForecast {
  List<DailyForecast> call(List<ForecastEntity> forecasts) {
    if (forecasts.isEmpty) return [];

    final Map<String, List<ForecastEntity>> grouped = {};

    for (final forecast in forecasts) {
      final key =
          '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(forecast);
    }

    return grouped.entries
        .map((entry) {
          final dayForecasts = entry.value;

          final tempMin = dayForecasts
              .map((f) => f.tempMin)
              .reduce((a, b) => a < b ? a : b);
          final tempMax = dayForecasts
              .map((f) => f.tempMax)
              .reduce((a, b) => a > b ? a : b);
          final maxPop = dayForecasts
              .map((f) => f.pop)
              .reduce((a, b) => a > b ? a : b);

          // Most frequent condition.
          final conditionCounts = <String, int>{};
          for (final f in dayForecasts) {
            conditionCounts[f.mainCondition] =
                (conditionCounts[f.mainCondition] ?? 0) + 1;
          }
          final mainCondition = conditionCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

          final representative = dayForecasts.firstWhere(
            (f) => f.mainCondition == mainCondition,
          );

          final dayIcons = dayForecasts.where((f) => f.icon.endsWith('d'));
          final nightIcons = dayForecasts.where((f) => f.icon.endsWith('n'));

          final dayIcon = dayIcons.isNotEmpty
              ? dayIcons.first.icon
              : representative.icon;
          final nightIcon = nightIcons.isNotEmpty
              ? nightIcons.first.icon
              : representative.icon.replaceAll('d', 'n');

          return DailyForecast(
            date: dayForecasts.first.dateTime,
            tempMin: tempMin,
            tempMax: tempMax,
            mainCondition: mainCondition,
            dayIcon: dayIcon,
            nightIcon: nightIcon,
            description: representative.description,
            pop: maxPop,
          );
        })
        .take(7)
        .toList();
  }
}

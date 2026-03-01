import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/forecast_entity.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ...forecasts.asMap().entries.map((entry) {
            final index = entry.key;
            final forecast = entry.value;
            return Column(
              children: [
                _DailyRow(forecast: forecast),
                if (index < forecasts.length - 1)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyForecast forecast;

  const _DailyRow({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final dayName = _getDayName(forecast.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              dayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: Colors.white.withValues(
                    alpha: forecast.pop > 0.05 ? 0.5 : 0.25,
                  ),
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${(forecast.pop * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: forecast.pop > 0.05 ? 0.6 : 0.35,
                    ),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Image.network(
            ApiConstants.weatherIcon(forecast.dayIcon, size: 2),
            width: 34,
            height: 34,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.wb_sunny, color: Color(0xFFFFD54F), size: 28),
          ),
          const SizedBox(width: 6),
          Image.network(
            ApiConstants.weatherIcon(forecast.nightIcon, size: 2),
            width: 34,
            height: 34,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.nights_stay,
              color: Color(0xFF90A4AE),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 34,
            child: Text(
              '${forecast.tempMax.round()}°',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              '${forecast.tempMin.round()}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final forecastDay = DateTime(date.year, date.month, date.day);

    if (forecastDay == today) return 'Today';
    if (forecastDay == tomorrow) return 'Tmrw';
    return DateFormat('EEE').format(date);
  }
}

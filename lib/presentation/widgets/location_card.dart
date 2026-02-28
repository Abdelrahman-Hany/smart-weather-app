import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/api_constants.dart';
import '../cubit/weather_state.dart';
import 'label_helpers.dart';

/// A card showing a saved location's info and current weather.
class LocationCard extends StatelessWidget {
  final LocationWeatherData locData;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const LocationCard({
    super.key,
    required this.locData,
    required this.isSelectMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final weather = locData.weather;
    final location = locData.location;
    final dateStr = DateFormat(
      'E, MMMM d \'at\' h:mm a',
    ).format(DateTime.now());
    final hasLabel = location.label != null && location.label!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (isSelectMode) ...[
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? const Color(0xFF4285F4)
                        : Colors.black26,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasLabel) ...[
                        Row(
                          children: [
                            Icon(
                              labelIcon(location.label!),
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.label!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        location.cityName,
                        style: TextStyle(
                          fontSize: hasLabel ? 14 : 18,
                          fontWeight: hasLabel
                              ? FontWeight.w400
                              : FontWeight.w600,
                          color: hasLabel ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.country.isNotEmpty
                            ? '${location.cityName}, ${location.country}'
                            : location.cityName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                if (weather != null) ...[
                  Image.network(
                    ApiConstants.weatherIcon(weather.icon, size: 2),
                    width: 32,
                    height: 32,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.cloud, color: Colors.grey, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weather.temperature.round()}\u00B0',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${weather.tempMax.round()}\u00B0 / ${weather.tempMin.round()}\u00B0',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ] else if (locData.status == WeatherStatus.loading) ...[
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                if (isSelectMode) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: Colors.black26,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/weather_entity.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherEntity weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // City name
          Text(
            weather.cityName,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          // Weather icon and temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                ApiConstants.weatherIcon(weather.icon),
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.cloud, size: 80, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                '${weather.temperature.round()}',
                style: textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 96,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '°C',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weather description
          Text(
            weather.description[0].toUpperCase() +
                weather.description.substring(1),
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          // High / Low
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'H: ${weather.tempMax.round()}°',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text(
                'L: ${weather.tempMin.round()}°',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Feels like ${weather.feelsLike.round()}°',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

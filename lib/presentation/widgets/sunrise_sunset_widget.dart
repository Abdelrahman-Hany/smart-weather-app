import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weather_entity.dart';

class SunriseSunsetWidget extends StatelessWidget {
  final WeatherEntity weather;

  const SunriseSunsetWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_twilight_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'SUNRISE & SUNSET',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SunTimeItem(
                icon: Icons.wb_sunny_rounded,
                label: 'Sunrise',
                time: DateFormat('HH:mm').format(weather.sunrise),
                iconColor: const Color(0xFFFFB74D),
              ),
              Container(width: 1, height: 50, color: Colors.white24),
              _SunTimeItem(
                icon: Icons.nights_stay_rounded,
                label: 'Sunset',
                time: DateFormat('HH:mm').format(weather.sunset),
                iconColor: const Color(0xFF7986CB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunTimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color iconColor;

  const _SunTimeItem({
    required this.icon,
    required this.label,
    required this.time,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

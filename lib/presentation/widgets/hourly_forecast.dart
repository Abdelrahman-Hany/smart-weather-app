import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/forecast_entity.dart';

const double _itemWidth = 80;
const double _chartHeight = 50;
// Vertical offsets inside the column: time(~16+8) + icon(36+6) + temp(~24+4) = ~94
const double _chartTopOffset = 94;

class HourlyForecastWidget extends StatelessWidget {
  final List<ForecastEntity> forecasts;
  final String? summary;

  const HourlyForecastWidget({
    super.key,
    required this.forecasts,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final temps = forecasts.map((f) => f.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final totalWidth = _itemWidth * forecasts.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary text
          if (summary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(
                summary!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Gradient divider line
          Container(
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Hourly items with continuous temperature line
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: SizedBox(
                width: totalWidth,
                child: Stack(
                  children: [
                    // The hourly columns (time, icon, temp, rain%)
                    Row(
                      children: List.generate(forecasts.length, (index) {
                        final forecast = forecasts[index];
                        final isFirst = index == 0;
                        return SizedBox(
                          width: _itemWidth,
                          child: _HourlyColumn(
                            time: isFirst
                                ? 'Now'
                                : DateFormat('h a').format(forecast.dateTime),
                            icon: forecast.icon,
                            temperature: forecast.temperature,
                            pop: forecast.pop,
                          ),
                        );
                      }),
                    ),
                    // Single continuous temperature curve overlay
                    Positioned(
                      top: _chartTopOffset,
                      left: 0,
                      right: 0,
                      height: _chartHeight,
                      child: CustomPaint(
                        painter: _ContinuousTempLinePainter(
                          temperatures: temps,
                          minTemp: minTemp,
                          maxTemp: maxTemp,
                          itemWidth: _itemWidth,
                        ),
                        size: Size(totalWidth, _chartHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          /*
          // 48-hour forecast link
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '48-hour forecast',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}

class _HourlyColumn extends StatelessWidget {
  final String time;
  final String icon;
  final double temperature;
  final double pop;

  const _HourlyColumn({
    required this.time,
    required this.icon,
    required this.temperature,
    required this.pop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time
        Text(
          time,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Weather icon
        Image.network(
          ApiConstants.weatherIcon(icon, size: 2),
          width: 36,
          height: 36,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.cloud, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        // Temperature
        Text(
          '${temperature.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Spacer for the chart area (painted by the overlay)
        const SizedBox(height: _chartHeight),
        const SizedBox(height: 8),
        // Rain probability - always shown like Google Weather
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop,
              color: Colors.white.withValues(alpha: pop > 0.1 ? 0.6 : 0.35),
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              '${(pop * 100).round()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: pop > 0.1 ? 0.7 : 0.35),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Draws a single continuous smooth curve through all temperature points.
class _ContinuousTempLinePainter extends CustomPainter {
  final List<double> temperatures;
  final double minTemp;
  final double maxTemp;
  final double itemWidth;

  _ContinuousTempLinePainter({
    required this.temperatures,
    required this.minTemp,
    required this.maxTemp,
    required this.itemWidth,
  });

  double _yForTemp(double temp, double height) {
    final range = maxTemp - minTemp;
    if (range == 0) return height / 2;
    final fraction = (temp - minTemp) / range;
    return height - (fraction * (height - 16)) - 8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (temperatures.length < 2) return;

    final linePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Build points — each point is at the center of its column
    final points = <Offset>[];
    for (int i = 0; i < temperatures.length; i++) {
      final x = (i * itemWidth) + (itemWidth / 2);
      final y = _yForTemp(temperatures[i], size.height);
      points.add(Offset(x, y));
    }

    // Draw smooth cubic bezier path through all points
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlOffset = (p1.dx - p0.dx) * 0.4;
      path.cubicTo(
        p0.dx + controlOffset,
        p0.dy,
        p1.dx - controlOffset,
        p1.dy,
        p1.dx,
        p1.dy,
      );
    }

    canvas.drawPath(path, linePaint);

    // Draw dots on top of the line
    for (final point in points) {
      canvas.drawCircle(point, 4, dotFillPaint);
      canvas.drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ContinuousTempLinePainter oldDelegate) {
    return oldDelegate.temperatures != temperatures;
  }
}

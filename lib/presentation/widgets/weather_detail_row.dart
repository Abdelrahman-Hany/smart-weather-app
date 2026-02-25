import 'package:flutter/material.dart';

class WeatherDetailRow extends StatelessWidget {
  final List<WeatherDetailItem> items;

  const WeatherDetailRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: items.map((item) => _DetailCard(item: item)).toList(),
      ),
    );
  }
}

class WeatherDetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const WeatherDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });
}

class _DetailCard extends StatelessWidget {
  final WeatherDetailItem item;

  const _DetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(item.icon, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                item.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (item.subtitle != null)
            Text(
              item.subtitle!,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

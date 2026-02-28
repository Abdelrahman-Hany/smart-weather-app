import 'package:flutter/material.dart';

/// A single action button used in selection-mode bottom bars.
class BottomBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  const BottomBarAction({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.black87 : Colors.black26;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

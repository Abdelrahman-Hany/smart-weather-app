import 'package:flutter/material.dart';

/// Preset label names mapped to their Material icons.
const Map<String, IconData> presetLabels = {
  'Home': Icons.home_outlined,
  'Office': Icons.business_outlined,
  'School': Icons.school_outlined,
};

/// Returns the icon for a [label] (preset or custom fallback).
IconData labelIcon(String label) {
  return presetLabels[label] ?? Icons.label_outline_rounded;
}

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

/// Preset label names mapped to their Material icons.
const Map<String, IconData> presetLabels = {
  'Home': Icons.home_outlined,
  'Office': Icons.business_outlined,
  'School': Icons.school_outlined,
};

/// Returns the icon for a [label] (preset or custom fallback).
IconData labelIcon(String label) {
  switch (label) {
    case 'Home':
    case 'المنزل':
      return Icons.home_outlined;
    case 'Office':
    case 'العمل':
      return Icons.business_outlined;
    case 'School':
    case 'المدرسة':
      return Icons.school_outlined;
    default:
      return Icons.label_outline_rounded;
  }
}

String localizedPresetLabel(String key, AppLocalizations l10n) {
  return l10n.localizePresetLabel(key);
}

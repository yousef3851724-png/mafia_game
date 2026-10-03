import 'package:flutter/material.dart';
import '../theme/radical_theme.dart';

/// Legacy-compatible palette.
/// رنگ‌ها به RadicalTheme نگاشت شده‌اند: noir black + metallic gold.
class AppColors {
  static const Color background = RadicalTheme.ink;
  static const Color surface = RadicalTheme.panel;
  static const Color surfaceLight = RadicalTheme.panel3;

  static const Color primaryRed = RadicalTheme.crimson;
  static const Color accentCyan = RadicalTheme.goldSoft;
  static const Color goldYellow = RadicalTheme.gold;
  static const Color medicGreen = RadicalTheme.gold;
  static const Color detectiveBlue = RadicalTheme.goldDeep;
  static const Color textMuted = RadicalTheme.smoke;
}

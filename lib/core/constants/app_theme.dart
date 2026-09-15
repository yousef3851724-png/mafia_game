import 'package:flutter/material.dart';

/// Legacy-compatible palette used by the older game screens.
/// All visual accents are intentionally normalized to the Radical palette:
/// black + metallic gold + deep purple.
class AppColors {
  static const Color background = Color(0xFF06070B);
  static const Color surface = Color(0xFF0F1219);
  static const Color surfaceLight = Color(0xFF171B25);

  // Kept under the legacy name so existing game logic/screens remain intact.
  static const Color primaryRed = Color(0xFF8E5CCB);
  static const Color accentCyan = Color(0xFFFFDFA0);
  static const Color goldYellow = Color(0xFFE3B873);
  static const Color medicGreen = Color(0xFFE3B873);
  static const Color detectiveBlue = Color(0xFF9A72D9);
  static const Color textMuted = Colors.white60;
}

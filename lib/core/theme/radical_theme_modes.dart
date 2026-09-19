import 'package:flutter/material.dart';

enum RadicalThemeMode { dark, light, noir }

class RadicalThemeProvider {
  static RadicalThemeMode _currentMode = RadicalThemeMode.dark;
  static RadicalThemeMode get currentMode => _currentMode;
  static void setThemeMode(RadicalThemeMode mode) => _currentMode = mode;

  static Color getInk() {
    switch (_currentMode) {
      case RadicalThemeMode.dark: return const Color(0xFF0A0E27);
      case RadicalThemeMode.light: return const Color(0xFFF5F5F5);
      case RadicalThemeMode.noir: return const Color(0xFF000000);
    }
  }

  static Color getPanel() {
    switch (_currentMode) {
      case RadicalThemeMode.dark: return const Color(0xFF16213E);
      case RadicalThemeMode.light: return const Color(0xFFFFFFFF);
      case RadicalThemeMode.noir: return const Color(0xFF1A1A1A);
    }
  }
}

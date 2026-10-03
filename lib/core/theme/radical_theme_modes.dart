import 'package:flutter/material.dart';
import 'radical_theme.dart';

enum RadicalThemeMode { dark, light, noir }

class RadicalThemeProvider {
  static RadicalThemeMode _currentMode = RadicalThemeMode.dark;
  static RadicalThemeMode get currentMode => _currentMode;
  static void setThemeMode(RadicalThemeMode mode) => _currentMode = mode;

  static Color getInk() => RadicalTheme.ink;
  static Color getPanel() => RadicalTheme.panel;
  static Color getPanel2() => RadicalTheme.panel2;
  static Color getGold() => RadicalTheme.gold;
  static Color getGoldBright() => RadicalTheme.goldBright;
  static Color getText() => RadicalTheme.textPrimary;
  static Color getTextMuted() => RadicalTheme.smoke;
  static Color getLine() => RadicalTheme.line;
  static Color getLineGold() => RadicalTheme.lineGold;
  static Color getBackground() => RadicalTheme.ink;
  static Color getSurface() => RadicalTheme.panel;
  static Color getAccent() => RadicalTheme.gold;
}

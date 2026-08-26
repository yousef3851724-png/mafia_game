import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color bloodRed = Color(0xFFB71C1C);
  static const Color darkGold = Color(0xFFFFD700);
  static const Color mysticPurple = Color(0xFF4A148C);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: bloodRed,
      secondary: darkGold,
      surface: surfaceDark,
      background: backgroundDark,
    ),
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: darkGold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Vazirmatn',
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkGold, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bloodRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
  );
}

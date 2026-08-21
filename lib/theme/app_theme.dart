import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFBB86FC),
    secondary: Color(0xFF03DAC6),
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 2,
  ),
);

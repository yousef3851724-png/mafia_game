import 'package:flutter/material.dart';

/// Design system for the Mafia Radical visual identity.
class RadicalTheme {
  RadicalTheme._();

  static const ink = Color(0xFF07080D);
  static const panel = Color(0xFF10131B);
  static const panel2 = Color(0xFF171B25);
  static const gold = Color(0xFFE4B96B);
  static const goldBright = Color(0xFFFFD991);
  static const crimson = Color(0xFFB92F45);
  static const crimsonBright = Color(0xFFE34B61);
  static const smoke = Color(0xFF9AA1B2);
  static const line = Color(0x20FFFFFF);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
    ).copyWith(
      primary: gold,
      onPrimary: const Color(0xFF17100A),
      secondary: crimson,
      onSecondary: Colors.white,
      surface: panel,
      onSurface: Colors.white,
      error: crimsonBright,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: line),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF0B0E15),
        indicatorColor: Color(0x25E4B96B),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: const Color(0xFF17100A),
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldBright,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0x55E4B96B)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xAAE4B96B), width: 1.4),
        ),
        labelStyle: const TextStyle(color: smoke),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: gold,
        thumbColor: goldBright,
        inactiveTrackColor: Color(0x30FFFFFF),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panel2,
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static BoxDecoration glass({bool accent = false, double radius = 22}) {
    return BoxDecoration(
      color: accent ? const Color(0xFF241B18) : panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent ? const Color(0x45E4B96B) : line),
      boxShadow: const [
        BoxShadow(color: Color(0x30000000), blurRadius: 22, offset: Offset(0, 10)),
      ],
    );
  }

  static Widget sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: smoke, fontSize: 13)),
        ],
      ],
    );
  }
}

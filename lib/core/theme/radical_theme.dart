import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared visual system for the Mafia Radical experience.
class RadicalTheme {
  RadicalTheme._();

  static const ink = Color(0xFF06070B);
  static const panel = Color(0xFF0F1219);
  static const panel2 = Color(0xFF171B25);
  static const panel3 = Color(0xFF1D2230);
  static const gold = Color(0xFFE3B873);
  static const goldBright = Color(0xFFFFDFA0);
  static const crimson = Color(0xFF9E263D);
  static const crimsonBright = Color(0xFFED4D67);
  static const violet = Color(0xFF9A72D9);
  static const smoke = Color(0xFF9CA4B5);
  static const line = Color(0x1FFFFFFF);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
    ).copyWith(
      primary: gold,
      onPrimary: const Color(0xFF17110A),
      secondary: crimson,
      onSecondary: Colors.white,
      tertiary: violet,
      surface: panel,
      surfaceContainerHighest: panel3,
      onSurface: Colors.white,
      error: crimsonBright,
      outline: line,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.7),
        headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.3),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        bodyLarge: const TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: const TextStyle(fontSize: 13, height: 1.4, color: smoke),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: line),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF090C12),
        indicatorColor: Color(0x28E3B873),
        height: 72,
        elevation: 12,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: const Color(0xFF17110A),
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldBright,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0x66E3B873)),
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
          borderSide: const BorderSide(color: Color(0xCCE3B873), width: 1.4),
        ),
        labelStyle: const TextStyle(color: smoke),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: gold,
        thumbColor: goldBright,
        inactiveTrackColor: Color(0x30FFFFFF),
        overlayColor: Color(0x18E3B873),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panel3,
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
    );
  }

  static BoxDecoration glass({bool accent = false, double radius = 22}) {
    return BoxDecoration(
      color: accent ? const Color(0xFF241C18) : panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent ? const Color(0x55E3B873) : line),
      boxShadow: const [
        BoxShadow(color: Color(0x45000000), blurRadius: 24, offset: Offset(0, 12)),
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
          Text(subtitle, style: const TextStyle(color: smoke, fontSize: 13, height: 1.35)),
        ],
      ],
    );
  }
}

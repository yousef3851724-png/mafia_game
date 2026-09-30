import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared visual system for the Mafia Radical experience.
class RadicalTheme {
  RadicalTheme._();

  static const ink = Color(0xFF07060A);
  static const panel = Color(0xFF141018);
  static const panel2 = Color(0xFF1A1520);
  static const panel3 = Color(0xFF231A2E);
  static const black = ink;
  static const charcoalLight = panel3;
  static const textPrimary = Colors.white;

  static const gold = Color(0xFFD4AF37);
  static const goldBright = Color(0xFFFFD700);
  static const goldDeep = Color(0xFF8B6914);
  static const goldSoft = Color(0xFFF0C75E);

  static const crimson = Color(0xFF8B0000);
  static const crimsonBright = Color(0xFFC41E1E);
  static const crimsonGlowColor = Color(0xFFE53935);

  static const navy = Color(0xFF1A3A5C);
  static const navyBright = Color(0xFF2C5282);

  static const violet = Color(0xFF8B5CF6);
  static const violetBright = Color(0xFFA855F7);
  static const violetSoft = Color(0xFFB98AF2);

  static const emerald = Color(0xFF10B981);
  static const cyan = Color(0xFF00E5FF);
  static const smoke = Color(0xFF9CA4B5);
  static const cream = Color(0xFFF0E6D2);
  static const line = Color(0x22FFFFFF);
  static const lineGold = Color(0x55D4AF37);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0810), Color(0xFF140C18), Color(0xFF07060A)],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldBright, gold, goldDeep],
  );

  static const LinearGradient crimsonButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [crimsonBright, crimson, Color(0xFF5A0000)],
  );

  static const LinearGradient navyButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyBright, navy, Color(0xFF0F2440)],
  );

  static const LinearGradient violetButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violetBright, violet, Color(0xFF5A2EA6)],
  );

  static List<BoxShadow> goldGlow({double blur = 24, double opacity = .32}) => [
    BoxShadow(color: gold.withValues(alpha: opacity), blurRadius: blur, spreadRadius: 1),
    BoxShadow(color: gold.withValues(alpha: opacity * .35), blurRadius: blur * 2, spreadRadius: 2),
  ];

  static List<BoxShadow> crimsonGlow({double blur = 22, double opacity = .35}) => [
    BoxShadow(color: crimsonBright.withValues(alpha: opacity), blurRadius: blur, spreadRadius: 1),
    BoxShadow(color: crimson.withValues(alpha: opacity * .4), blurRadius: blur * 2, spreadRadius: 2),
  ];

  static List<BoxShadow> violetGlow({double blur = 22, double opacity = .30}) => [
    BoxShadow(color: violet.withValues(alpha: opacity), blurRadius: blur, spreadRadius: 1),
    BoxShadow(color: violetBright.withValues(alpha: opacity * .35), blurRadius: blur * 2, spreadRadius: 2),
  ];

  static TextTheme get textTheme => dark().textTheme;

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark).copyWith(
      primary: gold,
      onPrimary: const Color(0xFF17110A),
      secondary: crimson,
      onSecondary: Colors.white,
      tertiary: violet,
      onTertiary: const Color(0xFF120A1A),
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
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.7),
        headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.3),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        bodyLarge: const TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: const TextStyle(fontSize: 13, height: 1.4, color: smoke),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      ),
      iconTheme: const IconThemeData(color: goldBright),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: goldBright,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: goldBright),
        actionsIconTheme: IconThemeData(color: goldBright),
        titleTextStyle: TextStyle(color: goldBright, fontSize: 20, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: line)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: panel3,
        surfaceTintColor: Colors.transparent,
        textStyle: const TextStyle(color: goldBright, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: lineGold)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF0A0810),
        indicatorColor: Color(0x33D4AF37),
        height: 72,
        elevation: 12,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: const Color(0xFF17110A),
          disabledBackgroundColor: panel3,
          disabledForegroundColor: smoke,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: Colors.white,
          disabledBackgroundColor: panel3,
          disabledForegroundColor: smoke,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldBright,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: lineGold, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldBright,
          minimumSize: const Size.fromHeight(46),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Color(0xFF17110A),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide(color: gold.withValues(alpha: .8), width: 1.4)),
        labelStyle: const TextStyle(color: smoke),
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

  static BoxDecoration glass({bool accent = false, double radius = 22}) => BoxDecoration(
    color: accent ? const Color(0xFF1E152A) : panel,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: accent ? lineGold : line),
    boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 12))],
  );

  static BoxDecoration glassCard({bool accent = false, double radius = 22}) => glass(accent: accent, radius: radius);

  static Widget sectionTitle(String title, {String? subtitle}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: smoke, fontSize: 12)),
      ],
    ],
  );
}

class RadicalColors {
  RadicalColors._();
  static const backgroundDark = RadicalTheme.ink;
  static const surfaceDark = RadicalTheme.panel;
  static const goldAccent = RadicalTheme.goldBright;
  static const crimsonPrimary = RadicalTheme.crimson;
}

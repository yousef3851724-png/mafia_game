import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Mafia Radical main theme: classic noir (warm black) + gold.
/// Gold = brand/primary, crimson = danger/mafia team, violet = premium only.
class RadicalTheme {
  RadicalTheme._();

  // ---- Noir surfaces (warm black, no blue tint) ----
  static const ink = Color(0xFF050507);
  static const panel = Color(0xFF0E0D12);
  static const panel2 = Color(0xFF15131A);
  static const panel3 = Color(0xFF1D1A24);
  static const black = ink;
  static const charcoalLight = panel3;

  // ---- Text ----
  static const textPrimary = Color(0xFFF5F0E6);
  static const cream = Color(0xFFF4EBD6);
  static const smoke = Color(0xFFA19A8C);

  // ---- Gold (brand) ----
  static const gold = Color(0xFFD4AF37);
  static const goldBright = Color(0xFFF5D76E);
  static const goldDeep = Color(0xFF8A6A1C);
  static const goldSoft = Color(0xFFE8C872);

  // ---- Crimson (danger / mafia) ----
  static const crimson = Color(0xFF9B1B1B);
  static const crimsonBright = Color(0xFFD32F2F);

  // ---- Violet (premium / rare only) ----
  static const violet = Color(0xFF8B5CF6);
  static const violetBright = Color(0xFFA855F7);
  static const violetSoft = Color(0xFFB98AF2);

  // ---- Support ----
  static const navy = Color(0xFF1A3A5C);
  static const navyBright = Color(0xFF2C5282);
  static const emerald = Color(0xFF10B981);
  static const cyan = Color(0xFF00E5FF);

  // ---- Team colors ----
  static const mafiaColor = crimsonBright;
  static const citizenColor = emerald;
  static const independentColor = goldBright;

  // ---- Lines ----
  static const line = Color(0x1FFFFFFF);
  static const lineGold = Color(0x55D4AF37);

  // ---- Gradients ----
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B0A0E), Color(0xFF120F14), Color(0xFF050507)],
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

  // ---- Glows ----
  static List<BoxShadow> goldGlow({double blur = 24, double opacity = .30}) => [
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
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: gold,
      onPrimary: Color(0xFF17110A),
      primaryContainer: goldDeep,
      onPrimaryContainer: goldBright,
      secondary: crimson,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF4A0000),
      onSecondaryContainer: Colors.white,
      tertiary: goldSoft,
      onTertiary: Color(0xFF17110A),
      tertiaryContainer: goldDeep,
      onTertiaryContainer: cream,
      error: crimsonBright,
      onError: Colors.white,
      errorContainer: Color(0xFF4A0000),
      onErrorContainer: Colors.white,
      surface: ink,
      onSurface: textPrimary,
      surfaceContainerLowest: ink,
      surfaceContainerLow: panel,
      surfaceContainer: panel,
      surfaceContainerHigh: panel2,
      surfaceContainerHighest: panel3,
      onSurfaceVariant: smoke,
      outline: Color(0x33D4AF37),
      outlineVariant: Color(0x22FFFFFF),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: cream,
      onInverseSurface: ink,
      inversePrimary: goldDeep,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      canvasColor: ink,
      cardColor: panel,
      dividerColor: line,
      dialogBackgroundColor: panel2,
      splashColor: Color(0x1FD4AF37),
      highlightColor: Color(0x0FD4AF37),
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: panel,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: lineGold, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: panel2,
        modalBarrierColor: Colors.black87,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: panel2,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Color(0xFF17110A),
          disabledBackgroundColor: panel3,
          disabledForegroundColor: smoke,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Color(0xFF17110A),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: BorderSide(color: lineGold, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: gold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel2,
        hintStyle: TextStyle(color: smoke),
        labelStyle: TextStyle(color: smoke),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panel2,
        selectedColor: goldDeep,
        side: BorderSide(color: line),
        labelStyle: TextStyle(color: textPrimary),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: gold,
        unselectedLabelColor: smoke,
        indicatorColor: gold,
        dividerColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: panel3,
        circularTrackColor: panel3,
      ),
      dividerTheme: DividerThemeData(
        color: line,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ink,
        selectedItemColor: gold,
        unselectedItemColor: smoke,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ink,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Color(0x59B8860B),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: gold),
        ),
      ),
      iconTheme: IconThemeData(color: goldBright),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: base.textTheme
          .apply(bodyColor: textPrimary, displayColor: textPrimary)
          .copyWith(
            headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.7, color: textPrimary),
            headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.3, color: textPrimary),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
            bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: textPrimary),
            bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: smoke),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
    );
  }


  static BoxDecoration glass({bool accent = false, double radius = 22}) => BoxDecoration(
    color: accent ? const Color(0xFF1A150C) : panel,
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

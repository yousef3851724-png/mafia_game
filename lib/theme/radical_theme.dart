cat > lib/theme/radical_theme.dart << 'EOF'
import 'package:flutter/material.dart';

class RadicalTheme {
  RadicalTheme._();

  static const Color black = Color(0xFF0A0A0A);
  static const Color charcoal = Color(0xFF16161A);
  static const Color charcoalLight = Color(0xFF222226);
  static const Color gold = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color crimson = Color(0xFFB71C1C);
  static const Color crimsonLight = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFF5F1E8);
  static const Color textSecondary = Color(0xFFB5AFA0);
  static const Color glass = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x33FFD700);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [black, charcoal, black],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, darkGold],
  );

  static const LinearGradient crimsonButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [crimsonLight, crimson],
  );

  static List<BoxShadow> goldGlow({double blur = 20, double opacity = 0.35}) => [
        BoxShadow(
          color: gold.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 1,
        ),
      ];

  static BoxDecoration glassCard({double radius = 20, Color? borderColor}) {
    return BoxDecoration(
      color: glass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? glassBorder, width: 1),
    );
  }

  static const String fontFamily = 'Vazirmatn';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: gold,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: black,
        ),
      );

  static ThemeData get themeData {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: black,
      primaryColor: gold,
      colorScheme: base.colorScheme.copyWith(
        primary: gold,
        secondary: crimson,
        surface: charcoal,
        onPrimary: black,
      ),
      textTheme: textTheme,
      fontFamily: fontFamily,
      splashColor: gold.withOpacity(0.1),
      highlightColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: black,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: gold,
        ),
      ),
    );
  }
}
EOF
echo "✅ radical_theme.dart ساخته شد"
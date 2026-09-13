import 'package:flutter/material.dart';
import 'features/home/radical_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MafiaRadicalApp());
}

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE3B873);
    const red = Color(0xFFC63C4A);
    const background = Color(0xFF07090F);
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
    ).copyWith(
      primary: gold,
      secondary: red,
      surface: const Color(0xFF111521),
      error: const Color(0xFFE25563),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مافیا رادیکال',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF111521),
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF0D1018),
          indicatorColor: Color(0x22E3B873),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Color(0xFF17100A),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111521),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: gold.withOpacity(.7), width: 1.5),
          ),
        ),
      ),
      home: const RadicalHomeScreen(),
    );
  }
}

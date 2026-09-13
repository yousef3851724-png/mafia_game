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
    const gold = Color(0xFFD4AF87);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mafia Radical',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080B12),
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
        useMaterial3: true,
        cardTheme: const CardThemeData(color: Color(0xFF111722), elevation: 0, margin: EdgeInsets.zero),
      ),
      home: const RadicalHomeScreen(),
    );
  }
}

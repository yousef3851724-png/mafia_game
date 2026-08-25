import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';

class MafiaApp extends StatelessWidget {
  const MafiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mafia Radical',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // نمایش صفحه اسپلش به عنوان صفحه اول
      home: const SplashScreen(),
    );
  }
}

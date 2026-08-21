import 'package:flutter/material.dart';
import 'core/router.dart';
import 'core/theme.dart';

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mafia Radical',
      theme: appTheme,
      routerConfig: router, // از core/router.dart
      debugShowCheckedModeBanner: false,
    );
  }
}

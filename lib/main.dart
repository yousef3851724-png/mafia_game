import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/radical_theme.dart';
import 'features/home/cinematic_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MafiaRadicalApp()));
}

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مافیا رادیکال',
      theme: RadicalTheme.dark(),
      home: const CinematicHomeScreen(),
    );
  }
}

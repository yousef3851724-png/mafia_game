import 'package:flutter/material.dart';
import 'router/app_router.dart';

class MafiaApp extends StatelessWidget {
  const MafiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mafia Radical',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

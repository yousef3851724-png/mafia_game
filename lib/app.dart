import 'package:flutter/material.dart';

class MafiaApp extends StatelessWidget {
  const MafiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mafia Radical',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Hello Mafia!')),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mafia Radical',
      home: const Scaffold(
        body: Center(
          child: Text('Mafia Radical'),
        ),
      ),
    );
  }
}

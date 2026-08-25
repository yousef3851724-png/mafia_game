import 'package:flutter/material.dart';

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
        fontFamily: 'Vazirmatn', // اگر فونت را اضافه کرده باشید
      ),
      home: const Scaffold(
        body: Center(child: Text('به بازی مافیا خوش آمدید!')),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MafiaApp extends StatelessWidget {
  const MafiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('مافیا رادیکال', style: TextStyle(fontSize: 30, color: Colors.red))),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Mafia Radical'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'به بازی مافیا خوش آمدید!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

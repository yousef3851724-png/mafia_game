import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/player_provider.dart';

class RoleRevealScreen extends ConsumerWidget {
  const RoleRevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playerProvider);

    if (players.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: Text(
            'ابتدا باید بازیکن اضافه کنید!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final randomPlayer = players.first; // فعلاً اولین بازیکن را نشان می‌دهیم

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('نقش شما'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(
              randomPlayer.name,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'شما نقش مافیا را دارید!',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
              ),
              child: const Text('باشه، فهمیدم', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

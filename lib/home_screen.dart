import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mafia Radical'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.games,
                size: 80,
                color: Color(0xFFBB86FC),
              ),
              const SizedBox(height: 24),
              const Text(
                'به مافیا رادیکال خوش آمدید!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'نسخه ${AppConstants.version}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              const Text(
                'حداقل بازیکنان: 6',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'حداکثر بازیکنان: 20',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('بخش بازی در حال توسعه است...')),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('شروع بازی'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/game_provider.dart';

class DayPhaseScreen extends ConsumerWidget {
  const DayPhaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    if (gameState.phase == GamePhase.gameOver) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              Text('برنده: ${gameState.winner}', style: const TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  ref.read(gameProvider.notifier).restartGame();
                  context.go('/setup');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('بازی جدید', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('روز است...'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('شهروندان، به چه کسی شک دارید؟', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: gameState.players.length,
                itemBuilder: (context, index) {
                  final player = gameState.players[index];
                  return Card(
                    color: Colors.grey.shade900,
                    child: ListTile(
                      title: Text(player.name, style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.gavel, color: Colors.amber),
                      onTap: () {
                        ref.read(gameProvider.notifier).resolveDay(player.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

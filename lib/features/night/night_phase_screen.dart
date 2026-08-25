import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/game_provider.dart';

class NightPhaseScreen extends ConsumerWidget {
  const NightPhaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentPlayer = gameState.players.isNotEmpty ? gameState.players.first : null;
    final isMafia = currentPlayer?.role == 'مافیا';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('شب است...'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('همه چشم‌ها را ببندید!', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: isMafia
                  ? ListView.builder(
                      itemCount: gameState.players.length,
                      itemBuilder: (context, index) {
                        final player = gameState.players[index];
                        return Card(
                          color: Colors.grey.shade900,
                          child: ListTile(
                            title: Text(player.name, style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              ref.read(gameProvider.notifier).selectMafiaVictim(player.id);
                            },
                            trailing: gameState.mafiaVictimId == player.id
                                ? const Icon(Icons.gavel, color: Colors.red)
                                : null,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('شما مافیا نیستید، منتظر بمانید...', style: TextStyle(color: Colors.grey)),
                    ),
            ),
            if (isMafia)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gameState.mafiaVictimId != null ? () {
                    ref.read(gameProvider.notifier).resolveNight();
                    context.go('/day');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('تایید قتل', style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_theme.dart';
import '../../game/widgets/player_with_frame.dart';

class LobbyRealtimeScreen extends ConsumerWidget {
  final String lobbyId;

  const LobbyRealtimeScreen({
    super.key,
    required this.lobbyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: RadicalTheme.background,
      appBar: AppBar(
        title: const Text('لابی'),
        backgroundColor: RadicalTheme.panel,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: RadicalTheme.panel.withValues(alpha: 0.8),
              border: Border.all(color: RadicalTheme.line),
            ),
            child: PlayerWithFrame(
              playerName: 'کھلاڑی ${index + 1}',
              avatar: Container(
                color: RadicalTheme.gold.withValues(alpha: 0.2),
              ),
              size: 60,
            ),
          );
        },
      ),
    );
  }
}

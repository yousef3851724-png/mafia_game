import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/widgets/player_with_frame.dart';
import '../../../core/theme/radical_theme.dart';

// ... (existing imports)

class _PlayerTile extends ConsumerWidget {
  final dynamic player;
  final bool isMe;
  final bool canKick;
  final VoidCallback onKick;

  const _PlayerTile({
    required this.player,
    required this.isMe,
    required this.canKick,
    required this.onKick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? RadicalTheme.gold.withOpacity(0.1) : RadicalTheme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? RadicalTheme.gold : RadicalTheme.line,
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          PlayerWithFrame(
            playerName: player.name,
            avatar: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RadicalTheme.ink.withOpacity(0.2),
              ),
              child: const Icon(Icons.person, size: 24),
            ),
            size: 60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('صندلی ${player.seat + 1}', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
              ],
            ),
          ),
          if (player.ready)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const Icon(Icons.hourglass_empty, color: RadicalTheme.smoke),
          if (canKick) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onKick,
            ),
          ],
        ],
      ),
    );
  }
}

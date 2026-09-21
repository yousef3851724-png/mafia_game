import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/radical_theme.dart';
import '../../widgets/player_with_frame.dart';

class PlayerAvatarCard extends ConsumerWidget {
  final dynamic player;
  final bool isSelected;
  final VoidCallback onTap;

  const PlayerAvatarCard({super.key, required this.player, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? RadicalTheme.gold.withValues(alpha: 0.15) : RadicalTheme.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? RadicalTheme.gold : RadicalTheme.line, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerWithFrame(
              playerName: player.name ?? 'بازیکن',
              avatar: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.ink.withValues(alpha: 0.2)),
                child: const Icon(Icons.person, size: 30),
              ),
              size: 80,
            ),
          ],
        ),
      ),
    );
  }
}

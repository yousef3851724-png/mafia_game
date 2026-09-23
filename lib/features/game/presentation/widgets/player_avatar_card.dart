import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/radical_theme.dart';
import '../../../store/widgets/equipped_frame_display.dart';

class PlayerAvatarCard extends ConsumerWidget {
  final String playerName;
  final String? avatarId;
  final bool isCurrentPlayer;

  const PlayerAvatarCard({
    super.key,
    required this.playerName,
    this.avatarId,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isCurrentPlayer 
          ? RadicalTheme.gold.withValues(alpha: 0.1)
          : RadicalTheme.panel,
        border: Border.all(
          color: isCurrentPlayer ? RadicalTheme.gold : RadicalTheme.line,
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EquippedFrameDisplay(size: 60, showLabel: false),
          const SizedBox(height: 8),
          Text(
            playerName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

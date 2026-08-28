import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../../../core/widgets/avatar_frame_widget.dart';

class PlayerAvatarCard extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final FrameType frameType;
  final VoidCallback onTap;

  const PlayerAvatarCard({
    super.key,
    required this.player,
    required this.isSelected,
    this.frameType = FrameType.fire, // مقدار تستی برای نمایش فریم
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: player.isAlive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: player.isAlive
              ? (isSelected ? theme.colorScheme.primary.withOpacity(0.25) : const Color(0xFF1E1E1E))
              : Colors.black38,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white10,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ویجت ماژولار آواتار + فریم
            AvatarFrameWidget(
              fallbackInitial: player.name,
              frameType: player.isAlive ? frameType : FrameType.none,
              isAlive: player.isAlive,
              size: 56,
            ),
            const SizedBox(height: 8),
            Text(
              player.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: player.isAlive ? Colors.white : Colors.grey,
                decoration: player.isAlive ? null : TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              player.role,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

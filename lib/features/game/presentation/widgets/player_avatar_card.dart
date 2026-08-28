import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';

class PlayerAvatarCard extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final VoidCallback onTap;

  const PlayerAvatarCard({
    super.key,
    required this.player,
    required this.isSelected,
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
              ? (isSelected ? theme.colorScheme.primary.withOpacity(0.2) : const Color(0xFF1E1E1E))
              : Colors.black45,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white12,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: player.isAlive ? Colors.redAccent.shade700 : Colors.grey.shade800,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0] : '?',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                if (!player.isAlive)
                  const Icon(Icons.close, color: Colors.red, size: 40),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              player.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: player.isAlive ? Colors.white : Colors.grey,
                decoration: player.isAlive ? null : TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              player.role,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

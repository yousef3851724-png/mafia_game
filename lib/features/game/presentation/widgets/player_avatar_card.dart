import 'package:flutter/material.dart';

import '../../domain/entities/player.dart';
import '../../../../core/widgets/avatar_frame_widget.dart';

class PlayerAvatarCard extends StatelessWidget {
  final SessionPlayer player;
  final bool isSelected;
  final FrameType frameType;
  final VoidCallback onTap;

  const PlayerAvatarCard({
    super.key,
    required this.player,
    required this.isSelected,
    this.frameType = FrameType.fire,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.18)
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarFrameWidget(
              fallbackInitial: player.name,
              frameType: frameType,
              size: 56,
            ),
            const SizedBox(height: 8),
            Text(
              player.name.isEmpty ? 'بازیکن' : player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            if (player.isHost)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThreeDimensionalHostStar(size: 15),
                  SizedBox(width: 4),
                  Text('میزبان', style: TextStyle(color: Colors.amber, fontSize: 11)),
                ],
              )
            else if (player.vote != null)
              Text(
                'رأی ثبت شده',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A small layered star with highlight, extrusion and glow instead of a flat
/// Material star icon. It is intentionally kept self-contained so the host
/// badge remains visually consistent wherever PlayerAvatarCard is reused.
class _ThreeDimensionalHostStar extends StatelessWidget {
  final double size;

  const _ThreeDimensionalHostStar({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 1,
            top: 2,
            child: Icon(
              Icons.star_rounded,
              size: size,
              color: const Color(0xFF7A4B00),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(.45),
                    blurRadius: 5,
                    spreadRadius: .4,
                  ),
                ],
              ),
              child: Icon(
                Icons.star_rounded,
                size: size,
                color: const Color(0xFFFFD54F),
              ),
            ),
          ),
          Positioned(
            left: size * .22,
            top: size * .16,
            child: Icon(
              Icons.star_rounded,
              size: size * .34,
              color: const Color(0xFFFFF3B0),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_theme.dart';
import '../../store/controllers/frame_ownership_controller.dart';

class PlayerWithFrame extends ConsumerWidget {
  final String playerName;
  final Widget avatar;
  final double size;

  const PlayerWithFrame({
    super.key,
    required this.playerName,
    required this.avatar,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownership = ref.watch(frameOwnershipProvider);
    final tier = ownership.equippedFrame;

    final hasFrame = tier.index > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: hasFrame ? Color(tier.color) : RadicalTheme.line,
              width: hasFrame ? 3 : 1,
            ),
            boxShadow: hasFrame
                ? [
                    BoxShadow(
                      color: Color(tier.color).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]
                : null,
          ),
          child: avatar,
        ),
        const SizedBox(height: 8),
        Text(
          playerName,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

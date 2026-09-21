import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../../core/theme/radical_theme.dart';
import '../controllers/frame_ownership_controller.dart';

class EquippedFrameDisplay extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const EquippedFrameDisplay({
    super.key,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownership = ref.watch(frameOwnershipProvider);
    final tier = ownership.equippedFrame;

    if (tier == RadicalFrameTier.none || tier.index == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RadicalTheme.ink.withOpacity(0.2),
              border: Border.all(color: RadicalTheme.line, width: 1),
            ),
            child: const Icon(Icons.frame_outlined),
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            const Text('فریم نہیں', style: TextStyle(color: RadicalTheme.smoke)),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(tier.color), width: 2),
            boxShadow: [
              BoxShadow(
                color: Color(tier.color).withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Center(
            child: Text(
              tier.displayName.isNotEmpty ? tier.displayName[0] : '?',
              style: TextStyle(
                fontSize: size * 0.4,
                color: Color(tier.color),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            tier.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

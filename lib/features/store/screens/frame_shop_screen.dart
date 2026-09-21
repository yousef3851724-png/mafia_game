import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../../core/theme/radical_theme.dart';
import '../controllers/frame_ownership_controller.dart';

class FrameShopScreen extends ConsumerStatefulWidget {
  const FrameShopScreen({super.key});

  @override
  ConsumerState<FrameShopScreen> createState() => _FrameShopScreenState();
}

class _FrameShopScreenState extends ConsumerState<FrameShopScreen> {
  @override
  Widget build(BuildContext context) {
    final ownership = ref.watch(frameOwnershipProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final tier = RadicalFrameTier.values[index];
        final isOwned = ownership.ownedFrames.contains(tier);
        final isEquipped = ownership.equippedFrame == tier;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(tier.color), width: 2),
            color: RadicalTheme.panel,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tier.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: isOwned ? () => _equipFrame(tier) : () => _purchaseFrame(tier),
                child: Text(isOwned ? 'تجهیز' : 'خرید'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _purchaseFrame(RadicalFrameTier tier) {
    ref.read(frameOwnershipProvider.notifier).purchaseFrameWithDiamonds(tier);
  }

  void _equipFrame(RadicalFrameTier tier) {
    ref.read(frameOwnershipProvider.notifier).equipFrame(tier);
  }
}
EO

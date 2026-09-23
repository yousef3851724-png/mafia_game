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

        return GestureDetector(
          onTap: isOwned 
            ? () => _equipFrame(tier)
            : () => _purchaseFrame(tier),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEquipped ? Color(tier.color) : RadicalTheme.line,
                width: isEquipped ? 3 : 1,
              ),
              color: RadicalTheme.panel,
              boxShadow: isEquipped
                  ? [
                      BoxShadow(
                        color: Color(tier.color).withValues(alpha: 0.5),
                        blurRadius: 20,
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(tier.color), width: 2),
                    color: Color(tier.color).withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      tier.displayName.isNotEmpty ? tier.displayName[0] : '?',
                      style: TextStyle(
                        fontSize: 28,
                        color: Color(tier.color),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tier.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (!isOwned)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${tier.diamondPrice}💎',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: RadicalTheme.gold,
                      ),
                    ),
                  )
                else if (isEquipped)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'تجهیز شده',
                      style: TextStyle(
                        color: RadicalTheme.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'خریداری شده',
                      style: TextStyle(
                        color: RadicalTheme.smoke,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
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

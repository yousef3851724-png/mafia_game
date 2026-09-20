import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../../core/theme/radical_theme.dart';
import '../../../core/widgets/radical_scaffold.dart';
import '../controllers/frame_ownership_controller.dart';
import '../providers/frame_store_providers.dart';

class FrameShopScreen extends ConsumerStatefulWidget {
  const FrameShopScreen({super.key});

  @override
  ConsumerState<FrameShopScreen> createState() => _FrameShopScreenState();
}

class _FrameShopScreenState extends ConsumerState<FrameShopScreen> {
  @override
  Widget build(BuildContext context) {
    final ownership = ref.watch(frameOwnershipProvider);
    final available = ref.watch(availableFramesProvider);
    final spending = ref.watch(frameSpendingProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RadicalTheme.ink.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: RadicalTheme.gold, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'خریدهای شما',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: RadicalTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${ownership.ownedFrames.length - 1} فریم خریداری شده',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'مجموع: $spending 💎',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RadicalTheme.crimson,
                  ),
                ),
              ],
            ),
          ),
          if (ownership.equippedFrame != RadicalFrameTier.none)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فریم فعال',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: RadicalTheme.gold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFrameCard(context, ref, ownership.equippedFrame, true),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'فریم‌های دردسترس',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: RadicalTheme.gold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...available.map((tier) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildFrameCard(context, ref, tier, false),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFrameCard(BuildContext context, WidgetRef ref, RadicalFrameTier tier, bool isEquipped) {
    final ownership = ref.watch(frameOwnershipProvider);
    final isOwned = ownership.ownedFrames.contains(tier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RadicalTheme.ink.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquipped ? RadicalTheme.gold : Color(tier.color),
          width: isEquipped ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(tier.color).withOpacity(0.1),
              border: Border.all(color: Color(tier.color), width: 2),
            ),
            child: Center(
              child: Text(
                tier.displayName[0],
                style: TextStyle(
                  color: Color(tier.color),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Color(tier.color),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(tier.description),
                if (!isOwned)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('${tier.diamondPrice} 💎'),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isOwned)
            isEquipped
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RadicalTheme.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('فعال'),
              )
              : ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(frameOwnershipProvider.notifier).equipFrame(tier);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${tier.name} فعال شد!')),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('تجهیز'),
              )
          else
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(frameOwnershipProvider.notifier).purchaseFrame(tier);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${tier.name} خریداری شد!')),
                  );
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('خرید'),
            ),
        ],
      ),
    );
  }
}

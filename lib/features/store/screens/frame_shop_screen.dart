import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../../core/theme/radical_theme.dart';
import '../../../core/widgets/radical_avatar_frame.dart';
import '../../../core/theme/frame_catalog.dart';
import '../controllers/frame_ownership_controller.dart';

class FrameShopScreen extends ConsumerWidget {
  const FrameShopScreen({super.key});

  RadicalFrameTier _toCat(RadicalFrameTier t) {
    switch (t.tierIndex) {
      case 1:
        return RadicalFrameTier.bronze;
      case 2:
        return RadicalFrameTier.silver;
      case 3:
        return RadicalFrameTier.gold;
      case 4:
        return RadicalFrameTier.platinum;
      case 5:
        return RadicalFrameTier.diamond;
      case 6:
        return RadicalFrameTier.legendary;
      default:
        return RadicalFrameTier.none;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownership = ref.watch(frameOwnershipProvider);
    final wallet = ref.watch(walletProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _chip(Icons.diamond, Colors.cyanAccent, '${wallet.diamonds}'),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: FrameCatalogPng.all.length,
            itemBuilder: (context, i) {
              final frame = FrameCatalogPng.all[i];
              final tier = frame.tier;
              final ct = _toCat(tier);
              final data = RadicalFrameData.of(ct);
              final owned = ownership.ownedFrames.contains(tier);
              final equipped = ownership.equippedFrame == tier;
              final price = frame.price;
              final ownerOnly = frame.ownerOnly;
              // تمام قاب‌ها، از معمولی تا Legendary، فقط با الماس خریداری می‌شوند.
              const usesDiamonds = true;

              return GestureDetector(
                onTap: () => _onTap(
                  context, ref, tier, owned, price, ownerOnly,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: RadicalTheme.panel,
                    border: Border.all(
                      color: equipped
                          ? data.gradientColors.first
                          : RadicalTheme.line,
                      width: equipped ? 3 : 1,
                    ),
                    boxShadow: equipped
                        ? [BoxShadow(color: data.glowColor, blurRadius: 20)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RadicalAvatarFrame(
                        avatarAssetPath: 'assets/logo/radical_face_only.png',
                        tier: ct,
                        size: 72,
                        showBadge: false,
                        framePath: frame.assetPath,
                      ),
                      const SizedBox(height: 10),
                      Text(frame.nameFa,
                          style: RadicalTheme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      if (ownerOnly && !owned)
                        const Text('اختصاصی مالک بازی 🔒',
                            style: TextStyle(color: Colors.orangeAccent))
                      else if (equipped)
                        const Text('تجهیز شده',
                            style: TextStyle(color: RadicalTheme.gold))
                      else if (owned)
                        const Text('خریداری شده',
                            style: TextStyle(color: Colors.white54))
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              usesDiamonds
                                  ? Icons.diamond
                                  : Icons.monetization_on,
                              size: 16,
                              color: usesDiamonds
                                  ? Colors.cyanAccent
                                  : RadicalTheme.gold,
                            ),
                            const SizedBox(width: 4),
                            Text('$price',
                                style: RadicalTheme.textTheme.bodyMedium),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, Color color, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: RadicalTheme.glassCard(radius: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(text, style: RadicalTheme.textTheme.bodyMedium),
          ],
        ),
      );

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    RadicalFrameTier tier,
    bool owned,
    int price,
    bool ownerOnly,
  ) async {
    final ctrl = ref.read(frameOwnershipProvider.notifier);
    if (ownerOnly && !owned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این قاب اختصاصی مالک بازی است و از فروشگاه قابل خرید نیست.')),
      );
      return;
    }
    if (owned) {
      await ctrl.equipFrame(tier);
      return;
    }
    final ok = await ctrl.buyWithWallet(
      tier,
      price,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الماس کافی نیست',
          ),
        ),
      );
    }
  }
}

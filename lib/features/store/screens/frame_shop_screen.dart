import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/radical_avatar_catalog.dart' as cat;
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/radical_frame_tier.dart';
import '../../../core/theme/radical_theme.dart';
import '../../../core/widgets/radical_avatar_frame.dart';
import '../controllers/frame_ownership_controller.dart';

class FrameShopScreen extends ConsumerWidget {
  const FrameShopScreen({super.key});

  cat.RadicalFrameTier _toCat(RadicalFrameTier t) {
    switch (t.tierIndex) {
      case 1:
        return cat.RadicalFrameTier.bronze;
      case 2:
        return cat.RadicalFrameTier.silver;
      case 3:
        return cat.RadicalFrameTier.gold;
      case 4:
        return cat.RadicalFrameTier.platinum;
      case 5:
        return cat.RadicalFrameTier.diamond;
      case 6:
        return cat.RadicalFrameTier.legendary;
      default:
        return cat.RadicalFrameTier.none;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownership = ref.watch(frameOwnershipProvider);
    final wallet = ref.watch(walletProvider);
    final tiers =
        RadicalFrameTier.values.where((t) => t.tierIndex > 0).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _chip(Icons.monetization_on, RadicalTheme.gold, '${wallet.coins}'),
              const SizedBox(width: 8),
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
            itemCount: tiers.length,
            itemBuilder: (context, i) {
              final tier = tiers[i];
              final ct = _toCat(tier);
              final data = cat.RadicalFrameData.of(ct);
              final owned = ownership.ownedFrames.contains(tier);
              final equipped = ownership.equippedFrame == tier;
              final price = data.diamondCost;

              return GestureDetector(
                onTap: () => _onTap(context, ref, tier, owned, price),
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
                      ),
                      const SizedBox(height: 10),
                      Text(data.displayNameFa,
                          style: RadicalTheme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      if (equipped)
                        const Text('تجهیز شده',
                            style: TextStyle(color: RadicalTheme.gold))
                      else if (owned)
                        const Text('خریداری شده',
                            style: TextStyle(color: Colors.white54))
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.diamond,
                                size: 16, color: Colors.cyanAccent),
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

  Future<void> _onTap(BuildContext context, WidgetRef ref,
      RadicalFrameTier tier, bool owned, int price) async {
    final ctrl = ref.read(frameOwnershipProvider.notifier);
    if (owned) {
      await ctrl.equipFrame(tier);
      return;
    }
    final ok = await ctrl.buyWithWallet(tier, price);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الماس کافی نیست')));
    }
  }
}
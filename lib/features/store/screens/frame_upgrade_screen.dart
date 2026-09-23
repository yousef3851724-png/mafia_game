import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_theme.dart';
import '../controllers/frame_upgrade_controller.dart';

const List<Map<String, dynamic>> upgrades = [
  {
    'id': 'glow',
    'name': 'درخشش',
    'type': 'glow',
    'cost': 50,
    'description': 'فریم کو درخشش دیں',
  },
  {
    'id': 'animation',
    'name': 'متحرک',
    'type': 'animation',
    'cost': 100,
    'description': 'فریم کو متحرک بنائیں',
  },
  {
    'id': 'rarity',
    'name': 'نادر',
    'type': 'rarity',
    'cost': 200,
    'description': 'فریم کو نادر بنائیں',
  },
  {
    'id': 'special',
    'name': 'خصوصی',
    'type': 'special',
    'cost': 500,
    'description': 'خصوصی اثرات شامل کریں',
  },
];

class FrameUpgradeScreen extends ConsumerWidget {
  const FrameUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upgradeState = ref.watch(frameUpgradeProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upgrades.length,
      itemBuilder: (context, index) {
        final upgrade = upgrades[index];
        final isOwned = upgradeState.purchasedUpgrades.contains(upgrade['id']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOwned ? RadicalTheme.gold : RadicalTheme.line,
              width: isOwned ? 2 : 1,
            ),
            color: RadicalTheme.panel,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrade['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      upgrade['description'],
                      style: const TextStyle(
                        color: RadicalTheme.smoke,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isOwned)
                ElevatedButton(
                  onPressed: () => _purchaseUpgrade(context, ref, upgrade['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RadicalTheme.gold,
                  ),
                  child: Text('${upgrade['cost']}💎'),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: RadicalTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'خریداری شده',
                    style: TextStyle(color: RadicalTheme.gold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _purchaseUpgrade(
    BuildContext context,
    WidgetRef ref,
    String upgradeId,
  ) {
    ref.read(frameUpgradeProvider.notifier).purchaseUpgrade(upgradeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اپ گریڈ خریداری ہوا!')),
    );
  }
}

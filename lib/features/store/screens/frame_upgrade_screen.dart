import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/radical_theme.dart';
import '../controllers/frame_upgrade_controller.dart';
import '../models/frame_upgrade.dart';

class FrameUpgradeScreen extends ConsumerWidget {
  const FrameUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upgradeState = ref.watch(frameUpgradeProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: frameUpgrades.length,
      itemBuilder: (context, index) {
        final upgrade = frameUpgrades[index];
        final isOwned = upgradeState.purchasedUpgrades[upgrade.id] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOwned ? RadicalTheme.gold.withOpacity(0.1) : RadicalTheme.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOwned ? RadicalTheme.gold : RadicalTheme.line,
              width: isOwned ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(upgrade.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(upgrade.description, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (!isOwned)
                    Text('${upgrade.diamondCost}', style: const TextStyle(fontWeight: FontWeight.w600, color: RadicalTheme.gold)),
                  if (isOwned)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              if (!isOwned) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => ref.read(frameUpgradeProvider.notifier).purchaseUpgrade(upgrade),
                    child: const Text('خریدیں'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

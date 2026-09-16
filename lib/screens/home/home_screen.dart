mkdir -p lib/screens/home

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/models/radical_avatar_frame_model.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_avatar_frame.dart';
import '../../core/widgets/radical_bottom_nav.dart';
import '../../core/widgets/radical_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final activeTab = ref.watch(homeTabProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      RadicalAvatarFrame(
                        avatarAssetPath: 'assets/logo/radical_face_only.png',
                        tier: RadicalFrameTier.gold,
                        size: 52,
                        isOnline: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('یوسف', style: RadicalTheme.textTheme.titleMedium),
                            Text('سطح ۱۲', style: RadicalTheme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: RadicalTheme.glassCard(radius: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, size: 16, color: RadicalTheme.gold),
                            const SizedBox(width: 5),
                            Text('${wallet.coins}', style: RadicalTheme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: RadicalTheme.glassCard(radius: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.diamond, size: 16, color: Colors.cyanAccent),
                            const SizedBox(width: 5),
                            Text('${wallet.diamonds}', style: RadicalTheme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const RadicalLogoMark(size: 190),
                        const SizedBox(height: 18),
                        Text('مافیا رادیکال', style: RadicalTheme.textTheme.displayLarge),
                        const SizedBox(height: 4),
                        Text('آماده‌ای نقشتو بازی کنی؟', style: RadicalTheme.textTheme.bodyMedium),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('ورود به بازی'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: RadicalTheme.glassCard(radius: 16),
                            child: const Icon(Icons.flash_on, color: RadicalTheme.gold, size: 24),
                          ),
                          const SizedBox(height: 6),
                          Text('شروع سریع', style: RadicalTheme.textTheme.bodyMedium),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: RadicalTheme.glassCard(radius: 16),
                            child: const Icon(Icons.people_alt_outlined, color: RadicalTheme.gold, size: 24),
                          ),
                          const SizedBox(height: 6),
                          Text('دوستان', style: RadicalTheme.textTheme.bodyMedium),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: RadicalTheme.glassCard(radius: 16),
                            child: const Icon(Icons.event_outlined, color: RadicalTheme.gold, size: 24),
                          ),
                          const SizedBox(height: 6),
                          Text('رویدادها', style: RadicalTheme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: RadicalBottomNav(
          activeTab: activeTab,
          onChanged: (tab) => ref.read(homeTabProvider.notifier).state = tab,
        ),
      ),
    );
  }
}


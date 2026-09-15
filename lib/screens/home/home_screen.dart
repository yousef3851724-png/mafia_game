import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_avatar_frame.dart';
import '../../core/widgets/radical_bottom_nav.dart';
import '../../features/scenarios/radical_avatar_catalog.dart';
import '../../features/store/store_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/scenarios/scenario_lobby_screen.dart';

/// صفحه‌ی اصلی اپ بعد از ورود/آنبوردینگ.
/// ساختار اصلی حفظ شده و از اجزای واقعی پروژه استفاده می‌کند.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final activeTab = ref.watch(homeTabProvider);

    Widget content;
    switch (activeTab) {
      case RadicalHomeTab.home:
        content = const _HomeContent();
        break;
      case RadicalHomeTab.lobby:
        content = const ScenarioLobbyScreen(ownerId: 'local_creator');
        break;
      case RadicalHomeTab.shop:
        content = const StoreScreen();
        break;
      case RadicalHomeTab.profile:
        content = const ProfileScreen();
        break;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                if (activeTab == RadicalHomeTab.home) _TopBar(wallet: wallet),
                Expanded(child: content),
                if (activeTab == RadicalHomeTab.home) const _QuickActionsRow(),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadicalAvatarFrame(
            avatarAssetPath: RadicalAvatarCatalog.avatars.first.assetPath,
            tier: RadicalFrameTier.gold,
            size: 190,
            isOnline: true,
          ),
          const SizedBox(height: 18),
          Text('مافیا رادیکال', style: RadicalTheme.textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('آماده‌ای نقشتو بازی کنی؟', style: RadicalTheme.textTheme.bodyMedium),
          const SizedBox(height: 28),
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator'),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('ورود به بازی'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final RadicalWallet wallet;
  const _TopBar({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          RadicalAvatarFrame(
            avatarAssetPath: RadicalAvatarCatalog.avatars.first.assetPath,
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
                Text('سطح ۱۲ — کهنه‌کار', style: RadicalTheme.textTheme.bodyMedium),
              ],
            ),
          ),
          _CurrencyChip(icon: Icons.monetization_on, color: RadicalTheme.gold, value: wallet.coins),
          const SizedBox(width: 8),
          _CurrencyChip(icon: Icons.diamond, color: Colors.cyanAccent, value: wallet.diamonds),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  const _CurrencyChip({required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: RadicalTheme.glass(radius: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text('$value', style: RadicalTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.flash_on, 'شروع سریع'),
      (Icons.people_alt_outlined, 'دوستان'),
      (Icons.event_outlined, 'رویدادها'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: RadicalTheme.glass(radius: 16),
              child: Icon(a.$1, color: RadicalTheme.gold, size: 24),
            ),
            const SizedBox(height: 6),
            Text(a.$2, style: RadicalTheme.textTheme.bodyMedium),
          ],
        )).toList(),
      ),
    );
  }
}

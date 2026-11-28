import 'dart:ui' show ImageFilter;

import '../../features/store/controllers/store_controller.dart';
import '../../features/store/store_items.dart';
import '../../features/store/equip_screen.dart';
import '../../features/store/store_hub_screen.dart';
import '../../router/app_router.dart';
import '../../core/theme/radical_frame_tier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/player_profile.dart';
import '../../core/services/owner_access.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_avatar_frame.dart';
import '../../features/lobbies/lobby_hub_screen.dart';
import '../../features/profile/profile_screen.dart';

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
            child: switch (activeTab) {
              RadicalHomeTab.home => _HomeTabBody(wallet: wallet),
              RadicalHomeTab.lobby =>
                const LobbyHubScreen(ownerId: 'local_creator'),
              RadicalHomeTab.shop => const StoreHubScreen(),
              RadicalHomeTab.profile => const ProfileScreen(),
            },
          ),
        ),
        bottomNavigationBar: _HomeBar(
          activeTab: activeTab,
          onTab: (tab) => ref.read(homeTabProvider.notifier).state = tab,
        ),
      ),
    );
  }
}

/// عدد را با رقم فارسی و جداکننده‌ی هزارگان نشان می‌دهد.
String _fa(num n) {
  final s = n.toInt().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('٬');
    b.write(s[i]);
  }
  const digits = '۰۱۲۳۴۵۶۷۸۹';
  return b
      .toString()
      .split('')
      .map((c) => RegExp(r'\d').hasMatch(c) ? digits[int.parse(c)] : c)
      .join();
}

Future<void> _ownerDialog(BuildContext context, WidgetRef ref) async {
  final c = TextEditingController();
  final code = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('کد مالک'),
      content: TextField(
        controller: c,
        autofocus: true,
        obscureText: true,
        textDirection: TextDirection.ltr,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('تأیید')),
      ],
    ),
  );
  if (code == null || code.isEmpty) return;
  final ok = await OwnerAccess.tryUnlock(ref, code);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'دسترسی مالک فعال شد' : 'کد نادرست است')));
}

void _soon(BuildContext context) {
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('به‌زودی')));
}

class _HomeTabBody extends ConsumerWidget {
  final RadicalWallet wallet;
  const _HomeTabBody({required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeControllerProvider);
    final profile = ref.watch(playerProfileProvider).valueOrNull;
    final avId = store.equipped[StoreCategory.avatar];
    final frId = store.equipped[StoreCategory.frame];
    final avPath = avId == null
        ? 'assets/logo/radical_face_only.png'
        : StoreItems.avatars.firstWhere((e) => e.id == avId).assetPath;
    final frPath = frId == null
        ? null
        : StoreItems.frames.firstWhere((e) => e.id == frId).assetPath;

    void goShop() =>
        ref.read(homeTabProvider.notifier).state = RadicalHomeTab.shop;
    void goProfile() =>
        ref.read(homeTabProvider.notifier).state = RadicalHomeTab.profile;

    return Stack(
      fit: StackFit.expand,
      children: [
        // پس‌زمینه‌ی نهایی (لوگو، مرد، گرگ‌ها و شهر) بدون هیچ دکمه‌ای روی تصویر.
        Image.asset(
          'assets/images/home_bg.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xCC060508),
                Color(0x00060508),
                Color(0x00060508),
                Color(0xF2060508),
              ],
              stops: [0.0, 0.14, 0.60, 1.0],
            ),
          ),
        ),
        // چیدمان فیزیکی مثل طرح: آواتار چپ، کیف پول و آیکن‌ها راست.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: goProfile,
                          child: RadicalAvatarFrame(
                            avatarAssetPath: avPath,
                            framePath: frPath,
                            tier: frPath == null
                                ? RadicalFrameTier.none
                                : RadicalFrameTier.gold,
                            size: 52,
                            isOnline: true,
                          ),
                        ),
                        Positioned(
                          left: -4,
                          bottom: -4,
                          child: _LevelBadge(text: _fa(profile?.level ?? 1)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onLongPress: () => _ownerDialog(context, ref),
                        child: Text(
                          profile?.name ?? '...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RadicalTheme.textTheme.titleMedium
                              ?.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _WalletPill(
                              icon: Icons.monetization_on,
                              color: RadicalTheme.gold,
                              text: _fa(wallet.coins),
                              onTap: goShop,
                            ),
                            const SizedBox(width: 5),
                            _WalletPill(
                              icon: Icons.diamond,
                              color: Colors.cyanAccent,
                              text: _fa(wallet.diamonds),
                              onTap: goShop,
                            ),
                            const SizedBox(width: 4),
                            _TopIcon(
                              icon: Icons.mail_outline_rounded,
                              onTap: () => _soon(context),
                            ),
                            _TopIcon(
                              icon: Icons.settings_rounded,
                              onTap: () => _soon(context),
                            ),
                            _TopIcon(
                              icon: Icons.menu_rounded,
                              onTap: () => _soon(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 14,
                      child: Column(
                        children: [
                          _SideAction(
                            icon: Icons.card_giftcard_rounded,
                            label: 'جوایز روزانه',
                            onTap: () => context.push(RadicalRoutes.luckyWheel),
                          ),
                          const SizedBox(height: 8),
                          _SideAction(
                            icon: Icons.emoji_events_rounded,
                            label: 'ماموریت‌ها',
                            onTap: () => _soon(context),
                          ),
                          const SizedBox(height: 8),
                          _SideAction(
                            icon: Icons.workspace_premium_rounded,
                            label: 'رویدادها',
                            onTap: () => _soon(context),
                          ),
                          const SizedBox(height: 8),
                          _SideAction(
                            icon: Icons.storefront_rounded,
                            label: 'فروشگاه',
                            onTap: goShop,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MainPlayButton(
                              label: 'بازی دوستانه',
                              onTap: () =>
                                  context.go(RadicalRoutes.passAndPlay),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'با دوستانت بازی کن و لذت ببر',
                              textAlign: TextAlign.center,
                              style: RadicalTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 12,
                                color: RadicalTheme.goldSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String text;
  const _LevelBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RadicalTheme.ink,
        border: Border.all(color: RadicalTheme.gold, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: RadicalTheme.goldBright,
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 22, color: RadicalTheme.goldSoft),
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onTap;
  const _WalletPill({
    required this.icon,
    required this.color,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: RadicalTheme.glassCard(radius: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(text, style: RadicalTheme.textTheme.bodyMedium),
            const SizedBox(width: 5),
            const Icon(Icons.add_circle,
                size: 15, color: RadicalTheme.goldSoft),
          ],
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SideAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: RadicalTheme.glassCard(radius: 23, accent: true),
              child: Icon(icon, color: RadicalTheme.gold, size: 23),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: RadicalTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دکمه‌ی اصلی پایین صفحه مثل طرح: قاب طلایی گوشه‌بریده، آیکن بالا، فلش‌ها دو طرف.
class _MainPlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MainPlayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: RadicalTheme.gold, width: 1.6),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xE61C1409), Color(0xF2090705)],
          ),
          shadows: [
            BoxShadow(
              color: RadicalTheme.gold.withValues(alpha: .28),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.keyboard_double_arrow_left_rounded,
                color: RadicalTheme.gold, size: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.groups_rounded,
                      color: RadicalTheme.goldBright, size: 22),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RadicalTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 19,
                      color: RadicalTheme.goldBright,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_double_arrow_right_rounded,
                color: RadicalTheme.gold, size: 24),
          ],
        ),
      ),
    );
  }
}

class _BarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final RadicalHomeTab? tab;
  final VoidCallback? onTap;
  _BarItem(this.label, this.icon, this.activeIcon, {this.tab, this.onTap});
}

/// نوار پایین شش‌تایی مثل طرح: خانه، بازی، قاب، دوستان، لابی‌ها، فروشگاه.
class _HomeBar extends StatelessWidget {
  final RadicalHomeTab activeTab;
  final ValueChanged<RadicalHomeTab> onTab;
  const _HomeBar({required this.activeTab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final items = <_BarItem>[
      _BarItem('خانه', Icons.home_outlined, Icons.home_rounded,
          tab: RadicalHomeTab.home),
      _BarItem('بازی', Icons.style_outlined, Icons.style_rounded,
          onTap: () => context.go(RadicalRoutes.passAndPlay)),
      _BarItem('قاب', Icons.shield_outlined, Icons.shield_rounded,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const EquipScreen()))),
      _BarItem('دوستان', Icons.people_outline_rounded, Icons.people_alt_rounded,
          onTap: () => _soon(context)),
      _BarItem('لابی‌ها', Icons.groups_outlined, Icons.groups_rounded,
          tab: RadicalHomeTab.lobby),
      _BarItem('فروشگاه', Icons.diamond_outlined, Icons.diamond_rounded,
          tab: RadicalHomeTab.shop),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: RadicalTheme.ink.withValues(alpha: .82),
            border: const Border(
              top: BorderSide(color: RadicalTheme.lineGold, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (final it in items)
                      Expanded(
                        child: _BarButton(
                          item: it,
                          active: it.tab != null && it.tab == activeTab,
                          onTap: () {
                            final t = it.tab;
                            if (t != null) {
                              onTab(t);
                            } else {
                              it.onTap?.call();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final _BarItem item;
  final bool active;
  final VoidCallback onTap;
  const _BarButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? RadicalTheme.goldBright : RadicalTheme.smoke;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active
                ? RadicalTheme.gold.withValues(alpha: .12)
                : Colors.transparent,
            border: Border.all(
              color: active ? RadicalTheme.gold : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? item.activeIcon : item.icon,
                  size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

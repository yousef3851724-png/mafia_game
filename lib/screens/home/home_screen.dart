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
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_avatar_frame.dart';
import '../../core/widgets/radical_bottom_nav.dart';
import '../../core/widgets/radical_logo.dart';
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
        bottomNavigationBar: RadicalBottomNav(
          activeTab: activeTab,
          onChanged: (tab) => ref.read(homeTabProvider.notifier).state = tab,
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
    void goLobby() =>
        ref.read(homeTabProvider.notifier).state = RadicalHomeTab.lobby;

    return Stack(
      fit: StackFit.expand,
      children: [
        // پس‌زمینه‌ی سینمایی (اختیاری): اگر فایل نبود چیزی نشان داده نمی‌شود.
        Image.asset(
          'assets/images/home_bg.png',
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
                Color(0xB3060508),
                Color(0x00060508),
                Color(0x00060508),
                Color(0xE6060508),
              ],
              stops: [0.0, 0.25, 0.5, 1.0],
            ),
          ),
        ),
        // چیدمان فیزیکی مثل طرح: آواتار چپ، کیف پول راست.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EquipScreen())),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('یوسف',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RadicalTheme.textTheme.titleMedium),
                          Text('سطح ۱۲',
                              style: RadicalTheme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    _WalletPill(
                      icon: Icons.monetization_on,
                      color: RadicalTheme.gold,
                      text: _fa(wallet.coins),
                      onTap: goShop,
                    ),
                    const SizedBox(width: 6),
                    _WalletPill(
                      icon: Icons.diamond,
                      color: Colors.cyanAccent,
                      text: _fa(wallet.diamonds),
                      onTap: goShop,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      left: 12,
                      top: 18,
                      child: Column(
                        children: [
                          _SideAction(
                            icon: Icons.card_giftcard_rounded,
                            label: 'جوایز روزانه',
                            onTap: () => context.push('/lucky-wheel'),
                          ),
                          const SizedBox(height: 10),
                          _SideAction(
                            icon: Icons.emoji_events_outlined,
                            label: 'ماموریت‌ها',
                            onTap: () => _soon(context),
                          ),
                          const SizedBox(height: 10),
                          _SideAction(
                            icon: Icons.event_outlined,
                            label: 'رویدادها',
                            onTap: () => _soon(context),
                          ),
                          const SizedBox(height: 10),
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
                      child: LayoutBuilder(
                        builder: (context, c) => FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: c.maxWidth,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 96),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const RadicalLogoMark(size: 120),
                                  const SizedBox(height: 6),
                                  Text('مافیا رادیکال',
                                      style:
                                          RadicalTheme.textTheme.displayLarge),
                                  const SizedBox(height: 18),
                                  FractionallySizedBox(
                                    widthFactor: 0.92,
                                    child: _AngledButton(
                                      label: 'بازی دوستانه',
                                      icon: Icons.groups_rounded,
                                      colors: const [
                                        Color(0xFF223247),
                                        Color(0xFF111826),
                                      ],
                                      border: const Color(0xFF6C86A3),
                                      onTap: () =>
                                          context.go(RadicalRoutes.passAndPlay),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FractionallySizedBox(
                                    widthFactor: 0.84,
                                    child: _AngledButton(
                                      label: 'پخش زنده',
                                      icon: Icons.sensors_rounded,
                                      colors: const [
                                        Color(0xFF9B1B24),
                                        Color(0xFF4A0A10),
                                      ],
                                      border: RadicalTheme.crimsonBright,
                                      onTap: () => _soon(context),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FractionallySizedBox(
                                    widthFactor: 0.76,
                                    child: _AngledButton(
                                      label: 'تیم‌های خصوصی',
                                      icon: Icons.groups_3_rounded,
                                      colors: const [
                                        Color(0xFF16386B),
                                        Color(0xFF0B1B33),
                                      ],
                                      border: const Color(0xFF3B82F6),
                                      onTap: goLobby,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FractionallySizedBox(
                                    widthFactor: 0.92,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _AngledButton(
                                            label: 'مسابقات',
                                            icon: Icons.emoji_events_rounded,
                                            height: 48,
                                            colors: const [
                                              Color(0xFF3F1D66),
                                              Color(0xFF1A0B2E),
                                            ],
                                            border: const Color(0xFFA855F7),
                                            onTap: () => _soon(context),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _AngledButton(
                                            label: 'جدول رده‌بندی',
                                            icon: Icons.leaderboard_rounded,
                                            height: 48,
                                            colors: const [
                                              Color(0xFF2E2511),
                                              Color(0xFF14110A),
                                            ],
                                            border: RadicalTheme.gold,
                                            onTap: () => _soon(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
              width: 48,
              height: 48,
              decoration: RadicalTheme.glassCard(radius: 14),
              child: Icon(icon, color: RadicalTheme.gold, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
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

/// دکمه‌ی گوشه‌بریده مثل طرح: آیکن چپ، متن وسط، فلش راست.
class _AngledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final Color border;
  final VoidCallback onTap;
  final double height;
  const _AngledButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.border,
    required this.onTap,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BeveledRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: border, width: 1.3),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: ShapeDecoration(
          shape: shape,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          shadows: [
            BoxShadow(
              color: border.withValues(alpha: .25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: RadicalTheme.textPrimary, size: 24),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadicalTheme.textTheme.titleMedium,
                ),
              ),
            ),
            Icon(Icons.keyboard_double_arrow_left_rounded,
                color: border, size: 20),
          ],
        ),
      ),
    );
  }
}

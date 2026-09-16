cat > lib/screens/home/home_screen.dart << 'EOF'
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
                _TopBar(wallet: wallet),
                Expanded(child: _GodfatherHero()),
                const _QuickActionsRow(),
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
          _CurrencyChip(
            icon: Icons.monetization_on,
            color: RadicalTheme.gold,
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../shop/widgets/currency_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName = 'مافیا رادیکال',
    this.level = 27,
    this.coinBalance = 254850,
    this.diamondBalance = 1250,
    this.xpCurrent = 450,
    this.xpTotal = 1000,
    this.onQuickGame,
    this.onFriendlyLobby,
    this.onOpenShop,
  });

  final String userName;
  final int level;
  final int coinBalance;
  final int diamondBalance;
  final int xpCurrent;
  final int xpTotal;
  final VoidCallback? onQuickGame;
  final VoidCallback? onFriendlyLobby;
  final VoidCallback? onOpenShop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildHero(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _ModeButton(title: 'بازی سریع', subtitle: 'ورود به بازی تصادفی', icon: Icons.flash_on, color: AppColors.primary, onTap: onQuickGame)),
                        const SizedBox(width: 12),
                        Expanded(child: _ModeButton(title: 'بازی دوستانه', subtitle: 'ایجاد یا ورود به لابی', icon: Icons.groups, color: AppColors.accent, onTap: onFriendlyLobby)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: _MiniButton(title: 'سناریوها', icon: Icons.theater_comedy)),
                        SizedBox(width: 10),
                        Expanded(child: _MiniButton(title: 'آواتارها', icon: Icons.face)),
                        SizedBox(width: 10),
                        Expanded(child: _MiniButton(title: 'ماموریت‌ها', icon: Icons.flag, hasBadge: true)),
                        SizedBox(width: 10),
                        Expanded(child: _MiniButton(title: 'جوایز روزانه', icon: Icons.card_giftcard, hasBadge: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBattlePass(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldFrameGradient),
                padding: const EdgeInsets.all(2),
                child: const CircleAvatar(backgroundColor: AppColors.surface, child: Icon(Icons.person, color: AppColors.textSecondary)),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                  child: Text('$level', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2B1E05))),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('سطح $level', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          CurrencyBadge(type: CurrencyType.coin, value: _format(coinBalance), onAddTap: () {}),
          const SizedBox(width: 6),
          CurrencyBadge(type: CurrencyType.diamond, value: _format(diamondBalance), onAddTap: () {}),
          const SizedBox(width: 6),
          const Icon(Icons.settings, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.nightGradient,
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.theater_comedy, size: 48, color: AppColors.secondary.withOpacity(0.8)),
          const SizedBox(height: 8),
          Text('مافیا رادیکال', style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildBattlePass() {
    final progress = xpCurrent / xpTotal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: AppColors.secondary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('گذرنامه نبرد - فصل 3', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$xpCurrent / $xpTotal', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: () {}, child: Text('مشاهده', style: AppTextStyles.caption.copyWith(color: AppColors.secondary))),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.home, label: 'خانه', selected: true),
          _NavItem(icon: Icons.shield, label: 'کلن'),
          _NavItem(icon: Icons.military_tech, label: 'رتبه'),
          _NavItem(icon: Icons.storefront, label: 'فروشگاه', onTap: onOpenShop),
          _NavItem(icon: Icons.person, label: 'پروفایل'),
        ],
      ),
    );
  }

  String _format(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.title, required this.subtitle, required this.icon, required this.color, this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [color.withOpacity(0.25), color.withOpacity(0.05)]),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.title, required this.icon, this.hasBadge = false});
  final String title;
  final IconData icon;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, color: AppColors.secondary, size: 20),
              if (hasBadge)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.error)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption.copyWith(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.selected = false, this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

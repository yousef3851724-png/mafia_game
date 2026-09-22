import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/app_providers.dart';
import '../theme/radical_theme.dart';

class RadicalBottomNavItem {
  final RadicalHomeTab tab;
  final IconData icon;
  final IconData activeIcon;
  final String labelFa;

  const RadicalBottomNavItem({
    required this.tab,
    required this.icon,
    required this.activeIcon,
    required this.labelFa,
  });
}

const List<RadicalBottomNavItem> radicalNavItems = [
  RadicalBottomNavItem(
    tab: RadicalHomeTab.home,
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    labelFa: 'خانه',
  ),
  RadicalBottomNavItem(
    tab: RadicalHomeTab.lobby,
    icon: Icons.groups_outlined,
    activeIcon: Icons.groups,
    labelFa: 'لابی',
  ),
  RadicalBottomNavItem(
    tab: RadicalHomeTab.shop,
    icon: Icons.storefront_outlined,
    activeIcon: Icons.storefront,
    labelFa: 'فروشگاه',
  ),
  RadicalBottomNavItem(
    tab: RadicalHomeTab.profile,
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    labelFa: 'پروفایل',
  ),
];

/// نوار پایین رادیکال با افکت شیشه‌ای و برجسته‌سازی طلایی تب فعال.
/// جایگاه و ترتیب چهار تب ثابت می‌ماند تا Flow فعلی بازی تغییر نکند.
class RadicalBottomNav extends StatelessWidget {
  final RadicalHomeTab activeTab;
  final ValueChanged<RadicalHomeTab> onChanged;

  const RadicalBottomNav({
    super.key,
    required this.activeTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: RadicalTheme.panel.withValues(alpha: .85),
            border: const Border(
              top: BorderSide(color: RadicalTheme.line, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: radicalNavItems.map((item) {
              final isActive = item.tab == activeTab;
              return _NavButton(
                item: item,
                isActive: isActive,
                onTap: () => onChanged(item.tab),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final RadicalBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive
              ? RadicalTheme.gold.withValues(alpha: .14)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? RadicalTheme.gold : RadicalTheme.smoke,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              item.labelFa,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? RadicalTheme.gold : RadicalTheme.smoke,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

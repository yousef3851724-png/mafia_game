import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

enum CurrencyType { coin, diamond, vip }

/// نشان نمایش موجودی سکه/الماس یا سطح VIP در نوار بالای صفحات.
class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({
    super.key,
    required this.type,
    required this.value,
    this.onAddTap,
  });

  final CurrencyType type;
  final String value;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    switch (type) {
      case CurrencyType.coin:
        icon = Icons.monetization_on;
        color = AppColors.coinColor;
        break;
      case CurrencyType.diamond:
        icon = Icons.diamond;
        color = AppColors.diamondColor;
        break;
      case CurrencyType.vip:
        icon = Icons.workspace_premium;
        color = AppColors.vipColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
          if (onAddTap != null && type != CurrencyType.vip) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onAddTap,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldButtonGradient),
                child: const Icon(Icons.add, size: 13, color: Color(0xFF2B1E05)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

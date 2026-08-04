import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// یک آیتم فروشگاه (قاب، استیکر، گیف و ...) با پیش‌نمایش دایره‌ای، نام و قیمت.
class ShopItemCard extends StatelessWidget {
  const ShopItemCard({
    super.key,
    required this.name,
    required this.price,
    this.priceIsGem = false,
    this.imageProvider,
    this.icon,
    this.isCircular = true,
    this.isOwned = false,
    this.isNew = false,
    this.onTap,
  });

  final String name;
  final int price;
  final bool priceIsGem;
  final ImageProvider? imageProvider;
  final IconData? icon;
  final bool isCircular;
  final bool isOwned;
  final bool isNew;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOwned ? AppColors.statusReady.withOpacity(0.6) : AppColors.divider,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircular ? null : BorderRadius.circular(10),
                    gradient: AppColors.goldFrameGradient,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: isCircular ? null : BorderRadius.circular(8),
                      color: AppColors.surfaceVariant,
                      image: imageProvider != null ? DecorationImage(image: imageProvider!, fit: BoxFit.cover) : null,
                    ),
                    alignment: Alignment.center,
                    child: imageProvider == null
                        ? Icon(icon ?? Icons.image_outlined, color: AppColors.textSecondary, size: 26)
                        : null,
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                      child: const Text('جدید', style: TextStyle(color: Colors.white, fontSize: 9)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            isOwned
                ? Text('استفاده شده', style: AppTextStyles.caption.copyWith(color: AppColors.statusReady, fontSize: 10))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priceIsGem ? Icons.diamond : Icons.monetization_on,
                        size: 12,
                        color: priceIsGem ? AppColors.diamondColor : AppColors.coinColor,
                      ),
                      const SizedBox(width: 3),
                      Text('$price', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

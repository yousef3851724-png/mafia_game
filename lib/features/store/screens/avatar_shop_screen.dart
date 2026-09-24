import 'package:flutter/material.dart';
import '../../../core/theme/radical_theme.dart';

class AvatarShopScreen extends StatelessWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'فروشگاه آواتار به‌زودی',
        style: TextStyle(
          color: RadicalTheme.smoke,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

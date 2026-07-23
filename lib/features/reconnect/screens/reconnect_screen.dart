import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// صفحه‌ای که هنگام بازگشت کاربر به یک بازی درحال‌اجرا نمایش داده می‌شود
/// (مثلاً بعد از قطعی اینترنت یا بستن اپ در میانه‌ی بازی).
class ReconnectScreen extends StatelessWidget {
  const ReconnectScreen({
    super.key,
    this.onEnterGame,
    this.onBackToLobby,
  });

  final VoidCallback? onEnterGame;
  final VoidCallback? onBackToLobby;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('ورود دیرهنگام', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.theater_comedy, size: 64, color: AppColors.secondary.withOpacity(0.9)),
                    const SizedBox(height: 8),
                    Text(
                      'MAFIA',
                      style: AppTextStyles.headline.copyWith(color: AppColors.secondary, letterSpacing: 4, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'RADICAL',
                      style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, letterSpacing: 6, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Text('شما با تاخیر وارد بازی شدید.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(
                      'بعضی از مراحل بازی ممکن است گذشته باشد.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _PrimaryButton(label: 'ورود به بازی', icon: Icons.arrow_forward, onTap: onEnterGame),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: onBackToLobby,
                      child: Text('بازگشت به لابی', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 28),
                    _buildInfoGrid(),
                    const SizedBox(height: 20),
                    Text(
                      'توجه: در صورت خروج مجدد، امکان بازگشت به این بازی وجود نخواهد داشت.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      (Icons.history, 'ادامه از مرحله فعلی', 'بازی را از همان مرحله ادامه دهید.'),
      (Icons.remove_red_eye_outlined, 'مشاهده خلاصه بازی', 'خلاصه‌ای از اتفاقات گذشته را مشاهده کنید.'),
      (Icons.people_outline, 'اطلاع از وضعیت بازیکنان', 'وضعیت و نقش بازیکنان را بررسی کنید.'),
      (Icons.card_giftcard, 'دریافت پاداش حضور', 'به دلیل دیر رسیدن، پاداش کمتری دریافت کنید.'),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return SizedBox(
          width: 130,
          child: Column(
            children: [
              Icon(item.$1, color: AppColors.secondary, size: 22),
              const SizedBox(height: 6),
              Text(item.$2, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(item.$3, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 9), textAlign: TextAlign.center),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.bloodGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// وضعیت اتصال/آمادگی بازیکن روی صندلی
enum SeatStatus { ready, notReady, empty }

/// یک صندلی بازیکن دور میز مافیا.
/// شامل: شماره صندلی، آواتار با قاب طلایی، نقطه وضعیت (سبز/قرمز)،
/// نام کاربری، برچسب نقش/تیم (اختیاری)، تاج میزبان (اختیاری)، آیکون میکروفون (اختیاری).
class PlayerSeatWidget extends StatelessWidget {
  const PlayerSeatWidget({
    super.key,
    required this.seatNumber,
    this.playerName,
    this.avatarImageProvider,
    this.status = SeatStatus.empty,
    this.isHost = false,
    this.roleTagLabel,
    this.roleTagColor,
    this.isSpeaking = false,
    this.isMuted = false,
    this.avatarSize = 64,
    this.onTap,
  });

  final int seatNumber;
  final String? playerName;
  final ImageProvider? avatarImageProvider;
  final SeatStatus status;
  final bool isHost;

  /// برچسب بالای آواتار مثل «خانواده تاریکی» یا «پادشاهان مافیا»
  final String? roleTagLabel;
  final Color? roleTagColor;

  final bool isSpeaking;
  final bool isMuted;
  final double avatarSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = status == SeatStatus.empty;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (roleTagLabel != null) _RoleTagChip(label: roleTagLabel!, color: roleTagColor),
          if (roleTagLabel != null) const SizedBox(height: 4),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // حلقه‌ی درخشش هنگام صحبت‌کردن
              if (isSpeaking)
                Container(
                  width: avatarSize + 14,
                  height: avatarSize + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.statusReady, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.statusReady.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              // قاب طلایی + آواتار
              Container(
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isEmpty ? null : AppColors.goldFrameGradient,
                  color: isEmpty ? AppColors.surfaceVariant : null,
                  border: isEmpty ? Border.all(color: AppColors.divider, width: 1.5) : null,
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.surface,
                  backgroundImage: avatarImageProvider,
                  child: isEmpty
                      ? Icon(Icons.person_outline, color: AppColors.textSecondary, size: avatarSize * 0.45)
                      : (avatarImageProvider == null
                          ? Icon(Icons.person, color: AppColors.textSecondary, size: avatarSize * 0.5)
                          : null),
                ),
              ),
              // بج شماره صندلی (بالا-وسط مثل موکاپ)
              Positioned(
                top: -10,
                child: _SeatNumberBadge(number: seatNumber),
              ),
              // تاج میزبان
              if (isHost)
                const Positioned(
                  top: -22,
                  child: Icon(Icons.emoji_events, color: AppColors.secondary, size: 18),
                ),
              // نقطه وضعیت پایین آواتار
              if (!isEmpty)
                Positioned(
                  bottom: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status == SeatStatus.ready ? AppColors.statusReady : AppColors.statusNotReady,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              // آیکون میکروفون
              if (isMuted && !isEmpty)
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Icon(Icons.mic_off, size: 14, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: avatarSize + 24,
            child: Text(
              isEmpty ? 'منتظر بازیکن...' : (playerName ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
          if (!isEmpty)
            Text(
              status == SeatStatus.ready ? 'آماده' : 'در انتظار',
              style: AppTextStyles.caption.copyWith(
                color: status == SeatStatus.ready ? AppColors.statusReady : AppColors.statusNotReady,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}

class _SeatNumberBadge extends StatelessWidget {
  const _SeatNumberBadge({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldFrameGradient,
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Text(
        '$number',
        style: AppTextStyles.caption.copyWith(
          color: const Color(0xFF2B1E05),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _RoleTagChip extends StatelessWidget {
  const _RoleTagChip({required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.teamCitizenTag).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 10),
      ),
    );
  }
}

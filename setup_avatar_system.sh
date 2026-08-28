#!/bin/bash
set -e

echo "🎨 در حال ساخت سیستم مدیریت آواتار و فریم‌ها..."

mkdir -p lib/core/widgets
mkdir -p lib/core/constants

# 1. تعریف ثابت‌های مسیر فریم‌ها و آواتارها
cat << 'FILE' > lib/core/constants/app_assets.dart
class AppAssets {
  // Avatars
  static const String defaultAvatar = 'assets/avatars/default.png';
  static const String godfatherAvatar = 'assets/avatars/godfather.png';
  static const String doctorAvatar = 'assets/avatars/doctor.png';
  static const String detectiveAvatar = 'assets/avatars/detective.png';

  // Frames (آتش، برقی، طلایی، نئونی، VIP)
  static const String frameFire = 'assets/frames/frame_fire.svg';
  static const String frameLightning = 'assets/frames/frame_lightning.svg';
  static const String frameGold = 'assets/frames/frame_gold.svg';
  static const String frameNeon = 'assets/frames/frame_neon.svg';
}
FILE

# 2. ساخت ویجت تخصصی آواتار + فریم
cat << 'FILE' > lib/core/widgets/avatar_frame_widget.dart
import 'package:flutter/material.dart';

enum FrameType { none, gold, fire, lightning, neon }

class AvatarFrameWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackInitial;
  final FrameType frameType;
  final double size;
  final bool isAlive;

  const AvatarFrameWidget({
    super.key,
    this.imageUrl,
    this.fallbackInitial = '?',
    this.frameType = FrameType.none,
    this.size = 70.0,
    this.isAlive = true,
  });

  Color _getFrameColor() {
    switch (frameType) {
      case FrameType.fire:
        return const Color(0xFFFF4500); // نارنجی/آتشی
      case FrameType.lightning:
        return const Color(0xFF00E5FF); // آبی/صاعقه‌ای
      case FrameType.gold:
        return const Color(0xFFFFD700); // طلایی
      case FrameType.neon:
        return const Color(0xFF39FF14); // سبز نئونی
      case FrameType.none:
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final frameColor = _getFrameColor();
    final hasFrame = frameType != FrameType.none;

    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // افکت Glow دور فریم (برای فریم‌های برقی و آتشی)
          if (hasFrame && isAlive)
            Container(
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: frameColor.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

          // حاشیه / فریم بیرونی
          if (hasFrame)
            Container(
              width: size + 8,
              height: size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAlive ? frameColor : Colors.grey.shade700,
                  width: 3.5,
                ),
              ),
            ),

          // دایره آواتار اصلی
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAlive ? const Color(0xFF2A2A2A) : Colors.black87,
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallback(),
                    )
                  : _buildFallback(),
            ),
          ),

          // وضعیت بازیکن مرده (علامت X قرمز)
          if (!isAlive)
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, color: Colors.redAccent, size: 40),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackInitial.isNotEmpty ? fallbackInitial[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: isAlive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
FILE

# 3. به‌روزرسانی کارت بازیکن برای اتصال به AvatarFrameWidget
cat << 'FILE' > lib/features/game/presentation/widgets/player_avatar_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../../../core/widgets/avatar_frame_widget.dart';

class PlayerAvatarCard extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final FrameType frameType;
  final VoidCallback onTap;

  const PlayerAvatarCard({
    super.key,
    required this.player,
    required this.isSelected,
    this.frameType = FrameType.fire, // مقدار تستی برای نمایش فریم
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: player.isAlive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: player.isAlive
              ? (isSelected ? theme.colorScheme.primary.withOpacity(0.25) : const Color(0xFF1E1E1E))
              : Colors.black38,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white10,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ویجت ماژولار آواتار + فریم
            AvatarFrameWidget(
              fallbackInitial: player.name,
              frameType: player.isAlive ? frameType : FrameType.none,
              isAlive: player.isAlive,
              size: 56,
            ),
            const SizedBox(height: 8),
            Text(
              player.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: player.isAlive ? Colors.white : Colors.grey,
                decoration: player.isAlive ? null : TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              player.role,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
FILE

echo "✅ سیستم آواتار و فریم‌ها ساخته شد و به کارت بازیکن متصل گردید!"

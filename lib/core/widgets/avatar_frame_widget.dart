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

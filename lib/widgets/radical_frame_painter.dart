import 'package:flutter/material.dart';
import '../core/models/radical_avatar_catalog.dart';

class RadicalFramePainter extends CustomPainter {
  final RadicalFrameTier tier;
  final bool isOnline;

  RadicalFramePainter({
    required this.tier,
    required this.isOnline,
  });

  Color get _frameColor {
    switch (tier) {
      case RadicalFrameTier.none:
        return Colors.grey.shade700;
      case RadicalFrameTier.bronze:
        return const Color(0xFFCD7F32);
      case RadicalFrameTier.silver:
        return const Color(0xFFC0C0C0);
      case RadicalFrameTier.gold:
        return const Color(0xFFD4AF37);
      case RadicalFrameTier.platinum:
        return const Color(0xFFE5E4E2);
      case RadicalFrameTier.diamond:
        return const Color(0xFF00E5FF);
      case RadicalFrameTier.legendary:
        return const Color(0xFFE60023);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final framePaint = Paint()
      ..color = _frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    if (tier == RadicalFrameTier.legendary || tier == RadicalFrameTier.diamond) {
      final glowPaint = Paint()
        ..color = _frameColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(center, radius - 4, glowPaint);
    }

    canvas.drawCircle(center, radius - 4, framePaint);

    if (isOnline) {
      final dotOffset = Offset(
        center.dx + radius * 0.7,
        center.dy + radius * 0.7,
      );
      final dotBorderPaint = Paint()..color = Colors.black;
      final dotPaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawCircle(dotOffset, 7.0, dotBorderPaint);
      canvas.drawCircle(dotOffset, 5.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadicalFramePainter oldDelegate) {
    return oldDelegate.tier != tier || oldDelegate.isOnline != isOnline;
  }
}

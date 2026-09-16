cat > lib/widgets/radical_frame_painter.dart << 'EOF'
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadicalFramePainter extends CustomPainter {
  final List<Color> gradientColors;
  final Color glowColor;
  final double strokeWidth;
  final double rotationRadians;

  RadicalFramePainter({
    required this.gradientColors,
    required this.glowColor,
    this.strokeWidth = 5,
    this.rotationRadians = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (glowColor != Colors.transparent) {
      final glowPaint = Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius, glowPaint);
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [...gradientColors, gradientColors.first],
        transform: GradientRotation(rotationRadians),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, ringPaint);

    final ornamentPaint = Paint()
      ..color = gradientColors.last
      ..style = PaintingStyle.fill;

    for (final angleDeg in [45, 135, 225, 315]) {
      final angle = angleDeg * math.pi / 180 + rotationRadians;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      _drawOrnament(canvas, point, angle, ornamentPaint, strokeWidth);
    }
  }

  void _drawOrnament(Canvas canvas, Offset at, double angle, Paint paint, double scale) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, -scale * 1.6)
      ..quadraticBezierTo(scale * 1.4, 0, 0, scale * 1.6)
      ..quadraticBezierTo(-scale * 1.4, 0, 0, -scale * 1.6)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RadicalFramePainter oldDelegate) {
    return oldDelegate.gradientColors != gradientColors ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.rotationRadians != rotationRadians;
  }
}
EOF
echo "✅ radical_frame_painter.dart ساخته شد"
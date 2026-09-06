import 'package:flutter/material.dart';

class MafiaRadicalLogo extends StatefulWidget {
  final double size;
  const MafiaRadicalLogo({super.key, this.size = 110.0});

  @override
  State<MafiaRadicalLogo> createState() => _MafiaRadicalLogoState();
}

class _MafiaRadicalLogoState extends State<MafiaRadicalLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = _pulseController.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3 + (glow * 0.4)),
                blurRadius: 20 + (glow * 10),
                spreadRadius: 2 + (glow * 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _RadicalLogoPainter(glowValue: glow),
          ),
        );
      },
    );
  }
}

class _RadicalLogoPainter extends CustomPainter {
  final double glowValue;
  _RadicalLogoPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // پس‌زمینه نشان
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2B080C), Color(0xFF100305)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // حلقه بیرونی درخشان
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = const SweepGradient(
        colors: [Colors.redAccent, Colors.amber, Colors.deepOrangeAccent, Colors.redAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, borderPaint);

    // کلاه و نماد مافیا
    final hatPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // لبه کلاه
    final hatPath = Path();
    hatPath.moveTo(w * 0.22, h * 0.52);
    hatPath.quadraticBezierTo(w * 0.5, h * 0.44, w * 0.78, h * 0.52);
    hatPath.quadraticBezierTo(w * 0.5, h * 0.58, w * 0.22, h * 0.52);

    // تاج کلاه
    hatPath.moveTo(w * 0.32, h * 0.50);
    hatPath.lineTo(w * 0.36, h * 0.32);
    hatPath.quadraticBezierTo(w * 0.5, h * 0.35, w * 0.64, h * 0.32);
    hatPath.lineTo(w * 0.68, h * 0.50);

    canvas.drawPath(hatPath, hatPaint);

    // نوار قرمز کلاه
    final ribbonPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(w * 0.33, h * 0.48), Offset(w * 0.67, h * 0.48), ribbonPaint);

    // قطره خون رادیکال
    final bloodPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..style = PaintingStyle.fill;

    final dropPath = Path();
    dropPath.moveTo(w * 0.5, h * 0.62);
    dropPath.quadraticBezierTo(w * 0.44, h * 0.73, w * 0.5, h * 0.78);
    dropPath.quadraticBezierTo(w * 0.56, h * 0.73, w * 0.5, h * 0.62);
    canvas.drawPath(dropPath, bloodPaint);
  }

  @override
  bool shouldRepaint(covariant _RadicalLogoPainter oldDelegate) =>
      oldDelegate.glowValue != glowValue;
}

import 'package:flutter/material.dart';

class MafiaRadicalLogo extends StatefulWidget {
  final double size;
  const MafiaRadicalLogo({super.key, this.size = 110.0});

  @override
  State<MafiaRadicalLogo> createState() => _MafiaRadicalLogoState();
}

class _MafiaRadicalLogoState extends State<MafiaRadicalLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
        final glow = Curves.easeInOut.transform(_pulseController.value);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE3B873).withOpacity(.12 + glow * .18),
                blurRadius: 22 + glow * 10,
                spreadRadius: 1 + glow * 3,
              ),
              BoxShadow(
                color: const Color(0xFF9E263D).withOpacity(.10 + glow * .12),
                blurRadius: 28,
              ),
            ],
          ),
          child: CustomPaint(painter: _RadicalLogoPainter(glowValue: glow)),
        );
      },
    );
  }
}

class _RadicalLogoPainter extends CustomPainter {
  final double glowValue;
  const _RadicalLogoPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2A2118), Color(0xFF0B0C11)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, bgPaint);

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 + glowValue * .8
      ..shader = const SweepGradient(
        colors: [Color(0xFFE3B873), Color(0xFF9E263D), Color(0xFFFFDFA0), Color(0xFFE3B873)],
      ).createShader(rect);
    canvas.drawCircle(center, radius - 2.5, outer);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x55E3B873);
    canvas.drawCircle(center, radius * .82, inner);

    final w = size.width;
    final h = size.height;
    final hat = Paint()..color = const Color(0xFFF2E7D0);
    final hatPath = Path()
      ..moveTo(w * .20, h * .53)
      ..quadraticBezierTo(w * .50, h * .43, w * .80, h * .53)
      ..quadraticBezierTo(w * .50, h * .60, w * .20, h * .53)
      ..moveTo(w * .31, h * .51)
      ..lineTo(w * .35, h * .31)
      ..quadraticBezierTo(w * .50, h * .35, w * .65, h * .31)
      ..lineTo(w * .69, h * .51)
      ..close();
    canvas.drawPath(hatPath, hat);

    final ribbon = Paint()
      ..color = const Color(0xFF9E263D)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * .33, h * .48), Offset(w * .67, h * .48), ribbon);

    final drop = Paint()..color = const Color(0xFFED4D67);
    final dropPath = Path()
      ..moveTo(w * .50, h * .61)
      ..quadraticBezierTo(w * .43, h * .73, w * .50, h * .79)
      ..quadraticBezierTo(w * .57, h * .73, w * .50, h * .61)
      ..close();
    canvas.drawPath(dropPath, drop);
  }

  @override
  bool shouldRepaint(covariant _RadicalLogoPainter oldDelegate) =>
      oldDelegate.glowValue != glowValue;
}

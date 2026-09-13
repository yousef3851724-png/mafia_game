import 'package:flutter/material.dart';

enum MafiaLogoScenario {
  classic,
  darkCity,
  western,
  halloween,
  prison,
  cyberpunk,
}

class MafiaRadicalLogo extends StatefulWidget {
  final double size;
  final MafiaLogoScenario scenario;

  const MafiaRadicalLogo({
    super.key,
    this.size = 110.0,
    this.scenario = MafiaLogoScenario.classic,
  });

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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * .47),
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
            child: CustomPaint(
              painter: _RadicalLogoPainter(
                glowValue: glow,
                scenario: widget.scenario,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RadicalLogoPainter extends CustomPainter {
  final double glowValue;
  final MafiaLogoScenario scenario;

  const _RadicalLogoPainter({
    required this.glowValue,
    required this.scenario,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = size.shortestSide * .46;

    final badgeRect = Rect.fromCenter(
      center: center,
      width: radius * 2.0,
      height: radius * 2.06,
    );

    final bgPaint = Paint()
      ..shader = _scenarioGradient(scenario, badgeRect);
    canvas.drawOval(badgeRect, bgPaint);

    _drawScenarioDetails(canvas, badgeRect, scenario, glowValue);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 + glowValue * .8
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFE3B873),
          Color(0xFF9E263D),
          Color(0xFFFFDFA0),
          Color(0xFFE3B873),
        ],
      ).createShader(badgeRect);
    canvas.drawOval(badgeRect.deflate(2.5), borderPaint);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x55E3B873);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 1.64,
        height: radius * 1.69,
      ),
      inner,
    );

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
    canvas.drawLine(
      Offset(w * .33, h * .48),
      Offset(w * .67, h * .48),
      ribbon,
    );

    final drop = Paint()..color = const Color(0xFFED4D67);
    final dropPath = Path()
      ..moveTo(w * .50, h * .61)
      ..quadraticBezierTo(w * .43, h * .73, w * .50, h * .79)
      ..quadraticBezierTo(w * .57, h * .73, w * .50, h * .61)
      ..close();
    canvas.drawPath(dropPath, drop);
  }

  Gradient _scenarioGradient(MafiaLogoScenario scenario, Rect rect) {
    switch (scenario) {
      case MafiaLogoScenario.darkCity:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08090D), Color(0xFF3A1015), Color(0xFF120609)],
        );
      case MafiaLogoScenario.western:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24130C), Color(0xFF9A5525), Color(0xFF3A2114)],
        );
      case MafiaLogoScenario.halloween:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10041B), Color(0xFF6B1B8C), Color(0xFF8F3A00)],
        );
      case MafiaLogoScenario.prison:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101316), Color(0xFF4A5258), Color(0xFF171A1D)],
        );
      case MafiaLogoScenario.cyberpunk:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF09001A), Color(0xFF76004E), Color(0xFF071B2F)],
        );
      case MafiaLogoScenario.classic:
        return const RadialGradient(
          colors: [Color(0xFF3A291C), Color(0xFF19090D), Color(0xFF08090D)],
        );
    }
  }

  void _drawScenarioDetails(
    Canvas canvas,
    Rect rect,
    MafiaLogoScenario scenario,
    double glow,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(.08 + glow * .04);

    switch (scenario) {
      case MafiaLogoScenario.darkCity:
        final baseY = rect.bottom * .72;
        for (var i = 0; i < 5; i++) {
          final x = rect.left + rect.width * (.18 + i * .16);
          final height = rect.height * (.10 + (i % 3) * .035);
          canvas.drawRect(
            Rect.fromLTWH(x, baseY - height, rect.width * .09, height),
            paint,
          );
        }
        break;
      case MafiaLogoScenario.western:
        canvas.drawLine(
          Offset(rect.left + rect.width * .16, rect.bottom * .73),
          Offset(rect.right - rect.width * .16, rect.bottom * .73),
          paint,
        );
        break;
      case MafiaLogoScenario.halloween:
        canvas.drawCircle(
          Offset(rect.right * .74, rect.top + rect.height * .25),
          rect.width * .08,
          paint,
        );
        break;
      case MafiaLogoScenario.prison:
        for (var i = 0; i < 4; i++) {
          final x = rect.left + rect.width * (.25 + i * .17);
          canvas.drawLine(
            Offset(x, rect.top + rect.height * .14),
            Offset(x, rect.bottom - rect.height * .14),
            paint,
          );
        }
        break;
      case MafiaLogoScenario.cyberpunk:
        canvas.drawLine(
          Offset(rect.left + rect.width * .12, rect.bottom * .68),
          Offset(rect.right - rect.width * .12, rect.bottom * .68),
          paint,
        );
        break;
      case MafiaLogoScenario.classic:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _RadicalLogoPainter oldDelegate) {
    return oldDelegate.glowValue != glowValue ||
        oldDelegate.scenario != scenario;
  }
}

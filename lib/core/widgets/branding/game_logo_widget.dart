import 'package:flutter/material.dart';

enum MafiaLogoScenario { classic, darkCity, western, halloween, prison, cyberpunk }

class MafiaRadicalLogo extends StatefulWidget {
  final double size;
  final MafiaLogoScenario scenario;

  const MafiaRadicalLogo({super.key, this.size = 110, this.scenario = MafiaLogoScenario.classic});

  @override
  State<MafiaRadicalLogo> createState() => _MafiaRadicalLogoState();
}

class _MafiaRadicalLogoState extends State<MafiaRadicalLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = Curves.easeInOut.transform(_pulse.value);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFFE3B873).withValues(alpha: .12 + glow * .18), blurRadius: 22 + glow * 10, spreadRadius: 1 + glow * 3),
                BoxShadow(color: const Color(0xFF9E263D).withValues(alpha: .10 + glow * .12), blurRadius: 28),
              ],
            ),
            child: CustomPaint(painter: _RadicalLogoPainter(glowValue: glow, scenario: widget.scenario)),
          ),
        );
      },
    );
  }
}

class _RadicalLogoPainter extends CustomPainter {
  final double glowValue;
  final MafiaLogoScenario scenario;
  const _RadicalLogoPainter({required this.glowValue, required this.scenario});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final rect = Rect.fromCenter(center: center, width: w * .92, height: h * .92);

    final bg = Paint()..shader = _scenarioGradient().createShader(rect);
    canvas.drawOval(rect, bg);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 + glowValue * .8
      ..shader = const SweepGradient(colors: [Color(0xFFE3B873), Color(0xFF9E263D), Color(0xFFFFDFA0), Color(0xFFE3B873)]).createShader(rect);
    canvas.drawOval(rect.deflate(2.5), border);

    final inner = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x55E3B873);
    canvas.drawOval(rect.deflate(w * .16), inner);

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

    final ribbon = Paint()..color = const Color(0xFF9E263D)..strokeWidth = 2.8..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * .33, h * .48), Offset(w * .67, h * .48), ribbon);

    final drop = Paint()..color = const Color(0xFFED4D67);
    final dropPath = Path()
      ..moveTo(w * .50, h * .61)
      ..quadraticBezierTo(w * .43, h * .73, w * .50, h * .79)
      ..quadraticBezierTo(w * .57, h * .73, w * .50, h * .61)
      ..close();
    canvas.drawPath(dropPath, drop);

    final shine = Paint()..color = Colors.white.withValues(alpha: .07 + glowValue * .04);
    canvas.drawOval(Rect.fromLTWH(w * .24, h * .19, w * .20, h * .10), shine);
  }

  Gradient _scenarioGradient() {
    switch (scenario) {
      case MafiaLogoScenario.darkCity:
        return const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF08090D), Color(0xFF3A1015), Color(0xFF120609)]);
      case MafiaLogoScenario.western:
        return const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF24130C), Color(0xFF9A5525), Color(0xFF3A2114)]);
      case MafiaLogoScenario.halloween:
        return const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF10041B), Color(0xFF6B1B8C), Color(0xFF8F3A00)]);
      case MafiaLogoScenario.prison:
        return const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF101316), Color(0xFF4A5258), Color(0xFF171A1D)]);
      case MafiaLogoScenario.cyberpunk:
        return const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF09001A), Color(0xFF76004E), Color(0xFF071B2F)]);
      case MafiaLogoScenario.classic:
        return const RadialGradient(colors: [Color(0xFF3A291C), Color(0xFF19090D), Color(0xFF08090D)]);
    }
  }

  @override
  bool shouldRepaint(covariant _RadicalLogoPainter oldDelegate) => oldDelegate.glowValue != glowValue || oldDelegate.scenario != scenario;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fictional, asset-free portrait used by the scenario table.
///
/// The portrait is intentionally drawn from simple vector layers so the app
/// stays offline-friendly and does not depend on celebrity or real-person
/// likenesses. Special roles receive their own visual treatment.
class RealisticAvatar extends StatelessWidget {
  final String role;
  final bool female;
  final double size;
  final bool alive;

  const RealisticAvatar({
    super.key,
    required this.role,
    this.female = false,
    this.size = 54,
    this.alive = true,
  });

  bool get _special => const {'دلقک', 'جوکر', 'زامبی', 'قاتل مستقل'}.contains(role);

  Color get _accent {
    if (role == 'دلقک' || role == 'جوکر') return const Color(0xFFB56BE8);
    if (role == 'زامبی') return const Color(0xFF78A87B);
    if (role == 'قاتل مستقل') return const Color(0xFFB34B63);
    if (role == 'مافیا' || role == 'پدرخوانده') return const Color(0xFF7888A3);
    if (role == 'دکتر' || role == 'محافظ') return const Color(0xFF69A8C7);
    return const Color(0xFF9DB1C4);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: alive ? 1 : .38,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_accent.withOpacity(.72), const Color(0xFF11151B)],
          ),
          border: Border.all(color: Colors.white.withOpacity(.22), width: 1.2),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(2, 5),
              color: Color(0x66000000),
            ),
          ],
        ),
        child: ClipOval(
          child: CustomPaint(
            painter: _PortraitPainter(
              female: female,
              special: role,
              accent: _accent,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  final bool female;
  final String special;
  final Color accent;

  const _PortraitPainter({
    required this.female,
    required this.special,
    required this.accent,
  });

  bool get isClown => special == 'دلقک' || special == 'جوکر';
  bool get isZombie => special == 'زامبی';
  bool get isKiller => special == 'قاتل مستقل';

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final c = Offset(size.width / 2, size.height / 2);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(.20), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c.translate(-s * .16, -s * .18), radius: s * .72));
    canvas.drawCircle(c.translate(-s * .16, -s * .18), s * .62, glow);

    final neckPaint = Paint()..color = const Color(0xFFB87961);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .39, s * .64, s * .22, s * .25),
        Radius.circular(s * .08),
      ),
      neckPaint,
    );

    final shirt = Paint()..color = isKiller ? const Color(0xFF181018) : const Color(0xFF202A35);
    canvas.drawPath(
      Path()
        ..moveTo(s * .14, s)
        ..quadraticBezierTo(s * .20, s * .73, s * .50, s * .70)
        ..quadraticBezierTo(s * .80, s * .73, s * .86, s)
        ..close(),
      shirt,
    );

    if (female && !isZombie) {
      final hair = Paint()..color = const Color(0xFF34251F);
      canvas.drawOval(Rect.fromLTWH(s * .16, s * .10, s * .68, s * .82), hair);
    }

    final skin = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isZombie
            ? const [Color(0xFF9AAF91), Color(0xFF536858)]
            : isClown
                ? const [Color(0xFFF2D7D2), Color(0xFFC9A7A3)]
                : const [Color(0xFFE5AE8D), Color(0xFF9B604F)],
      ).createShader(Rect.fromLTWH(s * .24, s * .20, s * .52, s * .57));

    final faceRect = Rect.fromLTWH(s * .25, s * .18, s * .50, s * .56);
    canvas.drawOval(faceRect, skin);

    final hair = Paint()..color = isClown ? const Color(0xFF3C174A) : const Color(0xFF231A18);
    if (!isZombie) {
      canvas.drawPath(
        Path()
          ..moveTo(s * .22, s * .38)
          ..quadraticBezierTo(s * .18, s * .10, s * .50, s * .09)
          ..quadraticBezierTo(s * .83, s * .10, s * .78, s * .40)
          ..quadraticBezierTo(s * .68, s * .25, s * .50, s * .29)
          ..quadraticBezierTo(s * .33, s * .25, s * .22, s * .38)
          ..close(),
        hair,
      );
    }

    final eye = Paint()..color = const Color(0xFF15171B);
    final eyeY = s * .43;
    canvas.drawOval(Rect.fromLTWH(s * .34, eyeY, s * .09, s * .055), eye);
    canvas.drawOval(Rect.fromLTWH(s * .57, eyeY, s * .09, s * .055), eye);

    if (isZombie) {
      final scar = Paint()
        ..color = const Color(0xFF6F3E3E)
        ..strokeWidth = s * .018
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(s * .31, s * .52), Offset(s * .43, s * .57), scar);
      canvas.drawLine(Offset(s * .58, s * .55), Offset(s * .69, s * .50), scar);
    }

    final nose = Paint()
      ..color = const Color(0x665C3029)
      ..strokeWidth = s * .018
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(s * .50, s * .45), Offset(s * .48, s * .52), nose);

    final mouth = Paint()
      ..color = isClown || isKiller ? const Color(0xFF5C1D2B) : const Color(0xFF6C3935)
      ..strokeWidth = s * .025
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(s * .42, s * .59)
      ..quadraticBezierTo(s * .50, s * (isClown ? .65 : .62), s * .58, s * .59);
    canvas.drawPath(mouthPath, mouth);

    if (isClown) {
      final red = Paint()..color = const Color(0xFFE04B5A);
      canvas.drawCircle(Offset(s * .50, s * .47), s * .045, red);
      canvas.drawCircle(Offset(s * .36, s * .47), s * .026, red);
      canvas.drawCircle(Offset(s * .64, s * .47), s * .026, red);
    }

    if (isKiller) {
      final mask = Paint()..color = const Color(0xCC111217);
      canvas.drawRect(Rect.fromLTWH(s * .27, s * .40, s * .46, s * .17), mask);
    }

    final rim = Paint()
      ..color = accent.withOpacity(.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .018;
    canvas.drawCircle(c, s * .48, rim);
  }

  @override
  bool shouldRepaint(covariant _PortraitPainter oldDelegate) =>
      oldDelegate.female != female ||
      oldDelegate.special != special ||
      oldDelegate.accent != accent;
}

import 'package:flutter/material.dart';

/// A lightweight, asset-free portrait component for the scenario table.
///
/// It deliberately uses fictional faces and layered lighting rather than
/// celebrity likenesses. Real portrait assets can later replace the portrait
/// layer without changing the game UI API.
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

  IconData get _icon {
    if (role == 'دلقک' || role == 'جوکر') return Icons.sentiment_very_dissatisfied_rounded;
    if (role == 'زامبی') return Icons.coronavirus_rounded;
    if (role == 'قاتل مستقل') return Icons.visibility_off_rounded;
    if (female) return Icons.face_3_rounded;
    return Icons.face_rounded;
  }

  List<Color> get _lighting {
    if (role == 'دلقک' || role == 'جوکر') {
      return const [Color(0xFF5E2B70), Color(0xFF17121D)];
    }
    if (role == 'زامبی') {
      return const [Color(0xFF48664D), Color(0xFF111714)];
    }
    if (role == 'قاتل مستقل') {
      return const [Color(0xFF4A1F2B), Color(0xFF100D12)];
    }
    if (role == 'مافیا' || role == 'پدرخوانده') {
      return const [Color(0xFF354052), Color(0xFF0E1118)];
    }
    if (role == 'دکتر' || role == 'کارآگاه' || role == 'محافظ') {
      return const [Color(0xFF3D6178), Color(0xFF111A20)];
    }
    return const [Color(0xFF52677A), Color(0xFF151B21)];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = alive ? 1.0 : 0.38;
    return Opacity(
      opacity: effectiveOpacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _lighting,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(2, 5),
              color: Color(0x66000000),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1.2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * .10,
              left: size * .13,
              child: Container(
                width: size * .25,
                height: size * .16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size),
                  color: Colors.white.withValues(alpha: .16),
                ),
              ),
            ),
            Icon(_icon, size: size * .52, color: Colors.white.withValues(alpha: .92)),
            if (_special)
              Positioned(
                right: size * .03,
                bottom: size * .02,
                child: Container(
                  padding: EdgeInsets.all(size * .055),
                  decoration: const BoxDecoration(
                    color: Color(0xDD0E0E12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, size: size * .18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

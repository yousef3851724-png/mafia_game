import 'package:flutter/material.dart';

/// Photographic character avatar used throughout Mafia Radical.
///
/// Each role maps to a distinct portrait so the table never falls back to a
/// toy/cartoon character during normal operation. The local vector painter is
/// retained only as a network-failure fallback.
class RealisticAvatar extends StatelessWidget {
  final String role;
  final bool female;
  final double size;

  const RealisticAvatar({
    super.key,
    required this.role,
    this.female = false,
    this.size = 54,
  });

  Color get _accent {
    if (role == 'دلقک' || role == 'جوکر') return const Color(0xFFB56BE8);
    if (role == 'زامبی') return const Color(0xFF78A87B);
    if (role == 'قاتل مستقل') return const Color(0xFFB34B63);
    if (role == 'مافیا' || role == 'پدرخوانده') return const Color(0xFF7888A3);
    if (role == 'دکتر' || role == 'محافظ') return const Color(0xFF69A8C7);
    return const Color(0xFF9DB1C4);
  }

  String get _portraitUrl {
    // Pravatar provides photographic portraits suitable for fictional game
    // avatars. The ids are deliberately fixed so every role is stable.
    final femaleIds = <String, int>{
      'شهروند': 47,
      'دکتر': 49,
      'بازپرس': 45,
      'کارآگاه': 44,
      'مافیا': 43,
      'پدرخوانده': 42,
      'دلقک': 41,
      'جوکر': 40,
      'زامبی': 39,
      'قاتل مستقل': 38,
      'محافظ': 37,
      'تکاور': 36,
    };
    final maleIds = <String, int>{
      'شهروند': 12,
      'دکتر': 13,
      'بازپرس': 14,
      'کارآگاه': 15,
      'مافیا': 16,
      'پدرخوانده': 17,
      'دلقک': 18,
      'جوکر': 19,
      'زامبی': 20,
      'قاتل مستقل': 21,
      'محافظ': 22,
      'تکاور': 23,
    };
    final id = (female ? femaleIds : maleIds)[role] ?? (female ? 47 : 12);
    return 'https://i.pravatar.cc/256?img=$id';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: .24), width: 1.2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(2, 5),
            color: Color(0x66000000),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          _portraitUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => _FallbackAvatar(
            role: role,
            female: female,
            size: size,
            accent: _accent,
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _AvatarLoading(accent: _accent);
          },
        ),
      ),
    );
  }
}

class _AvatarLoading extends StatelessWidget {
  final Color accent;
  const _AvatarLoading({required this.accent});

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xFF11151B),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
      );
}

class _FallbackAvatar extends StatelessWidget {
  final String role;
  final bool female;
  final double size;
  final Color accent;

  const _FallbackAvatar({
    required this.role,
    required this.female,
    required this.size,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF11151B),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: size * .62,
        color: accent.withValues(alpha: .85),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/widgets/avatar_frame_widget.dart';

/// Role portrait. Network photography is attempted first; the packaged Radical
/// artwork is always available as an offline fallback so the avatar cannot be empty.
class RealisticAvatar extends StatelessWidget {
  final String role;
  final bool female;
  final double size;
  final FrameType? frameType;
  final bool isAlive;

  const RealisticAvatar({super.key, required this.role, this.female = false, this.size = 54, this.frameType, this.isAlive = true});

  String get _portraitUrl {
    final femaleIds = <String, int>{'شهروند': 47, 'دکتر': 49, 'بازپرس': 45, 'کارآگاه': 44, 'مافیا': 43, 'پدرخوانده': 42, 'دلقک': 41, 'جوکر': 40, 'زامبی': 39, 'قاتل مستقل': 38, 'محافظ': 37, 'تکاور': 36};
    final maleIds = <String, int>{'شهروند': 12, 'دکتر': 13, 'بازپرس': 14, 'کارآگاه': 15, 'مافیا': 16, 'پدرخوانده': 17, 'دلقک': 18, 'جوکر': 19, 'زامبی': 20, 'قاتل مستقل': 21, 'محافظ': 22, 'تکاور': 23};
    final id = (female ? femaleIds : maleIds)[role] ?? (female ? 47 : 12);
    return 'https://i.pravatar.cc/256?img=$id';
  }

  String? get _fallbackAsset {
    switch (role) {
      case 'کارآگاه':
      case 'بازپرس':
        return 'assets/images/avatar_detective.svg';
      case 'مافیا':
      case 'پدرخوانده':
      case 'قاتل مستقل':
        return 'assets/images/avatar_noir.svg';
      case 'دلقک':
      case 'جوکر':
        return 'assets/images/avatar_crimson.svg';
      case 'زامبی':
        return 'assets/images/avatar_shadow.svg';
      default:
        return 'assets/images/avatar_gold.svg';
    }
  }

  FrameType get _roleFrame {
    if (frameType != null) return frameType!;
    switch (role) {
      case 'مافیا':
      case 'پدرخوانده':
      case 'قاتل مستقل':
      case 'زامبی':
        return FrameType.fire;
      case 'کارآگاه':
      case 'بازپرس':
        return FrameType.lightning;
      case 'دلقک':
      case 'جوکر':
        return FrameType.neon;
      default:
        return FrameType.gold;
    }
  }

  @override
  Widget build(BuildContext context) => AvatarFrameWidget(
        size: size,
        frameType: _roleFrame,
        isAlive: isAlive,
        fallbackInitial: role.isNotEmpty ? role : '?',
        imageUrl: _portraitUrl,
        fallbackAsset: _fallbackAsset,
      );
}

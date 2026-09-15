import 'package:flutter/material.dart';

import '../../core/widgets/avatar_frame_widget.dart';

/// Photographic character avatar used throughout Mafia Radical.
///
/// Every character uses a fixed photographic portrait and the app's native
/// Radical avatar-frame system. The local fallback is only used when a
/// portrait cannot be loaded.
class RealisticAvatar extends StatelessWidget {
  final String role;
  final bool female;
  final double size;
  final FrameType frameType;
  final bool isAlive;

  const RealisticAvatar({
    super.key,
    required this.role,
    this.female = false,
    this.size = 54,
    this.frameType = FrameType.gold,
    this.isAlive = true,
  });

  String get _portraitUrl {
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
    return AvatarFrameWidget(
      size: size,
      frameType: frameType,
      isAlive: isAlive,
      fallbackInitial: role.isNotEmpty ? role : '?',
      imageUrl: _portraitUrl,
    );
  }
}

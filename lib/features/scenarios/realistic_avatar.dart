import 'package:flutter/material.dart';
import '../../core/models/radical_avatar_catalog.dart';
import '../../core/widgets/avatar_frame_widget.dart';

/// آواتار اصلی رادیکال.
/// وقتی avatarId مشخص باشد، فقط دارایی محلی همان آواتار استفاده می‌شود
/// تا نمایش آواتارهای رادیکال به شبکه یا سرویس شخص ثالث وابسته نباشد.
class RealisticAvatar extends StatelessWidget {
  final String role;
  final bool female;
  final double size;
  final FrameType? frameType;
  final bool isAlive;
  final String? avatarId;

  const RealisticAvatar({
    super.key,
    required this.role,
    this.female = false,
    this.size = 54,
    this.frameType,
    this.isAlive = true,
    this.avatarId,
  });

  RadicalAvatarAsset? get _catalogAvatar {
    if (avatarId == null || avatarId!.isEmpty) return null;
    return RadicalAvatarCatalog.byId(avatarId!);
  }

  static const Map<String, int> _femaleAvatarByRole = <String, int>{
    'دکتر': 42, 'بازپرس': 33, 'کارآگاه': 66, 'مافیا': 22,
    'پدرخوانده': 60, 'قاتل': 38, 'جوکر': 12, 'زامبی': 55,
    'قاتل مستقل': 36, 'محافظ': 62, 'شهروند': 46,
  };
  static const Map<String, int> _maleAvatarByRole = <String, int>{
    'دکتر': 23, 'بازپرس': 35, 'کارآگاه': 30, 'مافیا': 32,
    'پدرخوانده': 56, 'قاتل': 61, 'جوکر': 48, 'زامبی': 63,
    'قاتل مستقل': 10, 'محافظ': 45, 'شهروند': 1,
  };
  static const List<int> _femalePool = <int>[
    2, 4, 7, 9, 12, 14, 17, 19, 22, 25, 28, 31, 33, 36, 38,
    42, 44, 46, 49, 52, 55, 58, 60, 62, 64, 66,
  ];
  static const List<int> _malePool = <int>[
    1, 3, 5, 6, 8, 10, 11, 13, 15, 16, 18, 20, 21, 23, 24, 26, 27, 29, 30,
    32, 34, 35, 37, 39, 40, 41, 43, 45, 47, 48, 50, 51, 53, 54, 56, 57, 59,
    61, 63, 65, 67, 68, 69, 70,
  ];

  String get _localPortraitAsset {
    final byRole = female ? _femaleAvatarByRole : _maleAvatarByRole;
    final pool = female ? _femalePool : _malePool;
    final sum = role.codeUnits.fold<int>(0, (a, c) => a + c);
    final n = byRole[role] ?? pool[sum % pool.length];
    return 'assets/avatars/set_70/avatar_${n.toString().padLeft(2, '0')}.png';
  }

  String? get _fallbackAsset => _localPortraitAsset;

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
  Widget build(BuildContext context) {
    final catalogAvatar = _catalogAvatar;
    return AvatarFrameWidget(
      size: size,
      frameType: _roleFrame,
      isAlive: isAlive,
      fallbackInitial: (catalogAvatar?.displayNameFa ?? role).isNotEmpty
          ? (catalogAvatar?.displayNameFa ?? role)
          : '?',
      // Catalog avatars are local-only. Legacy role-based avatars may still
      // use the existing network source when no catalog id is supplied.
      imageUrl: null,
      fallbackAsset: catalogAvatar?.assetPath ?? _fallbackAsset,
    );
  }
}

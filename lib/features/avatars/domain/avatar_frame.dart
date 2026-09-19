import 'package:flutter/material.dart';

enum AvatarFrameTier {
  vassal, knight, duke, sultan, emperor, simorgh, ahriman,
}

extension FrameTierInfo on AvatarFrameTier {
  String get displayName {
    const names = ['وسیل', 'شوالیه', 'دوک', 'سلطان', 'امپراطور', 'سیمرغ', 'اهریمن'];
    return names[index];
  }

  Color get frameColor {
    const colors = [
      Color(0xFFF5F5F5), Color(0xFF4CAF50), Color(0xFF2196F3),
      Color(0xFF9C27B0), Color(0xFFFFD700), Color(0xFFFF5722),
      Color(0xFF1A1A1A),
    ];
    return colors[index];
  }

  double get ringWidth => [4, 5, 6, 7, 8, 10, 12][index].toDouble();
}

class AvatarFrame {
  final String id;
  final AvatarFrameTier tier;
  final String characterName;
  final String description;
  final bool unlocked;

  AvatarFrame({
    required this.id,
    required this.tier,
    required this.characterName,
    required this.description,
    this.unlocked = false,
  });
}

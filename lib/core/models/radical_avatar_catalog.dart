import 'package:flutter/material.dart';  
  
/// سطح‌بندی فریم آواتار در پروژه مافیا رادیکال  
/// هر سطح رنگ‌بندی، درخشش و هزینه‌ی الماس مخصوص به خودش را دارد  
enum RadicalFrameTier {  
  none,  
  bronze,  
  silver,  
  gold,  
  platinum,  
  diamond,  
  legendary, // سیمرغ - ویژه رویدادها  
}  
  
class RadicalFrameData {  
  final RadicalFrameTier tier;  
  final String displayNameFa;  
  final List<Color> gradientColors;  
  final Color glowColor;  
  final int diamondCost;  
  final bool isAnimated;  
  final IconData? badgeIcon;  
  
  const RadicalFrameData({  
    required this.tier,  
    required this.displayNameFa,  
    required this.gradientColors,  
    required this.glowColor,  
    required this.diamondCost,  
    this.isAnimated = false,  
    this.badgeIcon,  
  });  
  
  static const Map<RadicalFrameTier, RadicalFrameData> catalog = {  
    RadicalFrameTier.none: RadicalFrameData(  
      tier: RadicalFrameTier.none,  
      displayNameFa: 'بدون فریم',  
      gradientColors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],  
      glowColor: Colors.transparent,  
      diamondCost: 0,  
    ),  
    RadicalFrameTier.bronze: RadicalFrameData(  
      tier: RadicalFrameTier.bronze,  
      displayNameFa: 'برنزی',  
      gradientColors: [Color(0xFFCD7F32), Color(0xFF8B5A2B)],  
      glowColor: Color(0x55CD7F32),  
      diamondCost: 50,  
      badgeIcon: Icons.shield_outlined,  
    ),  
    RadicalFrameTier.silver: RadicalFrameData(  
      tier: RadicalFrameTier.silver,  
      displayNameFa: 'نقره‌ای',  
      gradientColors: [Color(0xFFD7D7D7), Color(0xFF9E9E9E)],  
      glowColor: Color(0x55D7D7D7),  
      diamondCost: 150,  
      badgeIcon: Icons.shield,  
    ),  
    RadicalFrameTier.gold: RadicalFrameData(  
      tier: RadicalFrameTier.gold,  
      displayNameFa: 'طلایی',  
      gradientColors: [Color(0xFFFFD700), Color(0xFFB8860B)],  
      glowColor: Color(0x77FFD700),  
      diamondCost: 400,  
      badgeIcon: Icons.local_fire_department,  
    ),  
    RadicalFrameTier.platinum: RadicalFrameData(  
      tier: RadicalFrameTier.platinum,  
      displayNameFa: 'پلاتینیوم',  
      gradientColors: [Color(0xFFE5E4E2), Color(0xFF7C7C7C)],  
      glowColor: Color(0x77E5E4E2),  
      diamondCost: 800,  
      badgeIcon: Icons.diamond_outlined,  
    ),  
    RadicalFrameTier.diamond: RadicalFrameData(  
      tier: RadicalFrameTier.diamond,  
      displayNameFa: 'الماسی',  
      gradientColors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],  
      glowColor: Color(0x8800E5FF),  
      diamondCost: 1500,  
      isAnimated: true,  
      badgeIcon: Icons.diamond,  
    ),  
    RadicalFrameTier.legendary: RadicalFrameData(  
      tier: RadicalFrameTier.legendary,  
      displayNameFa: 'سیمرغ افسانه‌ای',  
      gradientColors: [  
        Color(0xFFFF0000),  
        Color(0xFFFFD700),  
        Color(0xFF000000),  
      ],  
      glowColor: Color(0x99FF0000),  
      diamondCost: 5000,  
      isAnimated: true,  
      badgeIcon: Icons.auto_awesome,  
    ),  
  };  
  
  static RadicalFrameData of(RadicalFrameTier tier) => catalog[tier]!;  
}  
  
/// یک آیتم آواتار ثابت (asset) در کاتالوگ بازی  
class RadicalAvatarAsset {  
  final String id;  
  final String assetPath; // مثال: assets/avatars/avatar_01.png  
  final String displayNameFa;  
  final bool isPremium;  
  
  const RadicalAvatarAsset({  
    required this.id,  
    required this.assetPath,  
    required this.displayNameFa,  
    this.isPremium = false,  
  });  
}  
  
/// کاتالوگ نمونه‌ی آواتارهای از پیش طراحی‌شده.  
/// مسیرها را با فایل‌های واقعی asset خودت جایگزین کن  
/// و در pubspec.yaml زیر assets/ رجیستر کن.  
class RadicalAvatarCatalog {  
  static const List<RadicalAvatarAsset> avatars = [  
    RadicalAvatarAsset(  
      id: 'a01',  
      assetPath: 'assets/avatars/avatar_01.png',  
      displayNameFa: 'سیمرغ',  
    ),  
    RadicalAvatarAsset(  
      id: 'a02',  
      assetPath: 'assets/avatars/avatar_02.png',  
      displayNameFa: 'اژدها',  
    ),  
    RadicalAvatarAsset(  
      id: 'a03',  
      assetPath: 'assets/avatars/avatar_03.png',  
      displayNameFa: 'رستم',  
    ),  
    RadicalAvatarAsset(  
      id: 'a04',  
      assetPath: 'assets/avatars/avatar_04.png',  
      displayNameFa: 'دیو سپید',  
      isPremium: true,  
    ),  
    RadicalAvatarAsset(  
      id: 'a05',  
      assetPath: 'assets/avatars/avatar_05.png',  
      displayNameFa: 'کاوه آهنگر',  
    ),  
    RadicalAvatarAsset(  
      id: 'a06',  
      assetPath: 'assets/avatars/avatar_06.png',  
      displayNameFa: 'ضحاک',  
      isPremium: true,  
    ),  
  ];  
  
  static RadicalAvatarAsset byId(String id) => avatars.firstWhere(  
        (a) => a.id == id,  
        orElse: () => avatars.first,  
      );  
}  
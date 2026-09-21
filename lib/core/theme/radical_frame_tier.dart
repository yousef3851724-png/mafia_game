import '../models/app_models.dart';

enum RadicalFrameTier {
  none(
    name: 'بدون فریم',
    displayName: 'None',
    diamondPrice: 0,
    diamondType: null,
    description: 'فریم پیش‌فرض',
    color: 0xFFFFFFFF,
  ),
  bronze(
    name: 'برنز',
    displayName: 'Bronze',
    diamondPrice: 50,
    diamondType: DiamondType.blue,
    description: 'فریم برنزی ساده',
    color: 0xFFCD7F32,
  ),
  silver(
    name: 'نقره',
    displayName: 'Silver',
    diamondPrice: 100,
    diamondType: DiamondType.blue,
    description: 'فریم نقره‌ای درخشان',
    color: 0xFFC0C0C0,
  ),
  gold(
    name: 'طلا',
    displayName: 'Gold',
    diamondPrice: 250,
    diamondType: DiamondType.radical,
    description: 'فریم طلایی فاخر',
    color: 0xFFFFD700,
  ),
  platinum(
    name: 'پلاتین',
    displayName: 'Platinum',
    diamondPrice: 500,
    diamondType: DiamondType.teen,
    description: 'فریم پلاتینی نایاب',
    color: 0xFFE5E4E2,
  ),
  diamond(
    name: 'الماس',
    displayName: 'Diamond',
    diamondPrice: 1000,
    diamondType: DiamondType.adult,
    description: 'فریم الماسی افسانه‌ای',
    color: 0xFF00D9FF,
  ),
  legendary(
    name: 'افسانه‌ای',
    displayName: 'Legendary',
    diamondPrice: 2500,
    diamondType: DiamondType.adult,
    description: 'فریم افسانه‌ای ابدی',
    color: 0xFFFF00FF,
  );

  final String name;
  final String displayName;
  final int diamondPrice;
  final DiamondType? diamondType;
  final String description;
  final int color;

  const RadicalFrameTier({
    required this.name,
    required this.displayName,
    required this.diamondPrice,
    required this.diamondType,
    required this.description,
    required this.color,
  });

  static RadicalFrameTier? getByName(String value) {
    try {
      return RadicalFrameTier.values.firstWhere(
        (tier) => tier.name == value || tier.displayName == value,
      );
    } catch (_) {
      return null;
    }
  }

  static RadicalFrameTier? getByIndex(int idx) {
    if (idx < 0 || idx >= RadicalFrameTier.values.length) return null;
    return RadicalFrameTier.values[idx];
  }

  RadicalFrameTier? get nextTier {
    if (index >= RadicalFrameTier.legendary.index) return null;
    return RadicalFrameTier.getByIndex(index + 1);
  }

  RadicalFrameTier? get previousTier {
    if (index <= RadicalFrameTier.none.index) return null;
    return RadicalFrameTier.getByIndex(index - 1);
  }

  bool get isPremium => diamondPrice > 0;
  String get label => name;
  String get desc => description;
}

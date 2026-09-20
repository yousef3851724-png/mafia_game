enum RadicalFrameTier {
  none(
    index: 0,
    name: 'بدون فریم',
    displayName: 'None',
    diamondPrice: 0,
    description: 'فریم پیش‌فرض',
    color: 0xFFFFFFFF,
  ),
  bronze(
    index: 1,
    name: 'برنز',
    displayName: 'Bronze',
    diamondPrice: 50,
    description: 'فریم برنزی ساده',
    color: 0xFFCD7F32,
  ),
  silver(
    index: 2,
    name: 'نقره',
    displayName: 'Silver',
    diamondPrice: 100,
    description: 'فریم نقره‌ای درخشان',
    color: 0xFFC0C0C0,
  ),
  gold(
    index: 3,
    name: 'طلا',
    displayName: 'Gold',
    diamondPrice: 250,
    description: 'فریم طلایی فاخر',
    color: 0xFFFFD700,
  ),
  platinum(
    index: 4,
    name: 'پلاتین',
    displayName: 'Platinum',
    diamondPrice: 500,
    description: 'فریم پلاتینی نایاب',
    color: 0xFFE5E4E2,
  ),
  diamond(
    index: 5,
    name: 'الماس',
    displayName: 'Diamond',
    diamondPrice: 1000,
    description: 'فریم الماسی افسانه‌ای',
    color: 0xFF00D9FF,
  ),
  legendary(
    index: 6,
    name: 'افسانه‌ای',
    displayName: 'Legendary',
    diamondPrice: 2500,
    description: 'فریم افسانه‌ای ابدی',
    color: 0xFFFF00FF,
  );

  final int index;
  final String name;
  final String displayName;
  final int diamondPrice;
  final String description;
  final int color;

  const RadicalFrameTier({
    required this.index,
    required this.name,
    required this.displayName,
    required this.diamondPrice,
    required this.description,
    required this.color,
  });

  static RadicalFrameTier? getByName(String name) {
    try {
      return RadicalFrameTier.values.firstWhere(
        (tier) => tier.name == name || tier.displayName == name,
      );
    } catch (_) {
      return null;
    }
  }

  static RadicalFrameTier? getByIndex(int idx) {
    try {
      return RadicalFrameTier.values.firstWhere((tier) => tier.index == idx);
    } catch (_) {
      return null;
    }
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

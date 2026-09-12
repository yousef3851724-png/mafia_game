/// کاتالوگ رسمی سناریوهای مافیا رادیکال.
///
/// قوانین ظرفیت و حالت بازی در همین لایه مشخص می‌شوند تا لابی نتواند
/// سناریوی ۲۰ نفره را به امتیازی تبدیل کند.
enum ScenarioFamily { classic, advanced, modern, custom }

enum ScenarioMode { friendly, ranked }

class ScenarioDefinition {
  final String id;
  final String title;
  final String description;
  final ScenarioFamily family;
  final int minPlayers;
  final int maxPlayers;
  final List<String> roles;
  final bool supportsCustomDeck;
  final Set<ScenarioMode> allowedModes;

  const ScenarioDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.family,
    required this.minPlayers,
    required this.maxPlayers,
    required this.roles,
    required this.allowedModes,
    this.supportsCustomDeck = false,
  });

  bool supportsMode(ScenarioMode mode) => allowedModes.contains(mode);
}

class ScenarioCatalog {
  ScenarioCatalog._();

  static const List<ScenarioDefinition> all = [
    ScenarioDefinition(
      id: 'classic',
      title: 'کلاسیک',
      description: 'سناریوی پایه برای بازی‌های استاندارد دوستانه.',
      family: ScenarioFamily.classic,
      minPlayers: 6,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'دکتر', 'کارآگاه'],
      supportsCustomDeck: true,
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'jack',
      title: 'جک',
      description: 'سناریوی پیشرفته برای بازی دوستانه.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'جک', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'joker',
      title: 'جوکر',
      description: 'سناریوی مدرن با نقش مستقل جوکر.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'جوکر', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'prosecutor',
      title: 'دادستان',
      description: 'سناریوی پیشرفته برای بازی دوستانه.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'دادستان', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'zombie_20',
      title: 'زامبی ۲۰ نفره',
      description: 'سناریوی بزرگ ۲۰ نفره که فقط در حالت دوستانه فعال است.',
      family: ScenarioFamily.modern,
      minPlayers: 12,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'زامبی', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'serial_killer',
      title: 'قاتل مستقل',
      description: 'سناریوی دوستانه با یک نقش مستقل و شرط پیروزی جداگانه.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'قاتل مستقل', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'investigator_10',
      title: 'بازپرس',
      description: 'سناریوی امتیازی استاندارد برای لابی ۱۰ نفره.',
      family: ScenarioFamily.advanced,
      minPlayers: 10,
      maxPlayers: 10,
      roles: ['مافیا', 'شهروند', 'بازپرس', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.ranked},
    ),
    ScenarioDefinition(
      id: 'commando_10',
      title: 'تکاور',
      description: 'سناریوی امتیازی ۱۰ نفره با نقش تکاور.',
      family: ScenarioFamily.advanced,
      minPlayers: 10,
      maxPlayers: 10,
      roles: ['مافیا', 'شهروند', 'تکاور', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.ranked},
    ),
    ScenarioDefinition(
      id: 'negotiator_10',
      title: 'مذاکره',
      description: 'سناریوی امتیازی ۱۰ نفره با تمرکز بر مذاکره.',
      family: ScenarioFamily.modern,
      minPlayers: 10,
      maxPlayers: 10,
      roles: ['مافیا', 'شهروند', 'مذاکره', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.ranked},
    ),
    ScenarioDefinition(
      id: 'custom',
      title: 'سناریوی دست‌ساز',
      description: 'ساخت Deck اختصاصی توسط سازنده لابی؛ به‌صورت پیش‌فرض دوستانه.',
      family: ScenarioFamily.custom,
      minPlayers: 6,
      maxPlayers: 20,
      roles: [],
      supportsCustomDeck: true,
      allowedModes: {ScenarioMode.friendly},
    ),
  ];

  static ScenarioDefinition? byId(String id) {
    for (final scenario in all) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }

  static List<ScenarioDefinition> forMode(ScenarioMode mode) =>
      all.where((scenario) => scenario.supportsMode(mode)).toList(growable: false);

  static bool canStart({
    required String scenarioId,
    required ScenarioMode mode,
    required int playerCount,
  }) {
    final scenario = byId(scenarioId);
    if (scenario == null || !scenario.supportsMode(mode)) return false;
    return playerCount >= scenario.minPlayers &&
        playerCount <= scenario.maxPlayers;
  }
}

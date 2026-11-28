/// کاتالوگ رسمی و کامل سناریوهای مافیا رادیکال.
///
/// سناریوهای دوستانه برای بازی آزاد هستند و سناریوهای ۱۰ نفره
/// می‌توانند در حالت Ranked نیز فعال باشند.
enum ScenarioFamily { classic, advanced, modern, custom, hunter }

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
      description: 'سناریوی پیشرفته با نقش جک در کنار تیم شهروند و مافیا.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'جک', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'joker',
      title: 'جوکر',
      description: 'سناریوی مدرن با نقش مستقل جوکر و هدف پیروزی جداگانه.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'جوکر', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'prosecutor',
      title: 'دادستان',
      description: 'سناریوی پیشرفته با نقش دادستان و فضای حقوقی بازی.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'دادستان', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'zombie_20',
      title: 'زامبی ۲۰ نفره',
      description: 'سناریوی بزرگ و مدرن برای جمع‌های ۱۲ تا ۲۰ نفره.',
      family: ScenarioFamily.modern,
      minPlayers: 12,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'زامبی', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'hunter_15_20',
      title: 'شکارچی',
      description: 'ساید مستقل شکارچی با ترکیب بالانس‌شده و متغیر از ۱۵ تا ۲۰ نفر؛ تک‌تیرانداز، ردیاب و شکارچی ارشد.',
      family: ScenarioFamily.hunter,
      minPlayers: 15,
      maxPlayers: 20,
      roles: ['مافیا', 'پدرخوانده', 'تک‌تیرانداز', 'ردیاب', 'شکارچی ارشد', 'دکتر', 'کارآگاه', 'محافظ', 'شهردار', 'روانشناس', 'تکاور', 'شهروند'],
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
      id: 'godfather',
      title: 'پدرخوانده',
      description: 'سناریوی مافیایی با تمرکز بیشتر روی رهبر تیم مافیا.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['پدرخوانده', 'مافیا', 'شهروند', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'guardian',
      title: 'محافظ',
      description: 'سناریوی دفاعی با نقش محافظ در تیم شهروند.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'محافظ', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'mayor',
      title: 'شهردار',
      description: 'سناریوی اجتماعی با نقش ویژه شهردار در رأی‌گیری.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'شهردار', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'sniper',
      title: 'تک‌تیرانداز',
      description: 'سناریوی مدرن با نقش تک‌تیرانداز و قابلیت ویژه شبانه.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'تک‌تیرانداز', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'psychologist',
      title: 'روانشناس',
      description: 'سناریوی پیشرفته با نقش روانشناس برای کنترل روند بازی.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'روانشناس', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'duel',
      title: 'دوئل',
      description: 'سناریوی رقابتی دوستانه با دو نقش ویژه و بازی سریع‌تر.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 16,
      roles: ['مافیا', 'شهروند', 'دوئلیست', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly},
    ),
    ScenarioDefinition(
      id: 'investigator_10',
      title: 'بازپرس',
      description: 'سناریوی ۱۰ نفره با نقش بازپرس؛ مناسب دوستانه و امتیازی.',
      family: ScenarioFamily.advanced,
      minPlayers: 10,
      maxPlayers: 10,
      roles: ['مافیا', 'شهروند', 'بازپرس', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly, ScenarioMode.ranked},
    ),
    ScenarioDefinition(
      id: 'commando_10',
      title: 'تکاور',
      description: 'سناریوی ۱۰ نفره با نقش تکاور؛ مناسب دوستانه و امتیازی.',
      family: ScenarioFamily.advanced,
      minPlayers: 10,
      maxPlayers: 10,
      roles: ['مافیا', 'شهروند', 'تکاور', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly, ScenarioMode.ranked},
    ),
    ScenarioDefinition(
      id: 'negotiator_10',
      title: 'مذاکره',
      description: 'سناریوی ۱۰ نفره با نقش مذاکره؛ مناسب دوستانه و امتیازی.',
      family: ScenarioFamily.modern,
      minPlayers: 10,
      maxPlayers: 10,
      roles: ['مافیا', 'شهروند', 'مذاکره', 'دکتر', 'کارآگاه'],
      allowedModes: {ScenarioMode.friendly, ScenarioMode.ranked},
    ),
    ScenarioDefinition(
      id: 'custom',
      title: 'سناریوی دست‌ساز',
      description: 'Deck اختصاصی سازنده لابی؛ فقط دوستانه و با هزینه ۵۰ الماس.',
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

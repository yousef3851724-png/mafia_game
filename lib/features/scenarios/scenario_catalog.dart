/// کاتالوگ رسمی سناریوهای مافیا رادیکال.
///
/// این فایل فقط قوانین سطح بازی را نگه می‌دارد تا انتخاب سناریو از منطق
/// اجرایی بازی جدا باشد و بعداً سناریوهای سفارشی هم به‌سادگی اضافه شوند.
enum ScenarioFamily { classic, advanced, modern, custom }

class ScenarioDefinition {
  final String id;
  final String title;
  final String description;
  final ScenarioFamily family;
  final int minPlayers;
  final int maxPlayers;
  final List<String> roles;
  final bool supportsCustomDeck;

  const ScenarioDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.family,
    required this.minPlayers,
    required this.maxPlayers,
    required this.roles,
    this.supportsCustomDeck = false,
  });
}

class ScenarioCatalog {
  ScenarioCatalog._();

  static const List<ScenarioDefinition> all = [
    ScenarioDefinition(
      id: 'classic',
      title: 'کلاسیک',
      description: 'سناریوی پایه برای بازی‌های استاندارد.',
      family: ScenarioFamily.classic,
      minPlayers: 6,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'دکتر', 'کارآگاه'],
      supportsCustomDeck: true,
    ),
    ScenarioDefinition(
      id: 'jack',
      title: 'جک',
      description: 'سناریوی پیشرفته با نقش جک و ترکیب متعادل گروه‌ها.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'جک', 'دکتر', 'کارآگاه'],
    ),
    ScenarioDefinition(
      id: 'joker',
      title: 'جوکر',
      description: 'سناریوی مدرن با نقش مستقل جوکر و هدف اختصاصی.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'جوکر', 'دکتر', 'کارآگاه'],
    ),
    ScenarioDefinition(
      id: 'prosecutor',
      title: 'دادستان',
      description: 'سناریوی پیشرفته با نقش دادستان و تصمیم‌های ویژه.',
      family: ScenarioFamily.advanced,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'دادستان', 'دکتر', 'کارآگاه'],
    ),
    ScenarioDefinition(
      id: 'zombie_20',
      title: 'زامبی ۲۰ نفره',
      description: 'سناریوی مدرن برای لابی‌های بزرگ تا ۲۰ بازیکن.',
      family: ScenarioFamily.modern,
      minPlayers: 12,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'زامبی', 'دکتر', 'کارآگاه'],
    ),
    ScenarioDefinition(
      id: 'serial_killer',
      title: 'قاتل مستقل',
      description: 'یک نقش مستقل با شرط پیروزی جدا از دو گروه اصلی.',
      family: ScenarioFamily.modern,
      minPlayers: 8,
      maxPlayers: 20,
      roles: ['مافیا', 'شهروند', 'قاتل مستقل', 'دکتر', 'کارآگاه'],
    ),
    ScenarioDefinition(
      id: 'custom',
      title: 'سناریوی دست‌ساز',
      description: 'ساخت Deck اختصاصی توسط سازنده لابی.',
      family: ScenarioFamily.custom,
      minPlayers: 6,
      maxPlayers: 20,
      roles: [],
      supportsCustomDeck: true,
    ),
  ];

  static ScenarioDefinition? byId(String id) {
    for (final scenario in all) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }
}

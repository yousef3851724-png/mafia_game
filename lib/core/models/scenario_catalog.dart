class ScenarioDefinition {
  final String id;
  final String displayNameFa;
  final int minPlayers;
  final int maxPlayers;
  final int mafiaCount;
  final String descriptionFa;

  const ScenarioDefinition({
    required this.id,
    required this.displayNameFa,
    required this.minPlayers,
    required this.maxPlayers,
    required this.mafiaCount,
    this.descriptionFa = '',
  });
}

class ScenarioCatalog {
  ScenarioCatalog._();

  static const List<ScenarioDefinition> allScenarios = [
    ScenarioDefinition(
      id: 'classic',
      displayNameFa: 'کلاسیک',
      minPlayers: 6,
      maxPlayers: 12,
      mafiaCount: 2,
      descriptionFa: 'مافیا کلاسیک با نقش‌های پایه',
    ),
    ScenarioDefinition(
      id: 'advanced',
      displayNameFa: 'پیشرفته',
      minPlayers: 8,
      maxPlayers: 15,
      mafiaCount: 3,
      descriptionFa: 'با نقش‌های ویژه',
    ),
    ScenarioDefinition(
      id: 'quick',
      displayNameFa: 'سریع',
      minPlayers: 5,
      maxPlayers: 8,
      mafiaCount: 1,
      descriptionFa: 'بازی کوتاه',
    ),
  ];

  static ScenarioDefinition byId(String id) {
    return allScenarios.firstWhere(
      (s) => s.id == id,
      orElse: () => allScenarios.first,
    );
  }
}

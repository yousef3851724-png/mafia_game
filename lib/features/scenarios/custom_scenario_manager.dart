import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomScenario {
  final String id;
  final String ownerId;
  final String title;
  final int playerCount;
  final List<String> roles;
  final DateTime createdAt;

  const CustomScenario({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.playerCount,
    required this.roles,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'playerCount': playerCount,
        'roles': roles,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomScenario.fromJson(Map<String, dynamic> json) {
    return CustomScenario(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      playerCount: json['playerCount'] as int,
      roles: List<String>.from(json['roles'] as List<dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class DiamondManager {
  DiamondManager._();

  static const String _key = 'user_diamonds';
  static const int customScenarioCost = 50;
  static int _diamonds = 0;

  static int get diamonds => _diamonds;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _diamonds = prefs.getInt(_key) ?? 0;
  }

  static Future<void> setDiamonds(int amount) async {
    _diamonds = amount < 0 ? 0 : amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _diamonds);
  }

  static bool canCreateCustomScenario() => _diamonds >= customScenarioCost;

  static Future<bool> chargeCustomScenario() async {
    if (!canCreateCustomScenario()) return false;
    _diamonds -= customScenarioCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _diamonds);
    return true;
  }
}

class CustomScenarioManager {
  CustomScenarioManager._();

  static const String _storageKey = 'owned_custom_scenarios';

  static Future<List<CustomScenario>> loadOwned(String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final result = <CustomScenario>[];

    for (final item in raw) {
      try {
        final scenario = CustomScenario.fromJson(
          jsonDecode(item) as Map<String, dynamic>,
        );
        if (scenario.ownerId == ownerId) {
          result.add(scenario);
        }
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }

    return result;
  }

  static Future<CustomScenario?> create({
    required String ownerId,
    required String title,
    required int playerCount,
    required List<String> roles,
  }) async {
    final cleanTitle = title.trim();
    final cleanRoles = roles
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);

    if (ownerId.trim().isEmpty ||
        cleanTitle.isEmpty ||
        playerCount < 6 ||
        playerCount > 20 ||
        cleanRoles.length != playerCount ||
        !DiamondManager.canCreateCustomScenario()) {
      return null;
    }

    final charged = await DiamondManager.chargeCustomScenario();
    if (!charged) return null;

    final scenario = CustomScenario(
      id: '${DateTime.now().microsecondsSinceEpoch}_custom',
      ownerId: ownerId,
      title: cleanTitle,
      playerCount: playerCount,
      roles: cleanRoles,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    raw.add(jsonEncode(scenario.toJson()));
    await prefs.setStringList(_storageKey, raw);
    return scenario;
  }
}

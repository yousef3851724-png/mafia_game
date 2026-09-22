import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomScenario {
  final String id;
  final String ownerId;
  final String name;
  final int playerCount;
  final List<String> roles;
  final DateTime createdAt;

  const CustomScenario({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.playerCount,
    required this.roles,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'playerCount': playerCount,
        'roles': roles,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomScenario.fromJson(Map<String, dynamic> json) {
    return CustomScenario(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      playerCount: json['playerCount'] as int,
      roles: List<String>.from(json['roles'] as List<dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class DiamondManager {
  DiamondManager._();

  static const int creationCost = 50;
  static const String _balanceKey = 'radical_diamonds';
  static int _balance = 0;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_balanceKey) ?? 100;
  }

  static int get balance => _balance;

  static bool canCreateCustomScenario() => _balance >= creationCost;

  static Future<bool> chargeForCustomScenario() async {
    if (!canCreateCustomScenario()) return false;
    _balance -= creationCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, _balance);
    return true;
  }

  static Future<void> add(int amount) async {
    if (amount <= 0) return;
    _balance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, _balance);
  }
}

class CustomScenarioStore {
  CustomScenarioStore._();

  static const String _key = 'radical_custom_scenarios';

  static Future<List<CustomScenario>> loadForOwner(String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw
        .map((item) => CustomScenario.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            ))
        .where((item) => item.ownerId == ownerId)
        .toList(growable: false);
  }

  static Future<void> save(CustomScenario scenario) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(scenario.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> remove(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.removeWhere((item) {
      final data = jsonDecode(item) as Map<String, dynamic>;
      return data['id'] == scenarioId;
    });
    await prefs.setStringList(_key, raw);
  }

  static Future<bool> create({
    required String ownerId,
    required String name,
    required int playerCount,
    required List<String> roles,
  }) async {
    final cleanName = name.trim();
    final cleanRoles = roles
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);

    if (cleanName.isEmpty ||
        playerCount < 6 ||
        playerCount > 20 ||
        cleanRoles.length != playerCount ||
        !DiamondManager.canCreateCustomScenario()) {
      return false;
    }

    final scenario = CustomScenario(
      id: '${ownerId}_${DateTime.now().microsecondsSinceEpoch}',
      ownerId: ownerId,
      name: cleanName,
      playerCount: playerCount,
      roles: cleanRoles,
      createdAt: DateTime.now(),
    );

    try {
      await save(scenario);
      final charged = await DiamondManager.chargeForCustomScenario();
      if (charged) return true;

      await remove(scenario.id);
      return false;
    } catch (_) {
      await remove(scenario.id);
      return false;
    }
  }
}

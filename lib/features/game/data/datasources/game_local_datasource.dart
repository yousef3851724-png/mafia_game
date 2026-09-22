import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state_model.dart';

abstract class GameLocalDataSource {
  Future<void> savePlayerName(String name);
  String? getPlayerName();

  Future<void> saveLastRoom(String roomId);
  String? getLastRoom();

  Future<void> cacheGameState(GameStateModel state);
  GameStateModel? getCachedGameState();
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  static const _playerNameKey = 'game_player_name';
  static const _lastRoomKey = 'game_last_room';
  static const _stateKey = 'game_cached_state';

  final SharedPreferences prefs;

  const GameLocalDataSourceImpl(this.prefs);

  @override
  Future<void> savePlayerName(String name) async {
    await prefs.setString(_playerNameKey, name.trim());
  }

  @override
  String? getPlayerName() => prefs.getString(_playerNameKey);

  @override
  Future<void> saveLastRoom(String roomId) async {
    await prefs.setString(_lastRoomKey, roomId.trim());
  }

  @override
  String? getLastRoom() => prefs.getString(_lastRoomKey);

  @override
  Future<void> cacheGameState(GameStateModel state) async {
    await prefs.setString(_stateKey, jsonEncode(state.toJson()));
  }

  @override
  GameStateModel? getCachedGameState() {
    final raw = prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return GameStateModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

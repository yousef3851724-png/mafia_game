import '../models/game_state_model.dart';

abstract class GameLocalDataSource {
  Future<void> cacheLastGameState(List<PlayerModel> players);
  Future<List<PlayerModel>> getLastCachedGameState();
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  List<PlayerModel> _cachedPlayers = [];

  @override
  Future<void> cacheLastGameState(List<PlayerModel> players) async {
    _cachedPlayers = players;
  }

  @override
  Future<List<PlayerModel>> getLastCachedGameState() async {
    return _cachedPlayers;
  }
}

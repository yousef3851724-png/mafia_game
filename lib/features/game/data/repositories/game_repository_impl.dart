import '../../domain/entities/player.dart';
import '../../domain/repositories/i_game_repository.dart';
import '../datasources/game_local_datasource.dart';
import '../datasources/game_remote_datasource.dart';
import '../models/game_state_model.dart';

class GameRepositoryImpl implements IGameRepository {
  final GameRemoteDataSource remoteDataSource;
  final GameLocalDataSource localDataSource;

  GameRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<List<Player>> watchPlayers() async* {
    await for (final state in remoteDataSource.watchGameState()) {
      await localDataSource.cacheGameState(state);
      yield state.players.map((p) => p.toEntity()).toList(growable: false);
    }
  }

  @override
  Stream<Map<String, int>> watchVotes() async* {
    await for (final state in remoteDataSource.watchGameState()) {
      await localDataSource.cacheGameState(state);
      yield Map.unmodifiable(state.votes);
    }
  }

  @override
  Future<String> joinRoom(String roomId, String playerName) async {
    final cleanRoomId = roomId.trim();
    final cleanName = playerName.trim();

    if (cleanRoomId.isEmpty) throw ArgumentError('Room ID cannot be empty.');
    if (cleanName.isEmpty) throw ArgumentError('Player name cannot be empty.');

    await localDataSource.savePlayerName(cleanName);
    await localDataSource.saveLastRoom(cleanRoomId);

    return remoteDataSource.joinRoom(cleanRoomId, cleanName);
  }

  @override
  Future<void> submitVote(
    String roomId,
    String playerId,
    String option,
  ) {
    return remoteDataSource.submitVote(roomId, playerId, option);
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) {
    return remoteDataSource.leaveRoom(roomId, playerId);
  }

  @override
  Future<void> dispose() {
    return remoteDataSource.close();
  }
}

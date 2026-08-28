import '../../domain/entities/player.dart';
import '../../domain/repositories/i_game_repository.dart';
import '../datasources/game_remote_datasource.dart';
import '../datasources/game_local_datasource.dart';

class GameRepositoryImpl implements IGameRepository {
  final GameRemoteDataSource remoteDataSource;
  final GameLocalDataSource localDataSource;

  GameRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> connectToGame(String roomId, String playerId) async {
    await remoteDataSource.initSocket(roomId, playerId);
  }

  @override
  Stream<List<Player>> get playersStream => remoteDataSource.onPlayersUpdated;

  @override
  Stream<String> get phaseStream => remoteDataSource.onPhaseChanged;

  @override
  Future<void> joinRoom(String roomId, String playerName) async {
    await remoteDataSource.emitJoinRoom(roomId, playerName);
  }

  @override
  Future<void> submitVote(String roomId, String voterId, String targetPlayerId) async {
    await remoteDataSource.emitVote(roomId, voterId, targetPlayerId);
  }

  @override
  Future<void> disconnect() async {
    await remoteDataSource.closeSocket();
  }
}

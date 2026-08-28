import '../entities/player.dart';

abstract class IGameRepository {
  Future<void> connectToGame(String roomId, String playerId);
  Stream<List<Player>> get playersStream;
  Stream<String> get phaseStream;
  Future<void> joinRoom(String roomId, String playerName);
  Future<void> submitVote(String roomId, String voterId, String targetPlayerId);
  Future<void> disconnect();
}

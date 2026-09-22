import '../entities/player.dart';

abstract class IGameRepository {
  Stream<List<Player>> watchPlayers();

  Stream<Map<String, int>> watchVotes();

  Future<String> joinRoom(String roomId, String playerName);

  Future<void> submitVote(
    String roomId,
    String playerId,
    String option,
  );

  Future<void> leaveRoom(String roomId, String playerId);

  Future<void> dispose();
}

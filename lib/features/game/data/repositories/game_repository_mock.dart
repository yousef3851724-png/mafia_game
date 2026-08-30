// Mock implementation of IGameRepository for local simulation / UI testing.
// Usage: provide GameRepositoryMock to GameBloc (or GameModule) instead of real repository.
import 'dart:async';
import 'dart:math';

import '../../domain/entities/player.dart';
import '../../domain/repositories/i_game_repository.dart';

class GameRepositoryMock implements IGameRepository {
  // Internal state
  final List<Player> _players = [];
  final Map<String, int> _votes = {};

  // Stream controllers (broadcast so many listeners can subscribe)
  final StreamController<List<Player>> _playersController =
      StreamController<List<Player>>.broadcast();
  final StreamController<Map<String, int>> _votesController =
      StreamController<Map<String, int>>.broadcast();

  // Optional: simulate network latency (milliseconds)
  final int latencyMs;

  GameRepositoryMock({this.latencyMs = 300}) {
    // seed with a host so UI has something initially if desired
    final host = Player(id: 'host', name: 'Host', isHost: true);
    _players.add(host);
    _emitPlayers();
    _emitVotes();
  }

  // Helpers to emit current state
  void _emitPlayers() {
    if (!_playersController.isClosed) {
      _playersController.add(List.unmodifiable(_players));
    }
  }

  void _emitVotes() {
    if (!_votesController.isClosed) {
      _votesController.add(Map.unmodifiable(_votes));
    }
  }

  // Generates a simple unique id (ok for mock / dev use)
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();

  @override
  Stream<List<Player>> watchPlayers() => _playersController.stream;

  @override
  Stream<Map<String, int>> watchVotes() => _votesController.stream;

  @override
  Future<String> joinRoom(String roomId, String playerName) async {
    // simulate latency
    await Future.delayed(Duration(milliseconds: latencyMs));

    final id = _generateId();
    final newPlayer = Player(id: id, name: playerName, isHost: false);
    _players.add(newPlayer);
    _emitPlayers();
    return id;
  }

  @override
  Future<void> submitVote(String roomId, String playerId, String option) async {
    await Future.delayed(Duration(milliseconds: latencyMs));

    // record player's vote on the player object if present
    final idx = _players.indexWhere((p) => p.id == playerId);
    if (idx != -1) {
      final updated = _players[idx].copyWith(vote: option);
      _players[idx] = updated;
    }

    // increment vote count for the option (options are arbitrary strings here)
    _votes[option] = (_votes[option] ?? 0) + 1;

    // emit changes
    _emitPlayers();
    _emitVotes();
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    await Future.delayed(Duration(milliseconds: latencyMs));

    _players.removeWhere((p) => p.id == playerId);
    // optionally remove votes by that player - in this mock we do not track per-voter mapping,
    // so we won't decrement counts, but you can extend this to track per-voter choice.
    _emitPlayers();
    _emitVotes();
  }

  @override
  Future<void> dispose() async {
    if (!_playersController.isClosed) await _playersController.close();
    if (!_votesController.isClosed) await _votesController.close();
  }
}

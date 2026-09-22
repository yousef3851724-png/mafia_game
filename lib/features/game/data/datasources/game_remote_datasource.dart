import 'dart:async';

import '../models/game_state_model.dart';

abstract class GameRemoteDataSource {
  Stream<GameStateModel> watchGameState();

  Future<String> joinRoom(String roomId, String playerName);

  Future<void> submitVote(
    String roomId,
    String voterId,
    String targetPlayerId,
  );

  Future<void> leaveRoom(String roomId, String playerId);

  Future<void> close();
}

/// Local simulation of the remote game server.
/// Replace this implementation with Socket.io/Firebase when the backend is ready.
class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final StreamController<GameStateModel> _controller =
      StreamController<GameStateModel>.broadcast();

  GameStateModel _state = GameStateModel.initial();
  bool _closed = false;

  @override
  Stream<GameStateModel> watchGameState() => _controller.stream;

  void _publish(GameStateModel state) {
    if (_closed) return;
    _state = state;
    _controller.add(state);
  }

  @override
  Future<String> joinRoom(String roomId, String playerName) async {
    if (_closed) throw StateError('Remote data source is closed.');

    final cleanName = playerName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Player name cannot be empty.');
    }

    final playerId = 'p_${DateTime.now().microsecondsSinceEpoch}';
    final player = PlayerModel(
      id: playerId,
      name: cleanName,
      isHost: _state.players.isEmpty,
    );

    _publish(_state.copyWith(players: [..._state.players, player]));
    return playerId;
  }

  @override
  Future<void> submitVote(
    String roomId,
    String voterId,
    String targetPlayerId,
  ) async {
    if (_closed) throw StateError('Remote data source is closed.');
    if (targetPlayerId.trim().isEmpty) {
      throw ArgumentError('Target player is required.');
    }

    final voterIndex = _state.players.indexWhere((p) => p.id == voterId);
    final targetExists = _state.players.any((p) => p.id == targetPlayerId);

    if (voterIndex == -1) throw StateError('Voter not found.');
    if (!targetExists) throw StateError('Target player not found.');

    final voter = _state.players[voterIndex];
    if (voter.vote != null) return;
    if (voter.id == targetPlayerId) {
      throw StateError('A player cannot vote for themselves.');
    }

    final updatedPlayers = [..._state.players];
    updatedPlayers[voterIndex] = PlayerModel(
      id: voter.id,
      name: voter.name,
      isHost: voter.isHost,
      vote: targetPlayerId,
    );

    final votes = Map<String, int>.from(_state.votes);
    votes[targetPlayerId] = (votes[targetPlayerId] ?? 0) + 1;

    _publish(_state.copyWith(
      players: updatedPlayers,
      votes: votes,
    ));
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    if (_closed) return;

    final remaining = _state.players.where((p) => p.id != playerId).toList();
    if (remaining.length == _state.players.length) return;

    var updatedPlayers = remaining;
    if (updatedPlayers.isNotEmpty && !updatedPlayers.any((p) => p.isHost)) {
      final first = updatedPlayers.first;
      updatedPlayers = [
        PlayerModel(
          id: first.id,
          name: first.name,
          isHost: true,
          vote: first.vote,
        ),
        ...updatedPlayers.skip(1),
      ];
    }

    final validIds = updatedPlayers.map((p) => p.id).toSet();
    final votes = <String, int>{
      for (final entry in _state.votes.entries)
        if (validIds.contains(entry.key)) entry.key: entry.value,
    };

    _publish(_state.copyWith(
      players: updatedPlayers,
      votes: votes,
    ));
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _controller.close();
  }
}

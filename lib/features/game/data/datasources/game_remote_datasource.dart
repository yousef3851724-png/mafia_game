import 'dart:async';

import '../models/game_state_model.dart';

abstract class GameRemoteDataSource {
  Stream<GameStateModel> watchGameState();

  Future<String> joinRoom(String roomId, String playerName);

  Future<void> submitVote(
    String roomId,
    String playerId,
    String option,
  );

  Future<void> leaveRoom(String roomId, String playerId);

  Future<void> close();
}

/// Local simulation of a remote game server.
/// Replace the method bodies with Socket.io/Firebase calls when the backend is ready.
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

    _publish(_state.copyWith(
      players: [..._state.players, player],
    ));

    return playerId;
  }

  @override
  Future<void> submitVote(
    String roomId,
    String playerId,
    String option,
  ) async {
    if (_closed) throw StateError('Remote data source is closed.');
    if (!_state.options.contains(option)) {
      throw ArgumentError('Invalid vote option: $option');
    }

    final index = _state.players.indexWhere((p) => p.id == playerId);
    if (index == -1) throw StateError('Player not found.');

    final player = _state.players[index];
    if (player.vote != null) return;

    final updatedPlayers = [..._state.players];
    updatedPlayers[index] = PlayerModel(
      id: player.id,
      name: player.name,
      isHost: player.isHost,
      vote: option,
    );

    final votes = Map<String, int>.from(_state.votes);
    votes[option] = (votes[option] ?? 0) + 1;

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

    _publish(_state.copyWith(players: updatedPlayers));
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _controller.close();
  }
}

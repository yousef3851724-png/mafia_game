import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { lobby, night, day, voting, gameOver }

class GameState {
  final String roomId;
  final GamePhase phase;
  final List<String> players;
  final Map<String, String> roles;

  const GameState({
    required this.roomId,
    this.phase = GamePhase.lobby,
    this.players = const [],
    this.roles = const {},
  });

  GameState copyWith({
    GamePhase? phase,
    List<String>? players,
    Map<String, String>? roles,
  }) => GameState(
        roomId: roomId,
        phase: phase ?? this.phase,
        players: players ?? this.players,
        roles: roles ?? this.roles,
      );
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(String roomId) : super(GameState(roomId: roomId));

  void updatePhase(GamePhase newPhase) {
    state = state.copyWith(phase: newPhase);
  }
}

final gameNotifierProvider = StateNotifierProvider.family<GameNotifier, GameState, String>(
  (ref, roomId) => GameNotifier(roomId),
);

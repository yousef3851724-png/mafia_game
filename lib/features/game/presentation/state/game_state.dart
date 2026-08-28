import '../../domain/entities/player.dart';

enum GameStatus { initial, loading, active, voting, night, ended, error }

class GameState {
  final GameStatus status;
  final List<Player> players;
  final String currentPhase;
  final String? errorMessage;
  final String? selectedPlayerId;

  const GameState({
    this.status = GameStatus.initial,
    this.players = const [],
    this.currentPhase = 'روز',
    this.errorMessage,
    this.selectedPlayerId,
  });

  GameState copyWith({
    GameStatus? status,
    List<Player>? players,
    String? currentPhase,
    String? errorMessage,
    String? selectedPlayerId,
  }) {
    return GameState(
      status: status ?? this.status,
      players: players ?? this.players,
      currentPhase: currentPhase ?? this.currentPhase,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPlayerId: selectedPlayerId ?? this.selectedPlayerId,
    );
  }
}

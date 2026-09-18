import 'package:equatable/equatable.dart';

import '../../domain/entities/player.dart';

enum GameStatus { initial, loading, loaded, error }

class GameRoomState extends Equatable {
  final GameStatus status;
  final List<SessionPlayer> players;
  final Map<String, int> votes;
  final List<String> options;
  final String currentPlayerId;
  final String roomId;
  final String? errorMessage;

  const GameRoomState({
    this.status = GameStatus.initial,
    this.players = const [],
    this.votes = const {},
    this.options = const ['A', 'B', 'C', 'D'],
    this.currentPlayerId = '',
    this.roomId = '',
    this.errorMessage,
  });

  GameRoomState copyWith({
    GameStatus? status,
    List<SessionPlayer>? players,
    Map<String, int>? votes,
    List<String>? options,
    String? currentPlayerId,
    String? roomId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GameRoomState(
      status: status ?? this.status,
      players: players ?? this.players,
      votes: votes ?? this.votes,
      options: options ?? this.options,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      roomId: roomId ?? this.roomId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        players,
        votes,
        options,
        currentPlayerId,
        roomId,
        errorMessage,
      ];
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamePhaseState {
  final String phase;
  final int dayNumber;
  final String lastVotedOut;
  final bool gameOver;
  final String winner;
  const GamePhaseState({this.phase = 'day', this.dayNumber = 1, this.lastVotedOut = '', this.gameOver = false, this.winner = ''});
  GamePhaseState copyWith({String? phase, int? dayNumber, String? lastVotedOut, bool? gameOver, String? winner}) =>
      GamePhaseState(phase: phase ?? this.phase, dayNumber: dayNumber ?? this.dayNumber, lastVotedOut: lastVotedOut ?? this.lastVotedOut, gameOver: gameOver ?? this.gameOver, winner: winner ?? this.winner);
}

class GameController extends StateNotifier<GamePhaseState> {
  GameController() : super(const GamePhaseState());
  void nextPhase() => state = state.copyWith(phase: state.phase == 'day' ? 'night' : 'day', dayNumber: state.phase == 'night' ? state.dayNumber + 1 : state.dayNumber);
  void castVote(String votedPlayerId) => state = state.copyWith(lastVotedOut: votedPlayerId);
  void endGame(String winner) => state = state.copyWith(gameOver: true, winner: winner);
}

final gameControllerProvider = StateNotifierProvider<GameController, GamePhaseState>((ref) => GameController());

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';

class GameState {
  final List<Player> players;
  final String? winner;

  GameState({required this.players, this.winner});
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState(players: []));

  void addPlayer(String name) {
    state = GameState(players: [...state.players, Player(id: DateTime.now().toString(), name: name, role: '')]);
  }

  void setWinner(String winner) {
    state = GameState(players: state.players, winner: winner);
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) => GameNotifier());

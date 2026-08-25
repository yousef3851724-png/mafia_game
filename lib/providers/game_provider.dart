import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import 'player_provider.dart';

enum GamePhase { waiting, night, day, gameOver }

class GameState {
  final List<Player> players;
  final GamePhase phase;
  final int? mafiaVictimId;
  final int? doctorSaveId;
  final int? detectiveCheckId;
  final String? winner;

  GameState({
    required this.players,
    required this.phase,
    this.mafiaVictimId,
    this.doctorSaveId,
    this.detectiveCheckId,
    this.winner,
  });

  GameState copyWith({
    List<Player>? players,
    GamePhase? phase,
    int? mafiaVictimId,
    int? doctorSaveId,
    int? detectiveCheckId,
    String? winner,
  }) {
    return GameState(
      players: players ?? this.players,
      phase: phase ?? this.phase,
      mafiaVictimId: mafiaVictimId ?? this.mafiaVictimId,
      doctorSaveId: doctorSaveId ?? this.doctorSaveId,
      detectiveCheckId: detectiveCheckId ?? this.detectiveCheckId,
      winner: winner ?? this.winner,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;

  GameNotifier(this.ref) : super(GameState(players: [], phase: GamePhase.waiting));

  void startGame() {
    final players = ref.read(playerProvider);
    if (players.length < 4) return;

    final roles = List<String>.filled(players.length, 'شهروند');
    roles[0] = 'مافیا';
    roles[1] = 'دکتر';
    roles[2] = 'کارآگاه';
    roles.shuffle(Random());

    final newPlayers = List<Player>.generate(players.length, (index) {
      return Player(
        id: players[index].id,
        name: players[index].name,
        role: roles[index],
      );
    });

    state = GameState(players: newPlayers, phase: GamePhase.night);
  }

  void selectMafiaVictim(String playerId) {
    state = state.copyWith(mafiaVictimId: playerId);
  }

  void selectDoctorSave(String playerId) {
    state = state.copyWith(doctorSaveId: playerId);
  }

  void resolveNight() {
    if (state.mafiaVictimId == state.doctorSaveId) {
      state = state.copyWith(phase: GamePhase.day);
    } else {
      final remainingPlayers = state.players.where((p) => p.id != state.mafiaVictimId).toList();
      state = GameState(players: remainingPlayers, phase: GamePhase.day);
    }
  }

  void resolveDay(String votedPlayerId) {
    final votedPlayer = state.players.firstWhere((p) => p.id == votedPlayerId);
    final remainingPlayers = state.players.where((p) => p.id != votedPlayerId).toList();

    final mafiaAlive = remainingPlayers.any((p) => p.role == 'مافیا');
    if (!mafiaAlive) {
      state = GameState(players: remainingPlayers, phase: GamePhase.gameOver, winner: 'شهروندان');
    } else if (remainingPlayers.length == 1 && remainingPlayers.first.role == 'مافیا') {
      state = GameState(players: remainingPlayers, phase: GamePhase.gameOver, winner: 'مافیا');
    } else {
      state = GameState(players: remainingPlayers, phase: GamePhase.night);
    }
  }

  void restartGame() {
    ref.read(playerProvider.notifier).clearPlayers();
    state = GameState(players: [], phase: GamePhase.waiting);
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});

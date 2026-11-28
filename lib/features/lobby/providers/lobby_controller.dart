import 'package:flutter_riverpod/flutter_riverpod.dart';

class LobbyPlayerRT {
  final String id, name;
  final bool ready, isHost;
  final int seat;
  LobbyPlayerRT({required this.id, required this.name, required this.ready, required this.isHost, required this.seat});
  LobbyPlayerRT copyWith({String? id, String? name, bool? ready, bool? isHost, int? seat}) =>
      LobbyPlayerRT(id: id ?? this.id, name: name ?? this.name, ready: ready ?? this.ready, isHost: isHost ?? this.isHost, seat: seat ?? this.seat);
}

class LobbyState {
  final List<LobbyPlayerRT> players;
  final bool gameStarted;
  const LobbyState({this.players = const [], this.gameStarted = false});
  LobbyState copyWith({List<LobbyPlayerRT>? players, bool? gameStarted}) =>
      LobbyState(players: players ?? this.players, gameStarted: gameStarted ?? this.gameStarted);
}

class LobbyController extends StateNotifier<LobbyState> {
  LobbyController() : super(const LobbyState());
  void addPlayer(String playerId, String playerName) {
    final newPlayers = [...state.players];
    newPlayers.add(LobbyPlayerRT(id: playerId, name: playerName, ready: false, isHost: newPlayers.isEmpty, seat: newPlayers.length));
    state = state.copyWith(players: newPlayers);
  }
  void toggleReady(String playerId) {
    final updated = state.players.map((p) => p.id == playerId ? p.copyWith(ready: !p.ready) : p).toList();
    state = state.copyWith(players: updated);
  }
  void kick(String playerId) {
    final updated = state.players.where((p) => p.id != playerId).toList();
    state = state.copyWith(players: updated);
  }
  void startGame() => state = state.copyWith(gameStarted: true);
}

final lobbyControllerProvider = StateNotifierProvider<LobbyController, LobbyState>((ref) => LobbyController());

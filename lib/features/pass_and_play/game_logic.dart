import '../../core/models/scenario_catalog.dart';

class GamePlayer {
  final String id, name, role;
  final bool alive;
  final int votes;
  GamePlayer({required this.id, required this.name, required this.role, required this.alive, required this.votes});
  GamePlayer copyWith({String? id, String? name, String? role, bool? alive, int? votes}) =>
      GamePlayer(id: id ?? this.id, name: name ?? this.name, role: role ?? this.role, alive: alive ?? this.alive, votes: votes ?? this.votes);
}

class GameState {
  final List<GamePlayer> players;
  final int dayNumber;
  final bool isNight, isGameOver;
  final String winner;
  GameState({required this.players, required this.dayNumber, required this.isNight, required this.isGameOver, required this.winner});
  List<GamePlayer> get alivePlayers => players.where((p) => p.alive).toList();
  GameState copyWith({List<GamePlayer>? players, int? dayNumber, bool? isNight, bool? isGameOver, String? winner}) =>
      GameState(players: players ?? this.players, dayNumber: dayNumber ?? this.dayNumber, isNight: isNight ?? this.isNight, isGameOver: isGameOver ?? this.isGameOver, winner: winner ?? this.winner);
}

class GameLogic {
  final ScenarioDefinition scenario;
  final int playerCount;
  GameLogic({required this.scenario, required this.playerCount});
  
  GameState initializeGame() {
    final roles = _assignRoles();
    final players = List.generate(playerCount, (i) => GamePlayer(id: 'p$i', name: 'بازیکن ${i + 1}', role: roles[i], alive: true, votes: 0));
    return GameState(players: players, dayNumber: 1, isNight: false, isGameOver: false, winner: '');
  }
  
  List<String> _assignRoles() {
    final roles = <String>[];
    for (int i = 0; i < scenario.mafiaCount; i++) roles.add('مافیا');
    for (int i = roles.length; i < playerCount; i++) roles.add('شهروند');
    roles.shuffle();
    return roles;
  }
  
  GameState castVote(GameState state, String votedPlayerId) {
    final updatedPlayers = state.players.map((p) => p.id == votedPlayerId ? p.copyWith(alive: false) : p).toList();
    return state.copyWith(players: updatedPlayers, isNight: true);
  }
  
  GameState nextPhase(GameState state) {
    if (state.isNight) return _checkWinConditions(state.copyWith(isNight: false, dayNumber: state.dayNumber + 1));
    return state;
  }
  
  GameState _checkWinConditions(GameState state) {
    final aliveMafia = state.alivePlayers.where((p) => p.role == 'مافیا').length;
    final aliveCitizens = state.alivePlayers.where((p) => p.role == 'شهروند').length;
    if (aliveMafia == 0) return state.copyWith(isGameOver: true, winner: 'citizens');
    if (aliveMafia >= aliveCitizens) return state.copyWith(isGameOver: true, winner: 'mafia');
    return state;
  }
}

import 'game_state.dart';
import '../lobbies/lobby_system.dart';
import '../scenarios/scenario_catalog.dart';

enum GameActionType { selectTarget, nightAction, openVoting, castVote, timeout }

enum GameEngineError { none, invalidPlayerCount, invalidScenario, invalidAge, invalidDiamond, invalidPhase, deadPlayer, missingTarget, unauthorized }

class GameEngineRules {
  final int minPlayers;
  final int maxPlayers;
  final int nightSeconds;
  final int discussionSeconds;
  final int votingSeconds;
  final bool ranked;
  const GameEngineRules({this.minPlayers = 4, this.maxPlayers = 20, this.nightSeconds = 20, this.discussionSeconds = 15, this.votingSeconds = 15, this.ranked = false});
  static const friendly = GameEngineRules();
  static const rankedRules = GameEngineRules(ranked: true);
  bool validPlayerCount(int count) => count >= minPlayers && count <= maxPlayers && (!ranked || count == 10);
}

class GameEngineOutcome {
  final String? winner;
  final int aliveMafia;
  final int aliveCitizens;
  final bool ended;
  final int ratingDelta;
  final int nextRating;
  final String? league;
  const GameEngineOutcome({required this.winner, required this.aliveMafia, required this.aliveCitizens, required this.ended, required this.ratingDelta, this.nextRating = 0, this.league});
}

class GameEngineValidation {
  final bool allowed;
  final GameEngineError error;
  const GameEngineValidation(this.allowed, this.error);
  static const ok = GameEngineValidation(true, GameEngineError.none);
}

class GameEngine {
  const GameEngine._();

  static GameEngineValidation validateLobby({required LobbyCategory category, required int playerCount, required ScenarioDefinition? scenario, LobbyAge playerAge = LobbyAge.adult, bool isStaff = false}) {
    if (!GameEngineRules(ranked: category.isRanked).validPlayerCount(playerCount)) return const GameEngineValidation(false, GameEngineError.invalidPlayerCount);
    if (!LobbyCatalog.canEnter(category: category, playerAge: playerAge, isStaff: isStaff)) return const GameEngineValidation(false, GameEngineError.invalidAge);
    if (scenario == null) return const GameEngineValidation(false, GameEngineError.invalidScenario);
    final mode = category.isRanked ? ScenarioMode.ranked : ScenarioMode.friendly;
    if (!ScenarioCatalog.canStart(scenarioId: scenario.id, mode: mode, playerCount: playerCount)) return const GameEngineValidation(false, GameEngineError.invalidScenario);
    if (category.isRanked && playerCount != 10) return const GameEngineValidation(false, GameEngineError.invalidPlayerCount);
    if (category.isTeen && scenario.roles.any((role) => const {'قاتل مستقل', 'زامبی', 'شکارچی ارشد'}.contains(role))) return const GameEngineValidation(false, GameEngineError.invalidAge);
    return GameEngineValidation.ok;
  }

  static GameEngineValidation validateDiamond({required LobbyCategory category, required DiamondType type}) => RadicalDiamonds.supports(category, type) ? GameEngineValidation.ok : const GameEngineValidation(false, GameEngineError.invalidDiamond);

  static GameEngineOutcome evaluate(GameState state, {GameEngineRules rules = GameEngineRules.friendly, int currentRating = 0}) {
    final mafia = state.alivePlayers.where((p) => _isMafia(p.role)).length;
    final citizens = state.alivePlayers.length - mafia;
    final ended = state.phase == GamePhase.ended || mafia == 0 || mafia >= citizens;
    final winner = state.winner ?? (mafia == 0 ? 'شهروندان' : mafia >= citizens ? 'مافیا' : null);
    final delta = rules.ranked && ended ? _ratingDelta(state, winner) : 0;
    final next = (currentRating + delta).clamp(0, 10000);
    return GameEngineOutcome(winner: winner, aliveMafia: mafia, aliveCitizens: citizens, ended: ended, ratingDelta: delta, nextRating: next, league: _leagueFor(next));
  }

  static bool canAct(GameState state, GameActionType action) {
    if (!state.initialized || state.phase == GamePhase.ended || !(state.user?.alive ?? false)) return false;
    return switch (action) {
      GameActionType.selectTarget => state.secondsLeft > 0,
      GameActionType.nightAction => state.phase == GamePhase.night && !state.nightActionDone && state.availableAction != NightAction.none,
      GameActionType.openVoting => state.phase == GamePhase.dayDiscussion,
      GameActionType.castVote => state.phase == GamePhase.dayVoting && state.secondsLeft > 0,
      GameActionType.timeout => state.secondsLeft <= 0,
    };
  }

  static bool validTarget(GameState state, String targetId, {bool allowUser = false}) {
    if (!state.initialized || state.phase == GamePhase.ended) return false;
    final target = state.players.where((p) => p.id == targetId).firstOrNull;
    return target != null && target.alive && (allowUser || !target.isUser);
  }

  static String phaseLabel(GamePhase phase) => switch (phase) {
    GamePhase.night => 'شب',
    GamePhase.dayDiscussion => 'روز • بحث',
    GamePhase.dayVoting => 'روز • رأی‌گیری',
    GamePhase.ended => 'پایان بازی',
  };

  static bool _isMafia(String role) => role == 'مافیا' || role == 'پدرخوانده' || role.contains('مافیا');

  static int _ratingDelta(GameState state, String? winner) {
    if (winner == null) return 0;
    final user = state.user;
    if (user == null) return 0;
    final userMafia = _isMafia(user.role);
    final won = (winner == 'مافیا' && userMafia) || (winner == 'شهروندان' && !userMafia);
    return won ? 25 : -15;
  }

  static String _leagueFor(int rating) {
    if (rating >= 3000) return 'Diamond';
    if (rating >= 2000) return 'Platinum';
    if (rating >= 1000) return 'Gold';
    if (rating >= 500) return 'Silver';
    return 'Bronze';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

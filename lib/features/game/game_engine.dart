import 'game_state.dart';
import '../lobbies/lobby_system.dart';
import '../scenarios/scenario_catalog.dart';

enum GameActionType { selectTarget, nightAction, openVoting, castVote, timeout }
enum LiveGameEngineError { none, invalidPlayerCount, invalidScenario, invalidAge, invalidDiamond, invalidPhase, deadPlayer, missingTarget, unauthorized }

class LiveGameEngineRules {
  final int minPlayers;
  final int maxPlayers;
  final int nightSeconds;
  final int discussionSeconds;
  final int votingSeconds;
  final bool ranked;
  const LiveGameEngineRules({this.minPlayers = 4, this.maxPlayers = 20, this.nightSeconds = 20, this.discussionSeconds = 15, this.votingSeconds = 15, this.ranked = false});
  static const friendly = LiveGameEngineRules();
  static const rankedRules = LiveGameEngineRules(ranked: true);
  bool validPlayerCount(int count) => count >= minPlayers && count <= maxPlayers && (!ranked || count == 10);
}

class LiveGameEngineOutcome {
  final String? winner;
  final int aliveMafia;
  final int aliveCitizens;
  final bool ended;
  final int ratingDelta;
  final int nextRating;
  final String? league;
  const LiveGameEngineOutcome({required this.winner, required this.aliveMafia, required this.aliveCitizens, required this.ended, required this.ratingDelta, this.nextRating = 0, this.league});
}

class LiveGameEngineValidation {
  final bool allowed;
  final LiveGameEngineError error;
  const LiveGameEngineValidation(this.allowed, this.error);
  static const ok = LiveGameEngineValidation(true, LiveGameEngineError.none);
}

class LiveGameEngine {
  const LiveGameEngine._();

  static LiveGameEngineValidation validateLobby({required LobbyCategory category, required int playerCount, required ScenarioDefinition? scenario, LobbyAge playerAge = LobbyAge.adult, bool isStaff = false}) {
    if (!LiveGameEngineRules(ranked: category.isRanked).validPlayerCount(playerCount)) return const LiveGameEngineValidation(false, LiveGameEngineError.invalidPlayerCount);
    if (!LobbyCatalog.canEnter(category: category, playerAge: playerAge, isStaff: isStaff)) return const LiveGameEngineValidation(false, LiveGameEngineError.invalidAge);
    if (scenario == null) return const LiveGameEngineValidation(false, LiveGameEngineError.invalidScenario);
    final mode = category.isRanked ? ScenarioMode.ranked : ScenarioMode.friendly;
    if (!ScenarioCatalog.canStart(scenarioId: scenario.id, mode: mode, playerCount: playerCount)) return const LiveGameEngineValidation(false, LiveGameEngineError.invalidScenario);
    if (category.isRanked && playerCount != 10) return const LiveGameEngineValidation(false, LiveGameEngineError.invalidPlayerCount);
    if (category.isTeen && scenario.roles.any((role) => const {'قاتل مستقل', 'زامبی', 'شکارچی ارشد'}.contains(role))) return const LiveGameEngineValidation(false, LiveGameEngineError.invalidAge);
    return LiveGameEngineValidation.ok;
  }

  static LiveGameEngineValidation validateDiamond({required LobbyCategory category, required DiamondType type}) => RadicalDiamonds.supports(category, type) ? LiveGameEngineValidation.ok : const LiveGameEngineValidation(false, LiveGameEngineError.invalidDiamond);

  static LiveGameEngineOutcome evaluate(LiveGameState state, {LiveGameEngineRules rules = LiveGameEngineRules.friendly, int currentRating = 0}) {
    final mafia = state.alivePlayers.where((p) => _isMafia(p.role)).length;
    final citizens = state.alivePlayers.length - mafia;
    final ended = state.phase == LiveGamePhase.ended || mafia == 0 || mafia >= citizens;
    final winner = state.winner ?? (mafia == 0 ? 'شهروندان' : mafia >= citizens ? 'مافیا' : null);
    final delta = rules.ranked && ended ? _ratingDelta(state, winner) : 0;
    final next = (currentRating + delta).clamp(0, 10000);
    return LiveGameEngineOutcome(winner: winner, aliveMafia: mafia, aliveCitizens: citizens, ended: ended, ratingDelta: delta, nextRating: next, league: _leagueFor(next));
  }

  static bool canAct(LiveGameState state, GameActionType action) {
    if (!state.initialized || state.phase == LiveGamePhase.ended || !(state.user?.alive ?? false)) return false;
    return switch (action) {
      GameActionType.selectTarget => state.secondsLeft > 0,
      GameActionType.nightAction => state.phase == LiveGamePhase.night && !state.nightActionDone && state.availableAction != NightAction.none,
      GameActionType.openVoting => state.phase == LiveGamePhase.dayDiscussion,
      GameActionType.castVote => state.phase == LiveGamePhase.dayVoting && state.secondsLeft > 0,
      GameActionType.timeout => state.secondsLeft <= 0,
    };
  }

  static bool validTarget(LiveGameState state, String targetId, {bool allowUser = false}) {
    if (!state.initialized || state.phase == LiveGamePhase.ended) return false;
    final target = state.players.where((p) => p.id == targetId).firstOrNull;
    return target != null && target.alive && (allowUser || !target.isUser);
  }

  static String phaseLabel(LiveGamePhase phase) => switch (phase) {
    LiveGamePhase.night => 'شب',
    LiveGamePhase.dayDiscussion => 'روز • بحث',
    LiveGamePhase.dayVoting => 'روز • رأی‌گیری',
    LiveGamePhase.ended => 'پایان بازی',
  };

  static bool _isMafia(String role) => role == 'مافیا' || role == 'پدرخوانده' || role.contains('مافیا');

  static int _ratingDelta(LiveGameState state, String? winner) {
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

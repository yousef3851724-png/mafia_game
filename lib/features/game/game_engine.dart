import 'game_state.dart';

enum GameActionType { selectTarget, nightAction, openVoting, castVote, timeout }

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

  const GameEngineOutcome({required this.winner, required this.aliveMafia, required this.aliveCitizens, required this.ended, required this.ratingDelta});
}

class GameEngine {
  const GameEngine._();

  static GameEngineOutcome evaluate(GameState state, {GameEngineRules rules = GameEngineRules.friendly}) {
    final mafia = state.alivePlayers.where((p) => _isMafia(p.role)).length;
    final citizens = state.alivePlayers.length - mafia;
    final ended = state.phase == GamePhase.ended || mafia == 0 || mafia >= citizens;
    final winner = state.winner ?? (mafia == 0 ? 'شهروندان' : mafia >= citizens ? 'مافیا' : null);
    return GameEngineOutcome(winner: winner, aliveMafia: mafia, aliveCitizens: citizens, ended: ended, ratingDelta: rules.ranked && ended ? _ratingDelta(state, winner) : 0);
  }

  static bool canAct(GameState state, GameActionType action) {
    if (!state.initialized || state.phase == GamePhase.ended || !(state.user?.alive ?? false)) return false;
    return switch (action) {
      GameActionType.selectTarget => state.secondsLeft > 0,
      GameActionType.nightAction => state.phase == GamePhase.night && !state.nightActionDone,
      GameActionType.openVoting => state.phase == GamePhase.dayDiscussion,
      GameActionType.castVote => state.phase == GamePhase.dayVoting && state.secondsLeft > 0,
      GameActionType.timeout => state.secondsLeft <= 0,
    };
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
}

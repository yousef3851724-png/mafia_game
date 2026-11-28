import '../../core/models/scenario_catalog.dart';

enum GamePhase { night, day, voting, ended }

enum PlayerRole { mafia, citizen, doctor, detective }

class Player {
  final String name;
  final PlayerRole role;
  bool isAlive;

  Player({
    required this.name,
    required this.role,
    this.isAlive = true,
  });
}

class GameState {
  final ScenarioDefinition scenario;
  final List<Player> players;
  final GamePhase phase;
  final int dayCount;

  GameState({
    required this.scenario,
    required this.players,
    this.phase = GamePhase.night,
    this.dayCount = 1,
  });

  List<Player> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  List<Player> get aliveMafia =>
      players.where((p) => p.isAlive && p.role == PlayerRole.mafia).toList();

  List<Player> get aliveCitizens =>
      players.where((p) => p.isAlive && p.role != PlayerRole.mafia).toList();

  bool get mafiaWins => aliveMafia.length >= aliveCitizens.length;
  bool get citizensWin => aliveMafia.isEmpty;
}

class GameLogic {
  GameLogic._();

  /// ساخت لیست بازیکن‌ها با نقش‌های تصادفی
  static List<Player> buildPlayers({
    required ScenarioDefinition scenario,
    required int playerCount,
    required List<String> names,
  }) {
    final roles = <PlayerRole>[];

    // اضافه کردن مافیا
    for (var i = 0; i < scenario.mafiaCount; i++) {
      roles.add(PlayerRole.mafia);
    }

    // یک دکتر (اگه حداقل ۷ نفر)
    if (playerCount >= 7) {
      roles.add(PlayerRole.doctor);
    }

    // یک کارآگاه (اگه حداقل ۸ نفر)
    if (playerCount >= 8) {
      roles.add(PlayerRole.detective);
    }

    // بقیه شهروند
    while (roles.length < playerCount) {
      roles.add(PlayerRole.citizen);
    }

    // شافل
    roles.shuffle();

    // ساخت پلیرها
    final players = <Player>[];
    for (var i = 0; i < playerCount; i++) {
      players.add(Player(
        name: i < names.length ? names[i] : 'بازیکن ${i + 1}',
        role: roles[i],
      ));
    }

    return players;
  }

  /// چک کردن شرط پایان بازی
  static GamePhase checkEndGame(GameState state) {
    if (state.mafiaWins || state.citizensWin) {
      return GamePhase.ended;
    }
    return state.phase;
  }
}

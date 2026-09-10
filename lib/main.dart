import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CoinManager.loadCoins();
  await SeasonalRanking.loadData();
  await SeasonalRanking.checkSeasonReset();
  runApp(const MafiaGame());
}

class MafiaGame extends StatelessWidget {
  const MafiaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mafia Radical',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0e14),
        primaryColor: const Color(0xFFd4af87),
      ),
      home: const LobbyScreen(),
    );
  }
}

class CoinManager {
  static const String _coinsKey = 'user_coins';
  static int _coins = 100;

  static Future<void> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(_coinsKey) ?? 100;
  }

  static Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, _coins);
  }

  static int get coins => _coins;

  static bool canPlayRanked() => _coins >= 100;

  static Future<void> payForRanked() async {
    if (canPlayRanked()) {
      _coins -= 100;
      await _saveCoins();
    }
  }

  static Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveCoins();
  }

  static Future<void> resetCoins() async {
    _coins = 100;
    await _saveCoins();
  }
}

class SeasonalRanking {
  static const String _seasonKey = 'current_season';
  static const String _pointsKey = 'seasonal_points';
  static const String _winsKey = 'seasonal_wins';
  static const String _seasonStartKey = 'season_start_time';

  static int _currentSeason = 1;
  static int _seasonalPoints = 0;
  static int _seasonalWins = 0;
  static DateTime _seasonStart = DateTime.now();

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSeason = prefs.getInt(_seasonKey) ?? 1;
    _seasonalPoints = prefs.getInt(_pointsKey) ?? 0;
    _seasonalWins = prefs.getInt(_winsKey) ?? 0;
    final startTime = prefs.getString(_seasonStartKey);
    if (startTime != null) {
      _seasonStart = DateTime.parse(startTime);
    } else {
      _seasonStart = DateTime.now();
      await _saveData();
    }
  }

  static Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seasonKey, _currentSeason);
    await prefs.setInt(_pointsKey, _seasonalPoints);
    await prefs.setInt(_winsKey, _seasonalWins);
    await prefs.setString(_seasonStartKey, _seasonStart.toIso8601String());
  }

  static int get currentSeason => _currentSeason;
  static int get points => _seasonalPoints;
  static int get wins => _seasonalWins;

  static Future<void> addWin() async {
    _seasonalWins += 1;
    _seasonalPoints += 1;
    await _saveData();
  }

  static Future<void> startNewSeason() async {
    _currentSeason += 1;
    _seasonalPoints = 0;
    _seasonalWins = 0;
    _seasonStart = DateTime.now();
    await _saveData();
  }

  static String getRank() {
    if (_seasonalPoints >= 10) return '🥇 Gold';
    if (_seasonalPoints >= 5) return '🥈 Silver';
    if (_seasonalPoints >= 2) return '🥉 Bronze';
    return '⚪ Participant';
  }

  static String getSeasonStatus() {
    return 'Season $_currentSeason | Wins: $_seasonalWins | Points: $_seasonalPoints | Rank: ${getRank()}';
  }

  static Future<void> checkSeasonReset() async {
    await loadData();
    final now = DateTime.now();
    final diff = now.difference(_seasonStart);
    if (diff.inDays >= 30) {
      await startNewSeason();
    }
  }

  static int get lotteryChances => _seasonalPoints;
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String selectedRole = 'citizen';
  final List<Map<String, String>> roles = const [
    {'label': '👤 شهروند', 'value': 'citizen'},
    {'label': '💉 دکتر', 'value': 'doctor'},
    {'label': '🔍 کارآگاه', 'value': 'detective'},
    {'label': '🔪 مافیا', 'value': 'mafia'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _vpnBadge(),
              const SizedBox(height: 16),
              const Text('Mafia Radical',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFd4af87))),
              const Text('Welcome to Mafia Game!',
                  style: TextStyle(fontSize: 18, color: Color(0xFFaab))),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Text('🪙 Coins: ${CoinManager.coins}'),
                  const SizedBox(width: 24),
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(child: Text(SeasonalRanking.getSeasonStatus())),
                ],
              ),
              const SizedBox(height: 20),
              const Text('🎭 Choose your role',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFd4af87))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: roles.map((role) {
                  return ChoiceChip(
                    label: Text(role['label']!),
                    selected: selectedRole == role['value'],
                    onSelected: (sel) =>
                        setState(() => selectedRole = role['value']!),
                    backgroundColor: const Color(0xFF2a3448),
                    selectedColor: const Color(0xFFd4af87),
                    labelStyle: TextStyle(
                        color: selectedRole == role['value']
                            ? Colors.black
                            : Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GameScreen(
                                  userRole: selectedRole,
                                  isRanked: false,
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60)),
                  ),
                  child: const Text('🎮 Friendly Game (Free)',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (CoinManager.canPlayRanked()) {
                      await CoinManager.payForRanked();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GameScreen(
                                    userRole: selectedRole,
                                    isRanked: true,
                                  )));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                '❌ Not enough coins! Play Friendly Game.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af87),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60)),
                  ),
                  child: const Text('🏆 Ranked Game (100 Coins)',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RankingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a3448),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60)),
                  ),
                  child: const Text('🏅 Seasonal Ranking',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
              const Spacer(),
              const Center(
                child: Text('⏳ Waiting to start...',
                    style: TextStyle(color: Color(0xFF8892a8))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vpnBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.green[700], borderRadius: BorderRadius.circular(30)),
      child: const Text('🔒 100% VPN',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String userRole;
  final bool isRanked;
  const GameScreen({super.key, required this.userRole, required this.isRanked});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine engine;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    engine = GameEngine(userRole: widget.userRole, onUpdate: updateUI);
    engine.startGame();
  }

  void updateUI(String msg, {String type = ''}) {
    setState(() {
      logs.add(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRanked ? '🏆 Ranked Game' : '🎮 Friendly Game',
            style: const TextStyle(color: Color(0xFFd4af87))),
        backgroundColor: const Color(0xFF0a0e14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFd4af87)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _statusBar(),
              const SizedBox(height: 12),
              _playersGrid(),
              const SizedBox(height: 12),
              _actionArea(),
              const SizedBox(height: 12),
              Expanded(child: _logArea()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar() {
    String status = engine.phase == 'idle'
        ? '⏳ Waiting...'
        : engine.phase == 'day'
            ? '☀️ Day ${engine.day}'
            : engine.phase == 'night'
                ? '🌙 Night ${engine.day}'
                : '🏁 Game Over';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1e2634),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(status,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFd4af87))),
          Text('👥 ${engine.alivePlayers.length} Alive',
              style: const TextStyle(color: Color(0xFF8892a8))),
        ],
      ),
    );
  }

  Widget _playersGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1e2634),
          borderRadius: BorderRadius.circular(16)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: engine.players.map((p) {
          bool dead = !p.isAlive;
          bool isUser = p.id == engine.userId;
          String label = isUser ? '⭐ ${p.name}' : p.name;
          if (dead || engine.phase == 'gameover')
            label += ' (${_roleName(p.role)})';
          return GestureDetector(
            onTap: () {
              if (engine.user.isAlive &&
                  p.isAlive &&
                  !isUser &&
                  !engine.isProcessing) {
                engine.selectTarget(p.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: dead ? const Color(0xFF2a2a2a) : const Color(0xFF2a3448),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                    color: dead ? const Color(0xFF5a2a2a) : const Color(0xFF3f4b62)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: dead ? Colors.grey[600] : Colors.white,
                  decoration: dead ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _actionArea() {
    String content = '';
    if (engine.phase == 'day' && engine.user.isAlive)
      content = '✅ Click on a player to vote.';
    else if (engine.phase == 'night' && engine.user.isAlive) {
      if (engine.user.role == 'mafia')
        content = '🔪 Click on a player to kill.';
      else if (engine.user.role == 'doctor')
        content = '💉 Click on a player to heal.';
      else if (engine.user.role == 'detective')
        content = '🔍 Click on a player to investigate.';
      else
        content = '🌙 Night falls, you sleep...';
    } else if (!engine.user.isAlive)
      content = '💀 You are dead. Watch...';
    else
      content = '⏳ Processing...';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF1e2634),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: Text(content,
              style: const TextStyle(color: Color(0xFF8892a8)))),
          if (engine.phase == 'gameover')
            ElevatedButton(
              onPressed: () async {
                if (widget.isRanked && engine.user.isAlive) {
                  await CoinManager.addCoins(20);
                  await SeasonalRanking.addWin();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('🎉 +20 Coins & +1 Seasonal Point!')),
                  );
                } else if (widget.isRanked && !engine.user.isAlive) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('😞 You lost! 100 Coins gone.')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }

  Widget _logArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF0f151e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF293242))),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: logs.reversed.map((msg) {
            Color color = Colors.white70;
            if (msg.contains('🎉') || msg.contains('won'))
              color = const Color(0xFFf7c948);
            else if (msg.contains('💀') || msg.contains('killed'))
              color = const Color(0xFFff5e6b);
            else if (msg.contains('🛡️') || msg.contains('heal'))
              color = const Color(0xFF6fc3ff);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(msg, style: TextStyle(color: color, fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _roleName(String role) {
    switch (role) {
      case 'mafia':
        return '🔪 Mafia';
      case 'doctor':
        return '💉 Doctor';
      case 'detective':
        return '🔍 Detective';
      default:
        return '👤 Citizen';
    }
  }
}

class Player {
  int id;
  String name;
  String role;
  bool isAlive;
  bool isUser;

  Player(
      {required this.id,
      required this.name,
      required this.role,
      this.isAlive = true,
      this.isUser = false});
}

class GameEngine {
  final String userRole;
  final Function(String, {String type}) onUpdate;

  List<Player> players = [];
  int userId = 0;
  String phase = 'idle';
  int day = 1;
  bool isProcessing = false;
  Map<int, int> votes = {};
  Map<String, int?> nightActions = {'kill': null, 'heal': null, 'investigate': null};

  GameEngine({required this.userRole, required this.onUpdate});

  void startGame() {
    _initPlayers();
    onUpdate('🎭 You are ${_roleName(userRole)}');
    phase = 'day';
    _startNewDay();
  }

  void _initPlayers() {
    List<String> names = [
      'YOU',
      'YOUSEF',
      'AMIRALI',
      'HAMZEH',
      'VIKING',
      'ARIA',
      'ANASTASIA',
      'SID'
    ];
    List<String> roles = [
      'citizen',
      'citizen',
      'citizen',
      'citizen',
      'mafia',
      'mafia',
      'doctor',
      'detective'
    ];
    roles.shuffle(Random());
    players = List.generate(
        names.length,
        (i) => Player(
            id: i, name: names[i], role: roles[i], isUser: i == 0));
    players[0].role = userRole;
    _rebalanceRoles();
    userId = 0;
  }

  void _rebalanceRoles() {
    var bots = players.where((p) => p.id != 0).toList();
    Map<String, int> need = {
      'mafia': 2,
      'doctor': 1,
      'detective': 1,
      'citizen': 4
    };
    need[userRole] = need[userRole]! - 1;
    List<String> target = [];
    need.forEach((key, val) {
      for (int i = 0; i < val; i++) target.add(key);
    });
    target.shuffle(Random());
    for (int i = 0; i < bots.length; i++) {
      bots[i].role = target[i % target.length];
    }
  }

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();
  List<Player> get mafiaAlive =>
      players.where((p) => p.isAlive && p.role == 'mafia').toList();
  List<Player> get townAlive =>
      players.where((p) => p.isAlive && p.role != 'mafia').toList();
  Player get user => players.firstWhere((p) => p.id == userId);

  void _startNewDay() {
    if (_checkGameOver()) return;
    phase = 'day';
    votes.clear();
    onUpdate('--- Day $day ---');
    if (!user.isAlive) {
      onUpdate('💀 You are dead. Watch...');
      Future.delayed(const Duration(seconds: 2), () => _aiVoteAndExecute());
      return;
    }
    onUpdate('👤 Click on a player to vote.');
  }

  void startNight() {
    if (_checkGameOver()) return;
    phase = 'night';
    nightActions = {'kill': null, 'heal': null, 'investigate': null};
    onUpdate('--- Night $day ---');
    if (!user.isAlive) {
      _doAIActions();
      Future.delayed(const Duration(seconds: 1), () => _resolveNight());
      return;
    }
    if (user.role == 'mafia')
      onUpdate('🔪 Click on a player to kill.');
    else if (user.role == 'doctor')
      onUpdate('💉 Click on a player to heal.');
    else if (user.role == 'detective')
      onUpdate('🔍 Click on a player to investigate.');
    else {
      onUpdate('👤 Night falls, you sleep...');
      _doAIActions();
      Future.delayed(const Duration(seconds: 1), () => _resolveNight());
    }
  }

  void selectTarget(int id) {
    if (isProcessing) return;
    var target = players.firstWhere((p) => p.id == id,
        orElse: () => Player(id: -1, name: '', role: ''));
    if (target.id == -1 || !target.isAlive || target.id == userId) return;

    if (phase == 'day') {
      votes[userId] = id;
      onUpdate('🗳️ You voted for ${target.name}');
      _aiVoteAndExecute();
      return;
    }
    if (phase == 'night') {
      if (user.role == 'mafia') nightActions['kill'] = id;
      else if (user.role == 'doctor') nightActions['heal'] = id;
      else if (user.role == 'detective') {
        nightActions['investigate'] = id;
        onUpdate('🔍 ${target.name} → ${_roleName(target.role)}');
      }
      _doAIActions();
      Future.delayed(const Duration(seconds: 1), () => _resolveNight());
    }
  }

  void _doAIActions() {
    var alive = alivePlayers;
    var mafias = mafiaAlive;
    if (mafias.isNotEmpty && nightActions['kill'] == null) {
      var targets = alive.where((p) => p.role != 'mafia').toList();
      if (targets.isNotEmpty)
        nightActions['kill'] = targets[Random().nextInt(targets.length)].id;
    }
    var docs = players
        .where((p) => p.isAlive && p.role == 'doctor' && !p.isUser)
        .toList();
    if (docs.isNotEmpty && nightActions['heal'] == null) {
      var targets = alive.where((p) => p.role != 'doctor').toList();
      if (targets.isNotEmpty)
        nightActions['heal'] = targets[Random().nextInt(targets.length)].id;
    }
    var dets = players
        .where((p) => p.isAlive && p.role == 'detective' && !p.isUser)
        .toList();
    if (dets.isNotEmpty && nightActions['investigate'] == null) {
      var targets = alive.where((p) => p.role == 'mafia' || p.role == 'detective').toList();
      if (targets.isNotEmpty) {
        var t = targets[Random().nextInt(targets.length)];
        nightActions['investigate'] = t.id;
      }
    }
  }

  void _resolveNight() {
    if (isProcessing) return;
    isProcessing = true;
    int? killId = nightActions['kill'];
    int? healId = nightActions['heal'];
    if (killId != null) {
      var target = players.firstWhere((p) => p.id == killId,
          orElse: () => Player(id: -1, name: '', role: ''));
      if (target.id != -1 && target.isAlive) {
        if (healId == killId) {
          onUpdate('🛡️ ${target.name} was healed by Doctor!');
        } else {
          target.isAlive = false;
          onUpdate('💀 ${target.name} (${_roleName(target.role)}) was killed.');
        }
      }
    } else {
      onUpdate('🌙 Quiet night.');
    }
    if (_checkGameOver()) {
      isProcessing = false;
      return;
    }
    day++;
    isProcessing = false;
    _startNewDay();
  }

  void _aiVoteAndExecute() {
    if (isProcessing) return;
    isProcessing = true;
    var alive = alivePlayers;
    for (var p in alive) {
      if (p.isUser) continue;
      var targets = alive.where((t) => t.id != p.id).toList();
      if (targets.isNotEmpty)
        votes[p.id] = targets[Random().nextInt(targets.length)].id;
    }
    Map<int, int> count = {};
    votes.forEach((_, targetId) {
      count[targetId] = (count[targetId] ?? 0) + 1;
    });
    int max = 0;
    int? eliminated;
    count.forEach((id, c) {
      if (c > max) {
        max = c;
        eliminated = id;
      }
    });
    if (eliminated != null) {
      var p = players.firstWhere((e) => e.id == eliminated,
          orElse: () => Player(id: -1, name: '', role: ''));
      if (p.id != -1 && p.isAlive) {
        p.isAlive = false;
        onUpdate('⚖️ ${p.name} (${_roleName(p.role)}) was eliminated.');
      }
    } else {
      onUpdate('🤝 No one was eliminated.');
    }
    if (_checkGameOver()) {
      isProcessing = false;
      return;
    }
    isProcessing = false;
    Future.delayed(const Duration(seconds: 1), () => startNight());
  }

  bool _checkGameOver() {
    int m = mafiaAlive.length;
    int t = townAlive.length;
    if (m == 0) {
      phase = 'gameover';
      onUpdate('🎉 Citizens won!');
      return true;
    }
    if (m >= t) {
      phase = 'gameover';
      onUpdate('💀 Mafia won!');
      return true;
    }
    return false;
  }

  String _roleName(String role) {
    switch (role) {
      case 'mafia':
        return '🔪 Mafia';
      case 'doctor':
        return '💉 Doctor';
      case 'detective':
        return '🔍 Detective';
      default:
        return '👤 Citizen';
    }
  }
}

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏆 Season ${SeasonalRanking.currentSeason} Ranking'),
        backgroundColor: const Color(0xFF0a0e14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFd4af87)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1e2634),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Status',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(SeasonalRanking.getSeasonStatus()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🏅 Top Players This Season:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4af87)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (ctx, i) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2a3448),
                      child: Text('${i + 1}'),
                    ),
                    title: Text('Player ${i + 1}'),
                    trailing: Text('${10 - i} Points',
                        style: const TextStyle(color: Color(0xFFd4af87))),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('🎲 Monthly Lottery Coming Soon...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4af87),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60)),
              ),
              child: const Text('🎲 Monthly Lottery'),
            ),
            const SizedBox(height: 10),
            Text('🎯 Your Chances: ${SeasonalRanking.lotteryChances}'),
          ],
        ),
      ),
    );
  }
}

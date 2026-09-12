import 'package:flutter/material.dart';
import 'features/lobby/round_lobby.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/scenarios/scenario_lobby_screen.dart';
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
      home: const ScenarioLobbyScreen(ownerId: 'local_creator'),
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
    _coins -= 100;
    await _saveCoins();
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
      _seasonStart = DateTime.tryParse(startTime) ?? DateTime.now();
    } else {
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
    _seasonalPoints += 10;
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
    if (_seasonalPoints >= 100) return 'Godfather 👑';
    if (_seasonalPoints >= 50) return 'Underboss 🥈';
    if (_seasonalPoints >= 20) return 'Soldier 🥉';
    return 'Associate 🎖️';
  }

  static String getSeasonStatus() {
    return 'فصل $_currentSeason | امتیاز: $_seasonalPoints';
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
  String selectedGameMode = 'friendly';

  final List<Map<String, String>> roles = const [
    {'label': '👤 شهروند', 'value': 'citizen'},
    {'label': '💉 دکتر', 'value': 'doctor'},
    {'label': '🔍 کارآگاه', 'value': 'detective'},
    {'label': '🔪 مافیا', 'value': 'mafia'},
  ];

  Widget _vpnBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi, size: 14, color: Colors.greenAccent),
          SizedBox(width: 4),
          Text('Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }

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
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFd4af87))),
              const Text('Welcome to Mafia Game!',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
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
              const SizedBox(height: 24),
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
                  final isSelected = selectedRole == role['value'];
                  return ChoiceChip(
                    label: Text(role['label']!),
                    selected: isSelected,
                    onSelected: (sel) {
                      if (sel) {
                        setState(() {
                          selectedRole = role['value']!;
                        });
                      }
                    },
                    backgroundColor: const Color(0xFF2a3448),
                    selectedColor: const Color(0xFFd4af87),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white),
                  );
                }).toList(),
              ),
              const Spacer(),
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
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            userRole: selectedRole,
                            isRanked: true,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('❌ Not enough coins! Play Friendly Game.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af87),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('🏆 Ranked Game (100 Coins)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RankingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a3448),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('🏅 Seasonal Ranking',
                      style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '🎮 حالت بازی',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4af87),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('🎮 دوستانه'),
                      selected: selectedGameMode == 'friendly',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedGameMode = 'friendly';
                          });
                        }
                      },
                      backgroundColor: const Color(0xFF2a3448),
                      selectedColor: const Color(0xFFd4af87),
                      labelStyle: TextStyle(
                        color: selectedGameMode == 'friendly'
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('🏆 امتیازی • 100 🪙'),
                      selected: selectedGameMode == 'ranked',
                      onSelected: (selected) {
                        if (selected) {
                          if (!CoinManager.canPlayRanked()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'برای ورود به حالت امتیازی حداقل 100 سکه لازم است.',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            selectedGameMode = 'ranked';
                          });
                        }
                      },
                      backgroundColor: const Color(0xFF2a3448),
                      selectedColor: const Color(0xFFd4af87),
                      labelStyle: TextStyle(
                        color: selectedGameMode == 'ranked'
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                selectedGameMode == 'friendly'
                    ? 'رایگان • بدون پاداش سکه'
                    : 'ورود: 100 🪙 • برد: +20 🪙',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Player {
  final String name;
  final String role;
  final bool isUser;
  bool isAlive;

  Player({
    required this.name,
    required this.role,
    required this.isUser,
    this.isAlive = true,
  });
}

enum GamePhase { night, nightResult, day, dayResult, ended }

class GameScreen extends StatefulWidget {
  final String userRole;
  final bool isRanked;

  const GameScreen({
    super.key,
    required this.userRole,
    required this.isRanked,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _rng = Random();
  late List<Player> players;
  GamePhase phase = GamePhase.night;
  int round = 1;

  String? nightTargetName;
  String nightResultText = '';
  String? detectiveResultText;

  String? dayVoteTarget;
  String dayResultText = '';

  bool gameOver = false;
  String? winnerTeam;

  static const List<String> _botNames = [
    'آرش',
    'سارا',
    'بابک',
    'نگار',
    'کیان',
    'مهسا',
    'رضا',
    'الناز',
  ];

  @override
  void initState() {
    super.initState();
    _setupPlayers();
  }

  void _setupPlayers() {
    const totalPlayers = 6;
    final roleDeck = <String>['mafia', 'doctor', 'detective'];
    while (roleDeck.length < totalPlayers) {
      roleDeck.add('citizen');
    }

    roleDeck.remove(widget.userRole);
    roleDeck.shuffle(_rng);

    final shuffledBotNames = List<String>.from(_botNames)..shuffle(_rng);
    final botNames = shuffledBotNames.take(totalPlayers - 1).toList();

    players = [
      Player(name: 'شما', role: widget.userRole, isUser: true),
      for (int i = 0; i < botNames.length; i++)
        Player(name: botNames[i], role: roleDeck[i], isUser: false),
    ];
  }

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();
  Player get userPlayer => players.firstWhere((p) => p.isUser);

  void _confirmNightAction() {
    String? mafiaTarget;
    String? doctorHeal;

    final aliveMafia = alivePlayers.where((p) => p.role == 'mafia').toList();
    final aliveDoctor = alivePlayers.where((p) => p.role == 'doctor').toList();

    if (userPlayer.role == 'mafia' && userPlayer.isAlive) {
      mafiaTarget = nightTargetName;
    } else if (aliveMafia.isNotEmpty) {
      final candidates = alivePlayers.where((p) => p.role != 'mafia').toList();
      if (candidates.isNotEmpty) {
        mafiaTarget = candidates[_rng.nextInt(candidates.length)].name;
      }
    }

    if (userPlayer.role == 'doctor' && userPlayer.isAlive) {
      doctorHeal = nightTargetName;
    } else if (aliveDoctor.isNotEmpty) {
      doctorHeal = alivePlayers[_rng.nextInt(alivePlayers.length)].name;
    }

    if (userPlayer.role == 'detective' && userPlayer.isAlive && nightTargetName != null) {
      final target = players.firstWhere((p) => p.name == nightTargetName);
      detectiveResultText = target.role == 'mafia'
          ? '🔍 نتیجه: ${target.name} مافیاست!'
          : '🔍 نتیجه: ${target.name} بی‌گناه است.';
    } else {
      detectiveResultText = null;
    }

    String resultMsg;
    if (mafiaTarget != null && mafiaTarget != doctorHeal) {
      final victim = players.firstWhere((p) => p.name == mafiaTarget);
      victim.isAlive = false;
      resultMsg = '🌙 شب به پایان رسید. ${victim.name} کشته شد.';
    } else if (mafiaTarget != null && mafiaTarget == doctorHeal) {
      resultMsg = '🌙 شب به پایان رسید. دکتر جان یک نفر را نجات داد!';
    } else {
      resultMsg = '🌙 شب به پایان رسید. هیچ‌کس کشته نشد.';
    }

    setState(() {
      nightResultText = resultMsg;
      nightTargetName = null;
      phase = GamePhase.nightResult;
    });

    _checkWinCondition();
  }

  void _confirmDayVote() {
    final Map<String, int> voteCount = {};

    void castVote(String targetName) {
      voteCount[targetName] = (voteCount[targetName] ?? 0) + 1;
    }

    if (userPlayer.isAlive && dayVoteTarget != null) {
      castVote(dayVoteTarget!);
    }

    for (final bot in alivePlayers.where((p) => !p.isUser)) {
      final candidates = alivePlayers.where((p) => p.name != bot.name).toList();
      if (candidates.isNotEmpty) {
        final target = candidates[_rng.nextInt(candidates.length)];
        castVote(target.name);
      }
    }

    String resultMsg;
    if (voteCount.isEmpty) {
      resultMsg = '☀️ رأی‌گیری بدون نتیجه ماند. کسی حذف نشد.';
    } else {
      final maxVotes = voteCount.values.reduce(max);
      final topCandidates =
          voteCount.entries.where((e) => e.value == maxVotes).map((e) => e.key).toList();
      if (topCandidates.length > 1) {
        resultMsg = '☀️ رأی‌ها مساوی شد. امروز کسی حذف نشد.';
      } else {
        final eliminatedName = topCandidates.first;
        final eliminated = players.firstWhere((p) => p.name == eliminatedName);
        eliminated.isAlive = false;
        resultMsg =
            '☀️ $eliminatedName با رأی جمع از بازی حذف شد (نقش: ${_roleLabel(eliminated.role)}).';
      }
    }

    setState(() {
      dayResultText = resultMsg;
      dayVoteTarget = null;
      phase = GamePhase.dayResult;
    });

    _checkWinCondition();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'mafia':
        return '🔪 مافیا';
      case 'doctor':
        return '💉 دکتر';
      case 'detective':
        return '🔍 کارآگاه';
      default:
        return '👤 شهروند';
    }
  }

  void _checkWinCondition() {
    final aliveMafiaCount = alivePlayers.where((p) => p.role == 'mafia').length;
    final aliveCitizenCount = alivePlayers.where((p) => p.role != 'mafia').length;

    if (aliveMafiaCount == 0) {
      setState(() {
        gameOver = true;
        winnerTeam = 'citizens';
        phase = GamePhase.ended;
      });
    } else if (aliveMafiaCount >= aliveCitizenCount) {
      setState(() {
        gameOver = true;
        winnerTeam = 'mafia';
        phase = GamePhase.ended;
      });
    }
  }

  void _proceedToDay() {
    setState(() {
      phase = GamePhase.day;
    });
  }

  void _proceedToNight() {
    setState(() {
      round += 1;
      phase = GamePhase.night;
    });
  }

  bool get _userWon {
    if (winnerTeam == null) return false;
    final userTeam = userPlayer.role == 'mafia' ? 'mafia' : 'citizens';
    return userTeam == winnerTeam;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRanked ? '🏆 Ranked Match' : '🎮 Friendly Match'),
        backgroundColor: const Color(0xFF161f2e),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildPhaseBody(),
        ),
      ),
    );
  }

  Widget _buildPhaseBody() {
    switch (phase) {
      case GamePhase.night:
        return _buildNightPhase();
      case GamePhase.nightResult:
        return _buildNightResult();
      case GamePhase.day:
        return _buildDayPhase();
      case GamePhase.dayResult:
        return _buildDayResult();
      case GamePhase.ended:
        return _buildEndScreen();
    }
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نقش شما: ${_roleLabel(userPlayer.role)}',
            style: const TextStyle(fontSize: 20, color: Color(0xFFd4af87))),
        const SizedBox(height: 4),
        Text('دور $round', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNightPhase() {
    final aliveOthers = alivePlayers.where((p) => !p.isUser).toList();
    final userAlive = userPlayer.isAlive;

    String instruction;
    List<Player> selectable;
    switch (userPlayer.role) {
      case 'mafia':
        instruction = '🔪 یک نفر را برای حذف انتخاب کنید:';
        selectable = aliveOthers;
        break;
      case 'doctor':
        instruction = '💉 یک نفر را برای نجات انتخاب کنید:';
        selectable = alivePlayers;
        break;
      case 'detective':
        instruction = '🔍 یک نفر را برای تحقیق انتخاب کنید:';
        selectable = aliveOthers;
        break;
      default:
        instruction = '👤 شب است. منتظر بمانید...';
        selectable = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        if (!userAlive)
          const Expanded(
            child: Center(
              child: Text('💀 شما از بازی حذف شده‌اید.\nمنتظر پایان بازی بمانید.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ),
          )
        else ...[
          Text(instruction, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          if (selectable.isNotEmpty)
            Expanded(
              child: ListView(
                children: selectable.map((p) {
                  final isSelected = nightTargetName == p.name;
                  return Card(
                    color: isSelected ? const Color(0xFFd4af87) : const Color(0xFF2a3448),
                    child: ListTile(
                      title: Text(p.name,
                          style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white)),
                      onTap: () {
                        setState(() {
                          nightTargetName = p.name;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            )
          else
            const Expanded(child: Center(child: Text('صبر کنید...'))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (selectable.isEmpty || nightTargetName != null)
                  ? _confirmNightAction
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4af87),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('تایید و پایان شب'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNightResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        Text(nightResultText, style: const TextStyle(fontSize: 18)),
        if (detectiveResultText != null) ...[
          const SizedBox(height: 12),
          Text(detectiveResultText!,
              style: const TextStyle(fontSize: 16, color: Color(0xFFd4af87))),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proceedToDay,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('ادامه به روز ☀️'),
          ),
        ),
      ],
    );
  }

  Widget _buildDayPhase() {
    final voteCandidates = alivePlayers.where((p) => p.name != userPlayer.name).toList();
    final userAlive = userPlayer.isAlive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const Text('🗣️ زمان بحث و رأی‌گیری است.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text('بازیکنان زنده: ${alivePlayers.map((p) => p.name).join('، ')}',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 12),
        if (!userAlive)
          const Expanded(
            child: Center(
              child: Text('💀 شما از بازی حذف شده‌اید.\nمنتظر پایان بازی بمانید.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ),
          )
        else ...[
          const Text('به چه کسی رأی می‌دهید؟', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: voteCandidates.map((p) {
                final isSelected = dayVoteTarget == p.name;
                return Card(
                  color: isSelected ? const Color(0xFFd4af87) : const Color(0xFF2a3448),
                  child: ListTile(
                    title: Text(p.name,
                        style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                    onTap: () {
                      setState(() {
                        dayVoteTarget = p.name;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: dayVoteTarget != null ? _confirmDayVote : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4af87),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ثبت رأی'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDayResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        Text(dayResultText, style: const TextStyle(fontSize: 18)),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proceedToNight,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('ادامه به شب بعد 🌙'),
          ),
        ),
      ],
    );
  }

  Widget _buildEndScreen() {
    final won = _userWon;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            winnerTeam == 'citizens' ? '🎉 پیروزی شهروندان!' : '🔪 پیروزی مافیا!',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            won ? 'شما بردید! 🏆' : 'شما باختید.',
            style: TextStyle(
                fontSize: 20, color: won ? Colors.greenAccent : Colors.redAccent),
          ),
          const SizedBox(height: 20),
          ...players.map((p) => Text(
                '${p.isAlive ? "✅" : "☠️"} ${p.name} — ${_roleLabel(p.role)}',
                style: const TextStyle(fontSize: 14),
              )),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (won && widget.isRanked) {
                await SeasonalRanking.addWin();
                await CoinManager.addCoins(20);
              } else if (won && !widget.isRanked) {
                
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('پایان بازی و بازگشت'),
          ),
        ],
      ),
    );
  }
}

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏅 Seasonal Ranking'),
        backgroundColor: const Color(0xFF161f2e),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('فصل جاری: ${SeasonalRanking.currentSeason}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('رتبه: ${SeasonalRanking.getRank()}',
                style: const TextStyle(fontSize: 20, color: Color(0xFFd4af87))),
            const SizedBox(height: 8),
            Text('بردها: ${SeasonalRanking.wins}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('امتیاز: ${SeasonalRanking.points}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}


class RoundLobbyTestScreen extends StatefulWidget {
  const RoundLobbyTestScreen({super.key});

  @override
  State<RoundLobbyTestScreen> createState() => _RoundLobbyTestScreenState();
}

class _RoundLobbyTestScreenState extends State<RoundLobbyTestScreen> {
  LobbyGameMode selectedMode = LobbyGameMode.friendly;

  final List<LobbyPlayer> players = const [
    LobbyPlayer(id: '1', name: 'یوسف', isReady: true),
    LobbyPlayer(id: '2', name: 'آرش', isReady: true),
    LobbyPlayer(id: '3', name: 'سینا', isReady: true),
    LobbyPlayer(id: '4', name: 'نیما'),
    LobbyPlayer(id: '5', name: 'امیر', isReady: true),
    LobbyPlayer(id: '6', name: 'رضا'),
    LobbyPlayer(id: '7', name: 'ماهان', isReady: true),
    LobbyPlayer(id: '8', name: 'سام'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoundLobby(
        players: players,
        maxPlayers: 20,
        gameMode: selectedMode,
        creatorId: '1',
        managerId: '2',
        isCurrentUserCreator: true,
        isCurrentUserManager: false,
        onLeaveLobby: () {
          Navigator.of(context).maybePop();
        },
        onStartGame: () {
          final ranked = selectedMode == LobbyGameMode.ranked;

          if (ranked && !CoinManager.canPlayRanked()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('برای بازی امتیازی ۱۰۰ سکه لازم است'),
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ranked
                    ? 'لابی امتیازی آماده شروع است'
                    : 'لابی دوستانه آماده شروع است',
              ),
            ),
          );
        },
        onSeatTap: (index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('صندلی شماره ${index + 1}'),
            ),
          );
        },
      ),
    );
  }
}

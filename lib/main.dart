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
            ],
          ),
        ),
      ),
    );
  }
}

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
  String statusMessage = 'در حال بازی...';

  void handleAction(String role) {
    setState(() {
      if (role == 'mafia') {
        statusMessage = '🔪 Click on a player to kill.';
      } else if (role == 'doctor') {
        statusMessage = '💉 Click on a player to heal.';
      } else if (role == 'detective') {
        statusMessage = '🔍 Click on a player to investigate.';
      } else {
        statusMessage = '👤 Citizen phase.';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    handleAction(widget.userRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRanked ? '🏆 Ranked Match' : '🎮 Friendly Match'),
        backgroundColor: const Color(0xFF161f2e),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('نقش شما: ${widget.userRole}',
                style: const TextStyle(fontSize: 22, color: Color(0xFFd4af87))),
            const SizedBox(height: 20),
            Text(statusMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (widget.isRanked) {
                  await SeasonalRanking.addWin();
                  await CoinManager.addCoins(150);
                }
                if (!mounted) return;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('پایان بازی و بازگشت'),
            )
          ],
        ),
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

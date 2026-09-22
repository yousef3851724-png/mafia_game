import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// ۱. مدیریت سکه‌ها
// ============================================================
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

// ============================================================
// ۲. مدیریت امتیاز فصلی و رتبه‌بندی
// ============================================================
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
    if (_seasonalPoints >= 10) return '🥇 طلا';
    if (_seasonalPoints >= 5) return '🥈 نقره';
    if (_seasonalPoints >= 2) return '🥉 برنز';
    return '⚪ شرکت‌کننده';
  }

  static String getSeasonStatus() {
    return 'فصل $_currentSeason | برد: $_seasonalWins | امتیاز: $_seasonalPoints | رتبه: ${getRank()}';
  }

  static Future<void> checkSeasonReset() async {
    await loadData();
    final now = DateTime.now();
    final diff = now.difference(_seasonStart);
    if (diff.inDays >= 30) {
      await startNewSeason();
    }
  }

  // ============================================================
  // ۳. قرعه‌کشی ماهیانه (بر اساس امتیازها)
  // ============================================================
  static int get lotteryChances => _seasonalPoints;

  static Future<String?> runLottery(List<String> players, List<int> pointsList) async {
    if (players.isEmpty || pointsList.isEmpty) return null;
    int totalChances = pointsList.reduce((a, b) => a + b);
    if (totalChances == 0) return null;

    int random = DateTime.now().millisecondsSinceEpoch % totalChances;
    int cumulative = 0;
    for (int i = 0; i < players.length; i++) {
      cumulative += pointsList[i];
      if (random < cumulative) {
        return players[i];
      }
    }
    return players.last;
  }
}
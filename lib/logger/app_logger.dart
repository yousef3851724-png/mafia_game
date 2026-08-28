import 'dart:math';
import '../models/game.dart';
import '../models/player.dart';
import '../models/role.dart';

enum AIDifficulty {
  easy,    // تصمیمات تصادفی
  medium,  // تصمیمات نیمه‌هوشمند
  hard,    // تصمیمات کاملاً بهینه
}

class AIPlayer {
  final String id;
  final String name;
  final AIDifficulty difficulty;
  final Random _random = Random();

  AIPlayer({
    required this.id,
    required this.name,
    this.difficulty = AIDifficulty.medium,
  });

  // ========== تصمیم‌گیری مافیا در شب ==========
  String? chooseNightKill(Game game, String mafiaId) {
    final alive = game.alivePlayers;
    final citizens = alive.where((p) => p.role != Role.mafia).toList();

    if (citizens.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return citizens[_random.nextInt(citizens.length)].id;

      case AIDifficulty.medium:
        // اولویت با نقش‌های خاص (دکتر و کارآگاه)
        final specials = citizens.where((p) =>
            p.role == Role.doctor || p.role == Role.detective).toList();
        if (specials.isNotEmpty && _random.nextDouble() < 0.6) {
          return specials[_random.nextInt(specials.length)].id;
        }
        return citizens[_random.nextInt(citizens.length)].id;

      case AIDifficulty.hard:
        // اولویت با نقش‌های خاص، سپس بازیکن‌های باهوش
        final specials = citizens.where((p) =>
            p.role == Role.doctor || p.role == Role.detective).toList();
        if (specials.isNotEmpty) {
          return specials[_random.nextInt(specials.length)].id;
        }
        // حذف بازیکن‌هایی که قبلاً به مافیا رأی دادن
        return citizens[_random.nextInt(citizens.length)].id;
    }
  }

  // ========== تصمیم‌گیری دکتر در شب ==========
  String? chooseDoctorSave(Game game) {
    final alive = game.alivePlayers;
    final patients = alive.where((p) => p.role != Role.mafia).toList();

    if (patients.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return patients[_random.nextInt(patients.length)].id;

      case AIDifficulty.medium:
        // نجات بازیکن‌های کلیدی
        final specials = patients.where((p) =>
            p.role == Role.doctor || p.role == Role.detective).toList();
        if (specials.isNotEmpty && _random.nextDouble() < 0.5) {
          return specials[_random.nextInt(specials.length)].id;
        }
        return patients[_random.nextInt(patients.length)].id;

      case AIDifficulty.hard:
        // اولویت با کارآگاه، سپس خودش
        final detective = patients.where((p) => p.role == Role.detective).toList();
        if (detective.isNotEmpty) return detective.first.id;
        return patients[_random.nextInt(patients.length)].id;
    }
  }

  // ========== تصمیم‌گیری کارآگاه در شب ==========
  String? chooseDetectiveCheck(Game game) {
    final alive = game.alivePlayers;
    final suspects = alive.where((p) =>
        p.role != Role.detective && p.id != id).toList();

    if (suspects.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return suspects[_random.nextInt(suspects.length)].id;

      case AIDifficulty.medium:
        // بررسی بازیکن‌هایی که رفتار مشکوک دارن
        final suspicious = suspects.where((p) =>
            p.role == Role.mafia && _random.nextDouble() < 0.3).toList();
        if (suspicious.isNotEmpty) return suspicious.first.id;
        return suspects[_random.nextInt(suspects.length)].id;

      case AIDifficulty.hard:
        // بررسی بازیکن‌هایی که احتمال مافیا بودنشون بالاست
        // (در نسخه‌ی واقعی از تحلیل رفتار استفاده می‌شه)
        final mafiaSuspects = suspects.where((p) =>
            p.role == Role.mafia).toList();
        if (mafiaSuspects.isNotEmpty) return mafiaSuspects.first.id;
        return suspects[_random.nextInt(suspects.length)].id;
    }
  }

  // ========== رای‌گیری در روز ==========
  String chooseDayVote(Game game, String voterId) {
    final alive = game.alivePlayers;
    final voters = alive.where((p) => p.id != voterId).toList();

    if (voters.isEmpty) return alive.first.id;

    switch (difficulty) {
      case AIDifficulty.easy:
        return voters[_random.nextInt(voters.length)].id;

      case AIDifficulty.medium:
        // احتمال اینکه به مافیا رأی بده
        final mafia = voters.where((p) => p.role == Role.mafia).toList();
        if (mafia.isNotEmpty && _random.nextDouble() < 0.4) {
          return mafia[_random.nextInt(mafia.length)].id;
        }
        return voters[_random.nextInt(voters.length)].id;

      case AIDifficulty.hard:
        // همیشه به مافیا رأی بده (اگر شناسایی کرده باشه)
        final mafia = voters.where((p) => p.role == Role.mafia).toList();
        if (mafia.isNotEmpty) {
          return mafia[_random.nextInt(mafia.length)].id;
        }
        // وگرنه به کسی که بیشترین رأی رو داره
        return voters[_random.nextInt(voters.length)].id;
    }
  }

  // ========== تشخیص پیروزی ==========
  String getAITaunt(bool isMafiaWon) {
    final taunts = {
      true: [
        'مافیاها برنده شدن! 😈',
        'شهروندان بازنده شدن! 🎭',
        'هوش مصنوعی برتر از انسان‌هاست! 🤖',
        'باز هم مافیاها پیروز شدند! 🔪',
      ],
      false: [
        'شهروندان برنده شدن! 🎉',
        'عدالت برقرار شد! ⚖️',
        'مافیاها شکست خوردند! 😤',
        'خوبی بر شر پیروز شد! 🌟',
      ],
    };
    final list = taunts[isMafiaWon] ?? taunts[false]!;
    return list[_random.nextInt(list.length)];
  }
}

// ========== کارخانه‌ی تولید هوش مصنوعی ==========
class AIFactory {
  static List<AIPlayer> createAIPlayers({
    required int count,
    AIDifficulty difficulty = AIDifficulty.medium,
    List<String>? names,
  }) {
    final defaultNames = [
      'ربات 🤖', 'سایبر 🦾', 'هوشمند 🧠', 'نابغه 💡',
      'شبح 👻', 'نابودگر 💀', 'محاسبه‌گر 📊', 'استراتژیست ♟️',
    ];

    final nameList = names ?? defaultNames;
    return List.generate(
      count,
      (i) => AIPlayer(
        id: 'ai_$i',
        name: nameList[i % nameList.length],
        difficulty: difficulty,
      ),
    );
  }
}
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

import 'dart:math';
import '../models/game.dart';
import '../models/player.dart';
import '../models/role.dart';

enum AIDifficulty {
  easy,
  medium,
  hard,
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

  String? chooseNightKill(Game game, String mafiaId) {
    final alive = game.alivePlayers;
    final citizens = alive.where((p) => p.role != Role.mafia).toList();
    if (citizens.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return citizens[_random.nextInt(citizens.length)].id;

      case AIDifficulty.medium:
        final specials = citizens.where((p) =>
            p.role == Role.doctor || p.role == Role.detective).toList();
        if (specials.isNotEmpty && _random.nextDouble() < 0.6) {
          return specials[_random.nextInt(specials.length)].id;
        }
        return citizens[_random.nextInt(citizens.length)].id;

      case AIDifficulty.hard:
        final specials = citizens.where((p) =>
            p.role == Role.doctor || p.role == Role.detective).toList();
        if (specials.isNotEmpty) {
          return specials[_random.nextInt(specials.length)].id;
        }
        return citizens[_random.nextInt(citizens.length)].id;
    }
  }

  String? chooseDoctorSave(Game game) {
    final alive = game.alivePlayers;
    final patients = alive.where((p) => p.role != Role.mafia).toList();
    if (patients.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return patients[_random.nextInt(patients.length)].id;

      case AIDifficulty.medium:
        final specials = patients.where((p) =>
            p.role == Role.doctor || p.role == Role.detective).toList();
        if (specials.isNotEmpty && _random.nextDouble() < 0.5) {
          return specials[_random.nextInt(specials.length)].id;
        }
        return patients[_random.nextInt(patients.length)].id;

      case AIDifficulty.hard:
        final detective = patients.where((p) => p.role == Role.detective).toList();
        if (detective.isNotEmpty) return detective.first.id;
        return patients[_random.nextInt(patients.length)].id;
    }
  }

  String? chooseDetectiveCheck(Game game) {
    final alive = game.alivePlayers;
    final suspects = alive.where((p) =>
        p.role != Role.detective && p.id != id).toList();
    if (suspects.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return suspects[_random.nextInt(suspects.length)].id;

      case AIDifficulty.medium:
        final suspicious = suspects.where((p) =>
            p.role == Role.mafia && _random.nextDouble() < 0.3).toList();
        if (suspicious.isNotEmpty) return suspicious.first.id;
        return suspects[_random.nextInt(suspects.length)].id;

      case AIDifficulty.hard:
        final mafiaSuspects = suspects.where((p) =>
            p.role == Role.mafia).toList();
        if (mafiaSuspects.isNotEmpty) return mafiaSuspects.first.id;
        return suspects[_random.nextInt(suspects.length)].id;
    }
  }

  String chooseDayVote(Game game, String voterId) {
    final alive = game.alivePlayers;
    final voters = alive.where((p) => p.id != voterId).toList();
    if (voters.isEmpty) return alive.first.id;

    switch (difficulty) {
      case AIDifficulty.easy:
        return voters[_random.nextInt(voters.length)].id;

      case AIDifficulty.medium:
        final mafia = voters.where((p) => p.role == Role.mafia).toList();
        if (mafia.isNotEmpty && _random.nextDouble() < 0.4) {
          return mafia[_random.nextInt(mafia.length)].id;
        }
        return voters[_random.nextInt(voters.length)].id;

      case AIDifficulty.hard:
        final mafia = voters.where((p) => p.role == Role.mafia).toList();
        if (mafia.isNotEmpty) {
          return mafia[_random.nextInt(mafia.length)].id;
        }
        return voters[_random.nextInt(voters.length)].id;
    }
  }
}

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

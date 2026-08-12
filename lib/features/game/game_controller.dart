import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/role.dart';
import 'ai_player.dart';

class GameController extends ChangeNotifier {
  Game? _game;
  Player? _selectedPlayer;
  List<String> _nightKillVotes = [];
  Map<String, String> _dayVotes = {};
  String? _doctorSave;
  String? _detectiveCheck;
  List<AIPlayer>? _aiPlayers;

  Game? get game => _game;
  Player? get selectedPlayer => _selectedPlayer;

  // ================== شروع بازی ==================
  void initializeGameWithAI({
    required List<String> playerNames,
    int aiCount = 2,
    AIDifficulty difficulty = AIDifficulty.medium,
  }) {
    _aiPlayers = AIFactory.createAIPlayers(
      count: aiCount,
      difficulty: difficulty,
    );

    final allNames = [
      ...playerNames,
      ..._aiPlayers!.map((ai) => ai.name),
    ];

    final roles = _assignRoles(allNames.length);
    final players = List.generate(
      allNames.length,
      (i) => Player(
        id: i < playerNames.length ? 'p$i' : _aiPlayers![i - playerNames.length].id,
        name: allNames[i],
        role: roles[i],
        isAI: i >= playerNames.length,
      ),
    );

    _game = Game(id: DateTime.now().toString(), players: players);
    _resetPhaseData();
    notifyListeners();

    _processAITurns();
  }

  List<Role> _assignRoles(int count) {
    final roles = <Role>[];
    final mafiaCount = max(1, (count / 4).round());
    final doctorCount = count >= 6 ? 1 : 0;
    final detectiveCount = count >= 8 ? 1 : 0;

    roles.addAll(List.filled(mafiaCount, Role.mafia));
    if (doctorCount > 0) roles.add(Role.doctor);
    if (detectiveCount > 0) roles.add(Role.detective);
    while (roles.length < count) roles.add(Role.citizen);

    roles.shuffle(Random());
    return roles;
  }

  void _resetPhaseData() {
    _nightKillVotes = [];
    _dayVotes = {};
    _doctorSave = null;
    _detectiveCheck = null;
    _selectedPlayer = null;
  }

  // ================== پردازش نوبت هوش مصنوعی ==================
  void _processAITurns() {
    if (_game == null || _aiPlayers == null) return;

    for (var ai in _aiPlayers!) {
      final player = _game!.players.firstWhere((p) => p.id == ai.id);
      if (!player.isAlive) continue;

      switch (player.role) {
        case Role.mafia:
          final targetId = ai.chooseNightKill(_game!, player.id);
          if (targetId != null) _nightKillVotes.add(targetId);
          break;
        case Role.doctor:
          final targetId = ai.chooseDoctorSave(_game!);
          if (targetId != null) {
            _doctorSave = targetId;
            final patient = _game!.players.firstWhere((p) => p.id == targetId);
            patient.isProtected = true;
          }
          break;
        case Role.detective:
          final targetId = ai.chooseDetectiveCheck(_game!);
          if (targetId != null) {
            _detectiveCheck = targetId;
            final suspect = _game!.players.firstWhere((p) => p.id == targetId);
            debugPrint('🔍 کارآگاه (AI) بررسی کرد: ${suspect.name} -> ${suspect.role}');
          }
          break;
        default:
          break;
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      _checkNightVotes();
    });
  }

  // ================== فاز شب ==================
  void voteToKill(String voterId, String targetId) {
    if (!_game!.isNight) return;
    _nightKillVotes.add(targetId);
    _checkNightVotes();
  }

  void _checkNightVotes() {
    final mafiaPlayers = _game!.mafiaPlayers;
    if (_nightKillVotes.length < mafiaPlayers.length) return;

    final voteCount = <String, int>{};
    for (var id in _nightKillVotes) {
      voteCount[id] = (voteCount[id] ?? 0) + 1;
    }
    final maxVotes = voteCount.values.fold(0, (a, b) => a > b ? a : b);
    final targets = voteCount.keys.where((k) => voteCount[k] == maxVotes).toList();
    final targetId = targets.isNotEmpty ? targets[Random().nextInt(targets.length)] : null;

    _applyNightKill(targetId);
  }

  void _applyNightKill(String? targetId) {
    if (targetId == null) {
      _endNightPhase();
      return;
    }

    final target = _game!.players.firstWhere((p) => p.id == targetId);
    if (target.isProtected) {
      target.isProtected = false;
      _endNightPhase();
      return;
    }

    target.isAlive = false;
    _endNightPhase();
  }

  void _endNightPhase() {
    _game!.isNight = false;
    _resetPhaseData();
    _checkWinCondition();
    notifyListeners();
  }

  // ================== فاز روز ==================
  void voteToEliminate(String voterId, String targetId) {
    if (_game!.isNight) return;
    _dayVotes[voterId] = targetId;
    _checkDayVotes();
  }

  void _checkDayVotes() {
    if (_dayVotes.length < _game!.alivePlayers.length) return;

    final voteCount = <String, int>{};
    for (var target in _dayVotes.values) {
      voteCount[target] = (voteCount[target] ?? 0) + 1;
    }
    final maxVotes = voteCount.values.fold(0, (a, b) => a > b ? a : b);
    final targets = voteCount.keys.where((k) => voteCount[k] == maxVotes).toList();
    final targetId = targets.isNotEmpty ? targets[Random().nextInt(targets.length)] : null;

    _applyDayElimination(targetId);
  }

  void _applyDayElimination(String? targetId) {
    if (targetId != null) {
      final target = _game!.players.firstWhere((p) => p.id == targetId);
      target.isAlive = false;
    }
    _game!.day++;
    _game!.isNight = true;
    _resetPhaseData();
    _checkWinCondition();
    notifyListeners();

    // پردازش نوبت هوش مصنوعی برای شب جدید
    _processAITurns();
  }

  // ================== نقش‌های ویژه ==================
  void doctorSave(String patientId) {
    if (!_game!.isNight) return;
    _doctorSave = patientId;
    final patient = _game!.players.firstWhere((p) => p.id == patientId);
    patient.isProtected = true;
  }

  void detectiveCheck(String suspectId) {
    if (!_game!.isNight) return;
    _detectiveCheck = suspectId;
  }

  // ================== بررسی برنده ==================
  void _checkWinCondition() {
    if (_game!.mafiaWon) {
      debugPrint('🎭 مافیاها برنده شدند!');
      _showGameOver('مافیاها برنده شدند! 😈');
    } else if (_game!.citizenWon) {
      debugPrint('🎉 شهروندان برنده شدند!');
      _showGameOver('شهروندان برنده شدند! 🎉');
    }
  }

  void _showGameOver(String message) {
    // اینجا می‌تونی دیالوگ نمایش بدی
    Future.delayed(const Duration(seconds: 1), () {
      // برای نمایش در UI، می‌تونی یک state اضافه کنی
    });
  }

  void selectPlayer(String playerId) {
    _selectedPlayer = _game!.players.firstWhere((p) => p.id == playerId);
    notifyListeners();
  }
}

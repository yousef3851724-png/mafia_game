// Auto-play bot controller for GameRepositoryMock
import 'dart:async';
import 'dart:math';

import '../../domain/entities/player.dart';
import '../repositories/game_repository_mock.dart';

class MockAutoPlayerController {
  final GameRepositoryMock repository;
  final int initialBots;
  final int actionIntervalMs;

  final Random _rnd = Random();
  final Map<String, Timer> _botTimers = {};

  MockAutoPlayerController({
    required this.repository,
    this.initialBots = 3,
    this.actionIntervalMs = 1500,
  }) {
    _spawnInitialBots();
  }

  void _spawnInitialBots() {
    for (var i = 0; i < initialBots; i++) {
      final id = repository.addBotPlayer(name: 'Bot-${i + 1}');
      _scheduleBot(id);
    }
  }

  void _scheduleBot(String botId) {
    _botTimers[botId] = Timer.periodic(Duration(milliseconds: actionIntervalMs), (_) async {
      // choose action: 0 - vote, 1 - leave, 2 - no-op (join handled separately)
      final action = _rnd.nextInt(3);
      final players = await repository.watchPlayers().first;

      if (action == 0) {
        // vote: pick a random other player
        final targets = players.where((p) => p.id != botId).toList();
        if (targets.isEmpty) return;
        final target = targets[_rnd.nextInt(targets.length)];
        await repository.submitVote('sim', botId, target.id);
      } else if (action == 1) {
        // leave
        repository.removePlayer(botId);
        // cancel timer
        _botTimers[botId]?.cancel();
        _botTimers.remove(botId);
      } else {
        // no-op
      }
    });
  }

  /// Adds a new bot and schedules its actions
  void addBot({String? name}) {
    final id = repository.addBotPlayer(name: name ?? 'Bot-${_botTimers.length + 1}');
    _scheduleBot(id);
  }

  void dispose() {
    for (final t in _botTimers.values) {
      t.cancel();
    }
    _botTimers.clear();
  }
}

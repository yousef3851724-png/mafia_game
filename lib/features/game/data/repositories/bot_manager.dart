// Auto-play bot extension for GameRepositoryMock.
// Adds a BotManager that can spawn N bots which perform random actions every tick.

import 'dart:async';
import 'dart:math';

import '../../domain/entities/player.dart';
import '../../domain/repositories/i_game_repository.dart';
import 'game_repository_mock.dart';

class BotManager {
  final GameRepositoryMock repository;
  final int initialBots;
  final int tickMs;
  final Random _rand = Random();

  final Map<String, Timer> _botTimers = {};

  BotManager({
    required this.repository,
    this.initialBots = 3,
    this.tickMs = 1500,
  }) {
    for (var i = 0; i < initialBots; i++) {
      _spawnBot();
    }
  }

  void _spawnBot() {
    final id = repository.addBotPlayer(name: 'Bot-${_rand.nextInt(999)}');
    final timer = Timer.periodic(Duration(milliseconds: tickMs), (_) async {
      if (_rand.nextBool()) {
        // 50% chance to act: vote or leave or do nothing
        final players = await repository.watchPlayers().first;
        if (players.length <= 1) return;
        final me = players.firstWhere((p) => p.id == id, orElse: () => null);
        if (me == null) return; // maybe removed

        final actionRoll = _rand.nextInt(100);
        if (actionRoll < 60) {
          // vote: choose random target not self
          final targets = players.where((p) => p.id != id).toList();
          if (targets.isEmpty) return;
          final target = targets[_rand.nextInt(targets.length)];
          await repository.submitVote('sim', id, target.id);
        } else if (actionRoll < 80) {
          // leave
          await repository.leaveRoom('sim', id);
          // cancel timer and remove
          _botTimers[id]?.cancel();
          _botTimers.remove(id);
        } else {
          // do nothing this tick
        }
      }
    });

    _botTimers[id] = timer;
  }

  void stopAll() {
    for (final t in _botTimers.values) {
      t.cancel();
    }
    _botTimers.clear();
  }
}

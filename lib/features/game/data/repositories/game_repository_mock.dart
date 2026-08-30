// Extended Mock implementation of IGameRepository for local simulation / UI testing.
// Adds: per-voter mapping, phase stream (روز/شب), helpers: reset, addBotPlayer, removePlayer
// Adds: auto-play/robot simulation with scenarios and control methods.

import 'dart:async';
import 'dart:math';

import '../../domain/entities/player.dart';
import '../../domain/repositories/i_game_repository.dart';

class GameRepositoryMock implements IGameRepository {
  // Internal state
  final List<Player> _players = [];
  final Map<String, int> _votes = {}; // option -> count
  final Map<String, String> _voterChoice = {}; // voterId -> option

  // Stream controllers (broadcast so many listeners can subscribe)
  final StreamController<List<Player>> _playersController =
      StreamController<List<Player>>.broadcast();
  final StreamController<Map<String, int>> _votesController =
      StreamController<Map<String, int>>.broadcast();

  // Phase stream: emits 'روز' / 'شب' (Persian labels) or any custom phases
  final StreamController<String> _phaseController =
      StreamController<String>.broadcast();
  String _currentPhase = 'روز';

  // Optional: simulate network latency (milliseconds)
  final int latencyMs;

  // Auto-play / bots
  final Map<String, Timer> _botTimers = {}; // botId -> Timer
  bool _autoPlayRunning = false;
  final Random _rnd = Random();

  GameRepositoryMock({this.latencyMs = 200, List<Player>? seedPlayers}) {
    // seed with provided players or a default host
    if (seedPlayers != null && seedPlayers.isNotEmpty) {
      _players.addAll(seedPlayers);
    } else {
      final host = Player(id: 'host', name: 'Host', isHost: true);
      _players.add(host);
    }

    _emitPlayers();
    _emitVotes();
    _emitPhase();
  }

  // Helpers to emit current state
  void _emitPlayers() {
    if (!_playersController.isClosed) {
      _playersController.add(List.unmodifiable(_players));
    }
  }

  void _emitVotes() {
    if (!_votesController.isClosed) {
      _votesController.add(Map.unmodifiable(_votes));
    }
  }

  void _emitPhase() {
    if (!_phaseController.isClosed) {
      _phaseController.add(_currentPhase);
    }
  }

  // Generates a simple unique id (ok for mock / dev use)
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString() +
      _rnd.nextInt(9999).toString();

  // Public utility methods for testing / simulator UI
  /// Toggle or set phase. If [phase] is null, toggles between 'روز' and 'شب'.
  void simulatePhaseChange([String? phase]) {
    if (phase != null) {
      _currentPhase = phase;
    } else {
      _currentPhase = _currentPhase == 'روز' ? 'شب' : 'روز';
    }
    _emitPhase();
  }

  /// Adds a bot player with optional name
  String addBotPlayer({String name = 'Bot'}) {
    final id = 'bot_' + _generateId();
    final p = Player(id: id, name: name, isHost: false);
    _players.add(p);
    _emitPlayers();
    return id;
  }

  /// Removes a player and clears their recorded vote
  void removePlayer(String playerId) {
    _players.removeWhere((p) => p.id == playerId);

    final prevChoice = _voterChoice.remove(playerId);
    if (prevChoice != null) {
      final current = _votes[prevChoice] ?? 0;
      if (current <= 1) {
        _votes.remove(prevChoice);
      } else {
        _votes[prevChoice] = current - 1;
      }
    }

    // stop and remove any bot timer
    _botTimers.remove(playerId)?.cancel();

    _emitPlayers();
    _emitVotes();
  }

  /// Resets mock to initial state (keeps host)
  void reset({bool keepHost = true}) {
    // stop bots
    stopAutoPlay();

    _players.clear();
    _votes.clear();
    _voterChoice.clear();
    if (keepHost) {
      _players.add(Player(id: 'host', name: 'Host', isHost: true));
    }
    _currentPhase = 'روز';

    _emitPlayers();
    _emitVotes();
    _emitPhase();
  }

  @override
  Stream<List<Player>> watchPlayers() => _playersController.stream;

  @override
  Stream<Map<String, int>> watchVotes() => _votesController.stream;

  /// Extra stream: phase changes. Note: not part of IGameRepository interface,
  /// but provided for simulator/debug UI.
  Stream<String> watchPhase() => _phaseController.stream;

  @override
  Future<String> joinRoom(String roomId, String playerName) async {
    // simulate latency
    await Future.delayed(Duration(milliseconds: latencyMs));

    final id = _generateId();
    final newPlayer = Player(id: id, name: playerName, isHost: false);
    _players.add(newPlayer);
    _emitPlayers();
    return id;
  }

  @override
  Future<void> submitVote(String roomId, String playerId, String option) async {
    await Future.delayed(Duration(milliseconds: latencyMs));

    // if the voter had a previous choice, decrement that count
    final prev = _voterChoice[playerId];
    if (prev != null) {
      final current = _votes[prev] ?? 0;
      if (current <= 1) {
        _votes.remove(prev);
      } else {
        _votes[prev] = current - 1;
      }
    }

    // record new choice
    _voterChoice[playerId] = option;

    // increment option count
    _votes[option] = (_votes[option] ?? 0) + 1;

    // update player's vote field if present
    final idx = _players.indexWhere((p) => p.id == playerId);
    if (idx != -1) {
      _players[idx] = _players[idx].copyWith(vote: option);
    }

    // emit changes
    _emitPlayers();
    _emitVotes();
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    await Future.delayed(Duration(milliseconds: latencyMs));

    removePlayer(playerId);
  }

  // =====================
  // Auto-play / Bots
  // =====================

  /// Start auto-play with given [scenario]. If scenario is null, default quickPlay is used.
  /// [botCount] controls how many bots to create if there are not enough players.
  /// [actionIntervalMs] controls action frequency for each bot (default 1500ms).
  void startAutoPlay({String scenario = 'quick', int botCount = 5, int actionIntervalMs = 1500}) {
    if (_autoPlayRunning) return;
    _autoPlayRunning = true;

    // ensure desired number of bots exist (do not remove human players)
    final existingBots = _players.where((p) => p.id.startsWith('bot_')).toList();
    for (int i = existingBots.length; i < botCount; i++) {
      final id = 'bot_' + _generateId();
      _players.add(Player(id: id, name: 'Bot${i + 1}', isHost: false));
    }
    _emitPlayers();

    // start timers per bot
    for (final p in _players.where((p) => p.id.startsWith('bot_'))) {
      // if already has timer, skip
      if (_botTimers.containsKey(p.id)) continue;
      _botTimers[p.id] = Timer.periodic(Duration(milliseconds: actionIntervalMs), (_) async {
        if (!_autoPlayRunning) return;
        await _performBotAction(p.id, scenario);
      });
    }
  }

  Future<void> _performBotAction(String botId, String scenario) async {
    // if bot was removed, cancel
    if (!_players.any((p) => p.id == botId)) {
      _botTimers.remove(botId)?.cancel();
      return;
    }

    // choose action based on scenario
    final choice = _rnd.nextDouble();
    if (scenario == 'quick') {
      // quick: mostly vote, sometimes change phase
      if (choice < 0.75) {
        // vote for a random other player
        final targets = _players.where((p) => p.id != botId).toList();
        if (targets.isNotEmpty) {
          final target = targets[_rnd.nextInt(targets.length)];
          await submitVote('sim', botId, target.id);
        }
      } else if (choice < 0.9) {
        simulatePhaseChange();
      } else {
        // small chance to leave
        removePlayer(botId);
      }
    } else if (scenario == 'drama') {
      // drama: more joins/leaves and phase changes
      if (choice < 0.4) {
        final targets = _players.where((p) => p.id != botId).toList();
        if (targets.isNotEmpty) {
          final target = targets[_rnd.nextInt(targets.length)];
          await submitVote('sim', botId, target.id);
        }
      } else if (choice < 0.7) {
        simulatePhaseChange();
      } else if (choice < 0.9) {
        // leave and rejoin after short delay
        removePlayer(botId);
        // re-add after random delay
        Future.delayed(Duration(milliseconds: 500 + _rnd.nextInt(1500)), () => addBotPlayer(name: 'Bot'));
      } else {
        // do nothing
      }
    } else {
      // default behaviour: random vote or no-op
      if (choice < 0.6) {
        final targets = _players.where((p) => p.id != botId).toList();
        if (targets.isNotEmpty) {
          final target = targets[_rnd.nextInt(targets.length)];
          await submitVote('sim', botId, target.id);
        }
      }
    }
  }

  /// Stop auto-play and cancel bot timers.
  void stopAutoPlay() {
    if (!_autoPlayRunning) return;
    _autoPlayRunning = false;
    for (final t in _botTimers.values) {
      t.cancel();
    }
    _botTimers.clear();
  }

  /// Returns whether auto-play is currently running.
  bool get isAutoPlayRunning => _autoPlayRunning;

  @override
  Future<void> dispose() async {
    stopAutoPlay();
    if (!_playersController.isClosed) await _playersController.close();
    if (!_votesController.isClosed) await _votesController.close();
    if (!_phaseController.isClosed) await _phaseController.close();
  }
}

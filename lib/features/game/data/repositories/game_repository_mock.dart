// Extended Mock implementation of IGameRepository with auto-play (bots) and scenarios.
// Features:
// - Keeps per-voter mapping so votes can be updated/removed
// - Phase stream (روز/شب)
// - Helpers: reset, addBotPlayer, removePlayer
// - Auto-play: startAutoPlay/stopAutoPlay, configurable interval and behavior
// - Pre-defined scenarios: quickPlay, drama

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

  // Phase stream: emits 'روز' / 'شب'
  final StreamController<String> _phaseController =
      StreamController<String>.broadcast();
  String _currentPhase = 'روز';

  // Optional: simulate network latency (milliseconds)
  final int latencyMs;

  // Auto-play (bots)
  bool _autoPlayRunning = false;
  Timer? _autoPlayTimer;
  final List<String> _botIds = [];
  final Random _random = Random();

  // Auto-play configuration
  int autoPlayIntervalMs;
  double autoPlayJoinChance; // chance a bot will join if not joined
  double autoPlayLeaveChance; // chance a bot leaves on action
  double autoPlayVoteChance; // chance a bot will vote on its turn

  GameRepositoryMock({
    this.latencyMs = 200,
    List<Player>? seedPlayers,
    this.autoPlayIntervalMs = 1500,
    this.autoPlayJoinChance = 0.6,
    this.autoPlayLeaveChance = 0.05,
    this.autoPlayVoteChance = 0.8,
  }) {
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
      _random.nextInt(9999).toString();

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
    final id = _generateId();
    final p = Player(id: id, name: name, isHost: false);
    _players.add(p);
    _botIds.add(id);
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

    _botIds.remove(playerId);

    _emitPlayers();
    _emitVotes();
  }

  /// Resets mock to initial state (keeps host)
  void reset({bool keepHost = true}) {
    _players.clear();
    _votes.clear();
    _voterChoice.clear();
    _botIds.clear();
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

  // =========================
  // Auto-play / Bots
  // =========================

  /// Start auto-play: bots will randomly join/vote/leave based on configured chances.
  void startAutoPlay({int? intervalMs}) {
    if (_autoPlayRunning) return;
    _autoPlayRunning = true;
    if (intervalMs != null) autoPlayIntervalMs = intervalMs;

    _autoPlayTimer = Timer.periodic(Duration(milliseconds: autoPlayIntervalMs), (_) {
      // For each bot slot, decide an action
      // If bot is not in players list, possibly join
      if (_botIds.length < 1) {
        // ensure at least one bot in the system to act on
        addBotPlayer(name: 'Bot-${_generateId().substring(0, 4)}');
        return;
      }

      // iterate copy of bots to avoid concurrent modification
      final bots = List<String>.from(_botIds);
      for (final botId in bots) {
        // if bot not present (might have been removed), maybe join
        final present = _players.any((p) => p.id == botId);
        if (!present) {
          if (_random.nextDouble() < autoPlayJoinChance) {
            addBotPlayer(name: 'Bot-${_generateId().substring(0, 4)}');
          }
          continue;
        }

        final actionRoll = _random.nextDouble();
        if (actionRoll < autoPlayLeaveChance) {
          // leave
          removePlayer(botId);
          continue;
        }

        if (actionRoll < (autoPlayLeaveChance + autoPlayVoteChance)) {
          // vote: pick a random target (not self)
          final targets = _players.where((p) => p.id != botId).toList();
          if (targets.isNotEmpty) {
            final target = targets[_random.nextInt(targets.length)];
            submitVote('auto', botId, target.id);
          }
        }
        // else do nothing this tick
      }
    });
  }

  /// Stop auto-play
  void stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _autoPlayRunning = false;
  }

  bool get isAutoPlayRunning => _autoPlayRunning;

  // =========================
  // Pre-defined scenarios
  // =========================

  /// QuickPlay: adds [botCount] bots quickly, they join then vote immediately
  Future<void> quickPlay({int botCount = 3, int joinDelayMs = 300}) async {
    for (int i = 0; i < botCount; i++) {
      final id = addBotPlayer(name: 'QuickBot-${i + 1}');
      await Future.delayed(Duration(milliseconds: joinDelayMs));
      // Immediately vote for random existing player (not self)
      final targets = _players.where((p) => p.id != id).toList();
      if (targets.isNotEmpty) {
        final target = targets[_random.nextInt(targets.length)];
        await submitVote('scenario', id, target.id);
      }
    }
  }

  /// Drama: bots join slowly, sometimes leave, and vote with longer gaps
  Future<void> drama({int botCount = 5}) async {
    for (int i = 0; i < botCount; i++) {
      final id = addBotPlayer(name: 'DramaBot-${i + 1}');
      await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(800)));
      // maybe vote
      if (_random.nextBool()) {
        final targets = _players.where((p) => p.id != id).toList();
        if (targets.isNotEmpty) {
          final target = targets[_random.nextInt(targets.length)];
          await submitVote('scenario', id, target.id);
        }
      }
      // maybe leave later
      if (_random.nextDouble() < 0.25) {
        await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(1000)));
        removePlayer(id);
      }
    }
  }

  @override
  Future<void> dispose() async {
    stopAutoPlay();
    if (!_playersController.isClosed) await _playersController.close();
    if (!_votesController.isClosed) await _votesController.close();
    if (!_phaseController.isClosed) await _phaseController.close();
  }
}

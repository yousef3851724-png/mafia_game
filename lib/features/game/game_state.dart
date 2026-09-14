import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scenarios/custom_scenario_system.dart';
import '../scenarios/hunter_scenario.dart';
import '../scenarios/scenario_catalog.dart';
import 'player_avatar.dart';

enum GamePhase { night, dayDiscussion, dayVoting, ended }

enum NightAction { none, kill, save, investigate }

class GamePlayer {
  final String id;
  final String name;
  final String role;
  final int seat;
  final bool isUser;
  final bool alive;
  final PlayerAvatar avatar;

  const GamePlayer({required this.id, required this.name, required this.role, required this.seat, required this.isUser, required this.alive, required this.avatar});

  GamePlayer copyWith({bool? alive}) => GamePlayer(
        id: id,
        name: name,
        role: role,
        seat: seat,
        isUser: isUser,
        alive: alive ?? this.alive,
        avatar: avatar,
      );
}

class GameState {
  final GamePhase phase;
  final int round;
  final int secondsLeft;
  final List<GamePlayer> players;
  final String? selectedPlayerId;
  final String message;
  final String? winner;
  final NightAction availableAction;
  final bool nightActionDone;
  final bool initialized;

  const GameState({required this.phase, required this.round, required this.secondsLeft, required this.players, required this.selectedPlayerId, required this.message, required this.winner, required this.availableAction, required this.nightActionDone, required this.initialized});

  factory GameState.initial() => const GameState(
        phase: GamePhase.night,
        round: 1,
        secondsLeft: 20,
        players: [],
        selectedPlayerId: null,
        message: 'شب اول شروع شد. نقش خودت را اجرا کن.',
        winner: null,
        availableAction: NightAction.none,
        nightActionDone: false,
        initialized: false,
      );

  List<GamePlayer> get alivePlayers => players.where((p) => p.alive).toList(growable: false);

  GamePlayer? get user {
    for (final player in players) {
      if (player.isUser) return player;
    }
    return null;
  }

  GameState copyWith({GamePhase? phase, int? round, int? secondsLeft, List<GamePlayer>? players, Object? selectedPlayerId = _keep, String? message, Object? winner = _keep, NightAction? availableAction, bool? nightActionDone, bool? initialized}) => GameState(
        phase: phase ?? this.phase,
        round: round ?? this.round,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        players: players ?? this.players,
        selectedPlayerId: identical(selectedPlayerId, _keep) ? this.selectedPlayerId : selectedPlayerId as String?,
        message: message ?? this.message,
        winner: identical(winner, _keep) ? this.winner : winner as String?,
        availableAction: availableAction ?? this.availableAction,
        nightActionDone: nightActionDone ?? this.nightActionDone,
        initialized: initialized ?? this.initialized,
      );

  static const _keep = Object();
}

final gameControllerProvider = NotifierProvider.autoDispose<GameController, GameState>(GameController.new);

class GameController extends AutoDisposeNotifier<GameState> {
  Timer? _timer;

  @override
  GameState build() {
    ref.onDispose(() => _timer?.cancel());
    return GameState.initial();
  }

  void start({required int playerCount, ScenarioDefinition? scenario, CustomScenario? customScenario}) {
    _timer?.cancel();
    final roles = _rolesFor(scenario: scenario, customScenario: customScenario, playerCount: playerCount);
    final names = const ['شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا', 'الناز', 'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین', 'کیارش', 'مریم', 'رامین', 'نوشین'];
    final females = const {'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه', 'هلیا', 'نیکا', 'مریم', 'نوشین'};
    final built = List.generate(playerCount, (index) {
      final name = names[index % names.length];
      return GamePlayer(
        id: 'player_${index + 1}',
        name: name,
        role: roles[index % roles.length],
        seat: index + 1,
        isUser: index == 0,
        alive: true,
        avatar: PlayerAvatar(id: 'avatar_${index + 1}', displayName: name, assetPath: null, imageUrl: null, female: females.contains(name), seed: index + 1),
      );
    });
    final action = _actionForRole(built.first.role);
    state = state.copyWith(phase: GamePhase.night, round: 1, secondsLeft: 20, players: built, selectedPlayerId: null, message: 'شب اول شروع شد. ${_actionLabel(action)}', winner: null, availableAction: action, nightActionDone: false, initialized: true);
    _startTimer();
  }

  void selectPlayer(String id) {
    if (state.phase == GamePhase.ended || state.secondsLeft <= 0 || !(state.user?.alive ?? false)) return;
    final player = _find(id);
    if (player == null || !player.alive || player.isUser) return;
    state = state.copyWith(selectedPlayerId: id);
  }

  void performNightAction() {
    if (state.phase != GamePhase.night || state.nightActionDone || !(state.user?.alive ?? false)) return;
    final action = state.availableAction;
    final targetId = state.selectedPlayerId;
    if (action != NightAction.none && targetId == null) {
      state = state.copyWith(message: 'ابتدا یک بازیکن زنده را انتخاب کن.');
      return;
    }
    final target = targetId == null ? null : _find(targetId);
    if (action != NightAction.none && (target == null || !target.alive || target.isUser)) return;

    final alive = state.alivePlayers;
    final userRole = state.user?.role ?? '';
    final mafia = alive.firstWhereOrNull((p) => _isMafia(p.role));
    final doctor = alive.firstWhereOrNull((p) => p.role == 'دکتر' || p.role == 'محافظ');
    String? mafiaTargetId;
    String? saveTargetId;
    String result = 'شب تمام شد.';

    if (_isMafia(userRole)) {
      mafiaTargetId = targetId;
    } else if (mafia != null && !mafia.isUser) {
      final candidates = alive.where((p) => !p.isUser && !_isMafia(p.role)).toList();
      if (candidates.isNotEmpty) mafiaTargetId = candidates[(state.round - 1) % candidates.length].id;
    }

    if (userRole == 'دکتر' || userRole == 'محافظ') {
      saveTargetId = targetId;
    } else if (doctor != null && !doctor.isUser) {
      final candidates = alive.where((p) => !p.isUser && p.id != doctor.id).toList();
      if (candidates.isNotEmpty) saveTargetId = candidates[(state.round - 1) % candidates.length].id;
    }

    if (action == NightAction.investigate && target != null) {
      result = '${target.name}: ${_isMafia(target.role) ? 'مافیا' : 'شهروند'}';
    } else if (action == NightAction.save && target != null) {
      result = '${target.name} برای این شب محافظت شد.';
    } else if (action == NightAction.kill && target != null) {
      result = '${target.name} هدف شلیک مافیا قرار گرفت.';
    }

    var nextPlayers = state.players;
    if (mafiaTargetId != null) {
      if (mafiaTargetId == saveTargetId) {
        result = 'امشب کسی به دلیل نجات دکتر کشته نشد.';
      } else {
        final victim = _find(mafiaTargetId);
        if (victim != null && victim.alive) {
          nextPlayers = nextPlayers.map((p) => p.id == victim.id ? p.copyWith(alive: false) : p).toList(growable: false);
          if (action != NightAction.investigate && action != NightAction.save) result = '${victim.name} در شب حذف شد.';
        }
      }
    }

    state = state.copyWith(players: nextPlayers, selectedPlayerId: null, nightActionDone: true, message: result);
    _finishNightIfReady();
  }

  void startVoting() {
    if (state.phase != GamePhase.dayDiscussion || !(state.user?.alive ?? false)) return;
    state = state.copyWith(phase: GamePhase.dayVoting, secondsLeft: 15, selectedPlayerId: null, message: 'زمان رأی‌گیری شروع شد. یک بازیکن را برای اخراج انتخاب کن.');
    _startTimer();
  }

  void castVote() {
    if (state.phase != GamePhase.dayVoting || !(state.user?.alive ?? false)) return;
    final targetId = state.selectedPlayerId;
    if (targetId == null) {
      state = state.copyWith(message: 'برای اخراج یک بازیکن رأی بده.');
      return;
    }
    final target = _find(targetId);
    if (target == null || !target.alive || target.isUser) return;

    final tally = <String, int>{};
    for (final player in state.alivePlayers) {
      if (player.isUser) {
        tally[target.id] = (tally[target.id] ?? 0) + 1;
      } else {
        final candidates = state.alivePlayers.where((p) => p.id != player.id).toList();
        if (candidates.isNotEmpty) {
          final vote = candidates[(player.seat + state.round) % candidates.length];
          tally[vote.id] = (tally[vote.id] ?? 0) + 1;
        }
      }
    }
    final sorted = tally.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.isEmpty ? null : sorted.first;
    final tie = sorted.length > 1 && sorted[0].value == sorted[1].value;
    if (top == null || tie) {
      state = state.copyWith(message: 'رأی‌ها مساوی شد؛ هیچ‌کس اخراج نشد.', selectedPlayerId: null);
    } else {
      final eliminated = _find(top.key);
      if (eliminated != null) state = state.copyWith(players: _setAlive(eliminated.id, false), message: '${eliminated.name} با ${top.value} رأی از بازی خارج شد.', selectedPlayerId: null);
    }
    _checkWinner();
    if (state.phase != GamePhase.ended) {
      final nextRound = state.round + 1;
      final nextAction = _actionForRole(state.user?.role);
      state = state.copyWith(round: nextRound, phase: GamePhase.night, secondsLeft: 20, availableAction: nextAction, nightActionDone: false, message: 'شب $nextRound شروع شد. ${_actionLabel(nextAction)}');
      _startTimer();
    }
  }

  void _enterDay() {
    _checkWinner();
    if (state.phase == GamePhase.ended) return;
    state = state.copyWith(phase: GamePhase.dayDiscussion, secondsLeft: 15, selectedPlayerId: null, message: 'روز ${state.round} شروع شد؛ نتیجه شب اعلام شد. زمان بحث شروع شد.', nightActionDone: false);
    _startTimer();
  }

  void _finishNightIfReady() {
    _checkWinner();
    if (state.phase == GamePhase.ended) return;
    if (state.nightActionDone) _enterDay();
  }

  void _checkWinner() {
    final alive = state.alivePlayers;
    final mafia = alive.where((p) => _isMafia(p.role)).length;
    final citizens = alive.length - mafia;
    if (mafia == 0) {
      _timer?.cancel();
      state = state.copyWith(phase: GamePhase.ended, secondsLeft: 0, winner: 'شهروندان', message: 'همه مافیاها حذف شدند. شهروندان برنده شدند.');
    } else if (mafia >= citizens && mafia > 0) {
      _timer?.cancel();
      state = state.copyWith(phase: GamePhase.ended, secondsLeft: 0, winner: 'مافیا', message: 'تعداد مافیا با شهروندان برابر یا بیشتر شد. مافیا برنده شد.');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase == GamePhase.ended) {
        _timer?.cancel();
        return;
      }
      if (state.secondsLeft <= 1) {
        _timer?.cancel();
        _onTimerExpired();
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  void _onTimerExpired() {
    switch (state.phase) {
      case GamePhase.night:
        if (!state.nightActionDone) _resolveTimeoutNight();
        break;
      case GamePhase.dayDiscussion:
        if (state.user?.alive ?? false) {
          startVoting();
        } else {
          _startObserverVoting();
        }
        break;
      case GamePhase.dayVoting:
        _autoVote();
        break;
      case GamePhase.ended:
        break;
    }
  }

  void _resolveTimeoutNight() {
    _resolveNpcNight();
  }

  void _resolveNpcNight() {
    final alive = state.alivePlayers;
    final mafia = alive.firstWhereOrNull((p) => _isMafia(p.role));
    final doctor = alive.firstWhereOrNull((p) => p.role == 'دکتر' || p.role == 'محافظ');
    if (mafia == null) {
      state = state.copyWith(nightActionDone: true);
      _enterDay();
      return;
    }
    final candidates = alive.where((p) => !p.isUser && !_isMafia(p.role)).toList();
    if (candidates.isEmpty) {
      state = state.copyWith(nightActionDone: true);
      _enterDay();
      return;
    }
    final target = candidates[(state.round - 1) % candidates.length];
    final saveCandidates = alive.where((p) => !p.isUser && p.id != doctor?.id).toList();
    final saveId = doctor == null || saveCandidates.isEmpty ? null : saveCandidates[(state.round - 1) % saveCandidates.length].id;
    if (target.id == saveId) {
      state = state.copyWith(nightActionDone: true, message: 'امشب کسی به دلیل نجات دکتر کشته نشد.');
    } else {
      state = state.copyWith(players: _setAlive(target.id, false), nightActionDone: true, message: '${target.name} در شب حذف شد.');
    }
    _finishNightIfReady();
  }

  void _startObserverVoting() {
    state = state.copyWith(phase: GamePhase.dayVoting, secondsLeft: 10, message: 'رأی‌گیری خودکار بازیکنان زنده در حال اجراست.');
    _startTimer();
  }

  void _autoVote() {
    final candidates = state.alivePlayers.where((p) => !p.isUser).toList();
    if (candidates.isEmpty) return;
    state = state.copyWith(selectedPlayerId: candidates.first.id);
    if (state.user?.alive ?? false) {
      castVote();
    } else {
      _castObserverVote();
    }
  }

  void _castObserverVote() {
    final id = state.selectedPlayerId;
    final target = id == null ? null : _find(id);
    if (target == null) return;
    state = state.copyWith(players: _setAlive(target.id, false), message: '${target.name} با رأی میز از بازی خارج شد.', selectedPlayerId: null);
    _checkWinner();
    if (state.phase != GamePhase.ended) {
      final nextRound = state.round + 1;
      final action = _actionForRole(state.user?.role);
      state = state.copyWith(round: nextRound, phase: GamePhase.night, secondsLeft: 20, availableAction: action, nightActionDone: false, message: 'شب $nextRound شروع شد.');
      _startTimer();
    }
  }

  List<String> _rolesFor({ScenarioDefinition? scenario, CustomScenario? customScenario, required int playerCount}) {
    if (customScenario != null && customScenario.roles.isNotEmpty) return List<String>.from(customScenario.roles);
    if (scenario?.id == HunterScenario.id && HunterScenario.supports(playerCount)) return HunterScenario.rolesFor(playerCount);
    if (scenario != null && scenario.roles.isNotEmpty) return List<String>.from(scenario.roles);
    return const ['مافیا', 'دکتر', 'کارآگاه', 'شهروند'];
  }

  NightAction _actionForRole(String? role) {
    if (_isMafia(role ?? '')) return NightAction.kill;
    if (role == 'دکتر' || role == 'محافظ') return NightAction.save;
    if (role == 'کارآگاه' || role == 'بازپرس') return NightAction.investigate;
    return NightAction.none;
  }

  String _actionLabel(NightAction action) {
    switch (action) {
      case NightAction.kill:
        return 'هدف را برای شلیک انتخاب کن.';
      case NightAction.save:
        return 'یک بازیکن را برای نجات انتخاب کن.';
      case NightAction.investigate:
        return 'یک بازیکن را برای استعلام انتخاب کن.';
      case NightAction.none:
        return 'شب توسط موتور بازی اجرا می‌شود.';
    }
  }

  bool _isMafia(String role) => role == 'مافیا' || role == 'پدرخوانده';

  GamePlayer? _find(String id) {
    for (final player in state.players) {
      if (player.id == id) return player;
    }
    return null;
  }

  List<GamePlayer> _setAlive(String id, bool alive) => state.players.map((p) => p.id == id ? p.copyWith(alive: alive) : p).toList(growable: false);
}

extension on Iterable<GamePlayer> {
  GamePlayer? firstWhereOrNull(bool Function(GamePlayer) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

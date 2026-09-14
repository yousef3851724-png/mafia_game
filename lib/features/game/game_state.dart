import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_models.dart';
import '../scenarios/custom_scenario_system.dart';
import '../scenarios/scenario_catalog.dart';
import 'player_avatar.dart';

enum GamePhase { night, dayDiscussion, dayVoting, ended }
enum NightAction { none, kill, save, investigate }

class GamePlayer {
  final String id;
  final String name;
  final String role;
  final AppRole appRole;
  final int seat;
  final bool isUser;
  final bool alive;
  final int votesReceived;
  final PlayerAvatar avatar;
  final bool isLeader;
  final bool isStaff;

  const GamePlayer({
    required this.id,
    required this.name,
    required this.role,
    required this.appRole,
    required this.seat,
    required this.isUser,
    required this.alive,
    required this.avatar,
    this.votesReceived = 0,
    this.isLeader = false,
    this.isStaff = false,
  });

  GamePlayer copyWith({
    bool? alive,
    int? votesReceived,
    bool? isLeader,
    bool? isStaff,
  }) => GamePlayer(
        id: id,
        name: name,
        role: role,
        appRole: appRole,
        seat: seat,
        isUser: isUser,
        alive: alive ?? this.alive,
        votesReceived: votesReceived ?? this.votesReceived,
        avatar: avatar,
        isLeader: isLeader ?? this.isLeader,
        isStaff: isStaff ?? this.isStaff,
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

  factory GameState.initial() => const GameState(phase: GamePhase.night, round: 1, secondsLeft: 20, players: [], selectedPlayerId: null, message: 'شب اول شروع شد.', winner: null, availableAction: NightAction.none, nightActionDone: false, initialized: false);

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
  final Random _random = Random();

  @override
  GameState build() {
    ref.onDispose(() => _timer?.cancel());
    return GameState.initial();
  }

  void start({required int playerCount, ScenarioDefinition? scenario, CustomScenario? customScenario}) {
    _timer?.cancel();
    final count = playerCount.clamp(4, 20);
    final roles = _buildRandomRoles(count, scenario: scenario, customScenario: customScenario);
    const names = ['شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا', 'الناز', 'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین', 'کیارش', 'مریم', 'رامین', 'نوشین'];
    const females = {'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه', 'هلیا', 'نیکا', 'مریم', 'نوشین'};
    final avatarIds = ['avatar_shadow', 'avatar_detective', 'avatar_crimson', 'avatar_gold', 'avatar_noir'];

    final built = List.generate(count, (index) {
      final name = names[index % names.length];
      final roleName = roles[index];
      final avatarId = avatarIds[index % avatarIds.length];
      return GamePlayer(
        id: 'player_${index + 1}',
        name: name,
        role: roleName,
        appRole: roleForName(roleName),
        seat: index + 1,
        isUser: index == 0,
        alive: true,
        isLeader: index == 0,
        isStaff: index == 1,
        avatar: PlayerAvatar(id: avatarId, displayName: name, assetPath: null, imageUrl: null, female: females.contains(name), seed: index + 1),
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
    final mafia = _first(alive, (p) => _isMafia(p.role));
    final doctor = _first(alive, (p) => p.role == 'دکتر' || p.role == 'محافظ');
    String? mafiaTargetId;
    String? saveTargetId;
    var result = 'شب تمام شد.';

    if (_isMafia(userRole)) {
      mafiaTargetId = targetId;
    } else if (mafia != null) {
      final candidates = alive.where((p) => !p.isUser && !_isMafia(p.role)).toList();
      if (candidates.isNotEmpty) mafiaTargetId = candidates[_random.nextInt(candidates.length)].id;
    }

    if (userRole == 'دکتر' || userRole == 'محافظ') {
      saveTargetId = targetId;
    } else if (doctor != null) {
      final candidates = alive.where((p) => !p.isUser && p.id != doctor.id).toList();
      if (candidates.isNotEmpty) saveTargetId = candidates[_random.nextInt(candidates.length)].id;
    }

    if (action == NightAction.investigate && target != null) {
      result = '${target.name}: ${_isMafia(target.role) ? 'مافیا' : 'شهروند'}';
    } else if (action == NightAction.save && target != null) {
      result = '${target.name} برای این شب محافظت شد.';
    } else if (action == NightAction.kill && target != null) {
      result = '${target.name} هدف شلیک مافیا قرار گرفت.';
    }

    var nextPlayers = state.players;
    if (mafiaTargetId != null && mafiaTargetId != saveTargetId) {
      final victim = _find(mafiaTargetId);
      if (victim != null && victim.alive) {
        nextPlayers = _setAlive(victim.id, false);
        if (action == NightAction.kill) result = '${victim.name} در شب حذف شد.';
      }
    } else if (mafiaTargetId != null) {
      result = 'امشب کسی به دلیل نجات دکتر کشته نشد.';
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
    final alive = state.alivePlayers;
    for (final player in alive) {
      final candidates = alive.where((p) => p.id != player.id).toList();
      if (candidates.isEmpty) continue;
      final vote = player.isUser ? target : candidates[_random.nextInt(candidates.length)];
      tally[vote.id] = (tally[vote.id] ?? 0) + 1;
    }

    final updated = state.players.map((p) => p.copyWith(votesReceived: tally[p.id] ?? 0)).toList(growable: false);
    final sorted = tally.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final tie = sorted.length > 1 && sorted[0].value == sorted[1].value;
    if (sorted.isEmpty || tie) {
      state = state.copyWith(players: updated, message: 'رأی‌ها مساوی شد؛ هیچ‌کس اخراج نشد.', selectedPlayerId: null);
    } else {
      final eliminated = _find(sorted.first.key);
      if (eliminated != null) {
        state = state.copyWith(players: updated.map((p) => p.id == eliminated.id ? p.copyWith(alive: false) : p).toList(growable: false), message: '${eliminated.name} با ${sorted.first.value} رأی از بازی خارج شد.', selectedPlayerId: null);
      }
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
    if (state.phase != GamePhase.ended && state.nightActionDone) _enterDay();
  }

  void _checkWinner() {
    final alive = state.alivePlayers;
    final mafia = alive.where((p) => _isMafia(p.role)).length;
    final citizens = alive.length - mafia;
    if (mafia == 0) {
      _timer?.cancel();
      state = state.copyWith(phase: GamePhase.ended, secondsLeft: 0, winner: 'شهروندان', message: 'همه مافیاها حذف شدند. شهروندان برنده شدند.');
    } else if (mafia >= citizens) {
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
        if (!state.nightActionDone) _resolveNpcNight();
        break;
      case GamePhase.dayDiscussion:
        if (state.user?.alive ?? false) startVoting(); else _startObserverVoting();
        break;
      case GamePhase.dayVoting:
        _autoVote();
        break;
      case GamePhase.ended:
        break;
    }
  }

  void _resolveNpcNight() {
    final alive = state.alivePlayers;
    final mafia = _first(alive, (p) => _isMafia(p.role));
    final doctor = _first(alive, (p) => p.role == 'دکتر' || p.role == 'محافظ');
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
    final target = candidates[_random.nextInt(candidates.length)];
    final saveCandidates = alive.where((p) => !p.isUser && p.id != doctor?.id).toList();
    final saved = doctor == null || saveCandidates.isEmpty ? null : saveCandidates[_random.nextInt(saveCandidates.length)];
    if (target.id == saved?.id) {
      state = state.copyWith(nightActionDone: true, message: 'امشب کسی به دلیل نجات دکتر کشته نشد.');
    } else {
      state = state.copyWith(players: _setAlive(target.id, false), nightActionDone: true, message: '${target.name} در شب حذف شد.');
    }
    _finishNightIfReady();
  }

  void _startObserverVoting() {
    state = state.copyWith(phase: GamePhase.dayVoting, secondsLeft: 10, message: 'رأی‌گیری خودکار بازیکنان زنده در حال انجام است.');
    _startTimer();
  }

  void _autoVote() {
    if (state.phase != GamePhase.dayVoting) return;
    final alive = state.alivePlayers;
    if (alive.length <= 2) {
      _checkWinner();
      return;
    }
    final candidates = alive.where((p) => !_isMafia(p.role)).toList();
    final target = candidates.isNotEmpty ? candidates[_random.nextInt(candidates.length)] : alive[_random.nextInt(alive.length)];
    final updated = state.players.map((p) => p.copyWith(votesReceived: p.id == target.id ? 1 : 0, alive: p.id == target.id ? false : p.alive)).toList(growable: false);
    state = state.copyWith(players: updated, message: '${target.name} با رأی خودکار از بازی خارج شد.');
    _checkWinner();
    if (state.phase != GamePhase.ended) {
      final next = state.round + 1;
      final action = _actionForRole(state.user?.role);
      state = state.copyWith(round: next, phase: GamePhase.night, secondsLeft: 20, availableAction: action, nightActionDone: false, message: 'شب $next شروع شد. ${_actionLabel(action)}');
      _startTimer();
    }
  }

  List<String> _buildRandomRoles(int count, {ScenarioDefinition? scenario, CustomScenario? customScenario}) {
    final configured = customScenario?.roles ?? scenario?.roles ?? const <String>[];
    final special = configured.where((r) => r != 'مافیا' && r != 'شهروند' && r != 'دکتر' && r != 'کارآگاه').toList();
    final mafiaCount = count >= 10 ? 3 : count >= 7 ? 2 : 1;
    final roles = <String>[...List.filled(mafiaCount, 'مافیا')];
    if (count >= 6) roles.add('دکتر');
    if (count >= 6) roles.add('کارآگاه');
    if (special.isNotEmpty && roles.length < count) roles.add(special[_random.nextInt(special.length)]);
    while (roles.length < count) roles.add('شهروند');
    roles.shuffle(_random);
    return roles.take(count).toList(growable: false);
  }

  NightAction _actionForRole(String? role) => switch (role) {
        'مافیا' || 'پدرخوانده' => NightAction.kill,
        'دکتر' || 'محافظ' => NightAction.save,
        'کارآگاه' || 'بازپرس' => NightAction.investigate,
        _ => NightAction.none,
      };

  String _actionLabel(NightAction action) => switch (action) {
        NightAction.kill => 'یک هدف را برای شلیک انتخاب کن.',
        NightAction.save => 'یک بازیکن را برای نجات انتخاب کن.',
        NightAction.investigate => 'یک بازیکن را برای استعلام انتخاب کن.',
        NightAction.none => 'نوبت شب شما اکشن ویژه‌ای ندارد.',
      };

  bool _isMafia(String role) => role == 'مافیا' || role == 'پدرخوانده' || role.contains('مافیا');

  GamePlayer? _find(String id) {
    for (final player in state.players) {
      if (player.id == id) return player;
    }
    return null;
  }

  GamePlayer? _first(Iterable<GamePlayer> items, bool Function(GamePlayer) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  List<GamePlayer> _setAlive(String id, bool alive) => state.players.map((p) => p.id == id ? p.copyWith(alive: alive) : p).toList(growable: false);
}

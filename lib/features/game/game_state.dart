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

  const GamePlayer({
    required this.id,
    required this.name,
    required this.role,
    required this.seat,
    required this.isUser,
    required this.alive,
    required this.avatar,
  });

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

  const GameState({
    required this.phase,
    required this.round,
    required this.secondsLeft,
    required this.players,
    required this.selectedPlayerId,
    required this.message,
    required this.winner,
    required this.availableAction,
    required this.nightActionDone,
    required this.initialized,
  });

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

  GameState copyWith({
    GamePhase? phase,
    int? round,
    int? secondsLeft,
    List<GamePlayer>? players,
    Object? selectedPlayerId = _keep,
    String? message,
    Object? winner = _keep,
    NightAction? availableAction,
    bool? nightActionDone,
    bool? initialized,
  }) {
    return GameState(
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
  }

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

  void start({
    required int playerCount,
    ScenarioDefinition? scenario,
    CustomScenario? customScenario,
  }) {
    _timer?.cancel();
    final roles = _rolesFor(scenario: scenario, customScenario: customScenario, playerCount: playerCount);
    final names = const ['شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا', 'الناز', 'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین', 'کیارش', 'مریم', 'رامین', 'نوشین'];
    final females = const {'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه', 'هلیا', 'نیکا', 'مریم', 'نوشین'};

    final built = List.generate(playerCount, (index) {
      final role = roles[index % roles.length];
      final name = names[index % names.length];
      return GamePlayer(
        id: 'player_${index + 1}',
        name: name,
        role: role,
        seat: index + 1,
        isUser: index == 0,
        alive: true,
        avatar: PlayerAvatar(
          id: 'avatar_${index + 1}',
          displayName: name,
          assetPath: null,
          imageUrl: null,
          female: females.contains(name),
          seed: index + 1,
        ),
      );
    });

    final userAction = _actionForRole(built.first.role);
    state = state.copyWith(
      phase: GamePhase.night,
      round: 1,
      secondsLeft: 20,
      players: built,
      selectedPlayerId: null,
      message: 'شب اول شروع شد. ${_actionLabel(userAction)}',
      winner: null,
      availableAction: userAction,
      nightActionDone: false,
      initialized: true,
    );
    _startTimer();
  }

  void selectPlayer(String id) {
    if (state.phase == GamePhase.ended || state.secondsLeft <= 0) return;
    final player = _find(id);
    if (player == null || !player.alive || player.isUser) return;
    state = state.copyWith(selectedPlayerId: id);
  }

  void performNightAction() {
    if (state.phase != GamePhase.night || state.nightActionDone) return;
    final targetId = state.selectedPlayerId;
    final action = state.availableAction;
    if (action == NightAction.none) {
      _resolveNpcNight();
      return;
    }
    if (targetId == null) {
      state = state.copyWith(message: 'ابتدا یک بازیکن زنده را انتخاب کن.');
      return;
    }

    final target = _find(targetId);
    if (target == null || !target.alive || target.isUser) return;

    switch (action) {
      case NightAction.kill:
        state = state.copyWith(
          players: _setAlive(target.id, false),
          message: '${target.name} هدف شلیک مافیا قرار گرفت.',
          nightActionDone: true,
          selectedPlayerId: null,
        );
        break;
      case NightAction.save:
        state = state.copyWith(
          message: '${target.name} برای این شب محافظت شد.',
          nightActionDone: true,
          selectedPlayerId: null,
        );
        break;
      case NightAction.investigate:
        state = state.copyWith(
          message: '${target.name}: ${_isMafia(target.role) ? 'مافیا' : 'شهروند'}',
          nightActionDone: true,
          selectedPlayerId: null,
        );
        break;
      case NightAction.none:
        break;
    }
    _finishNightIfReady();
  }

  void _resolveNpcNight() {
    final alive = state.alivePlayers;
    final mafia = alive.firstWhereOrNull((p) => _isMafia(p.role));
    final doctor = alive.firstWhereOrNull((p) => p.role == 'دکتر' || p.role == 'محافظ');
    final candidates = alive.where((p) => !p.isUser).toList();
    if (mafia != null && candidates.isNotEmpty) {
      final target = candidates.firstWhere((p) => !_isMafia(p.role), orElse: () => candidates.first);
      final saved = doctor != null && doctor != target && target.id == _saveTarget(alive, doctor);
      if (!saved) {
        state = state.copyWith(players: _setAlive(target.id, false), message: '${target.name} در شب حذف شد.');
      } else {
        state = state.copyWith(message: 'امشب کسی به دلیل نجات دکتر کشته نشد.');
      }
    }
    state = state.copyWith(nightActionDone: true, selectedPlayerId: null);
    _finishNightIfReady();
  }

  String _saveTarget(List<GamePlayer> alive, GamePlayer doctor) {
    final candidates = alive.where((p) => !p.isUser && p.id != doctor.id).toList();
    return candidates.isEmpty ? doctor.id : candidates[(state.round - 1) % candidates.length].id;
  }

  void finishNight() {
    if (state.phase != GamePhase.night) return;
    if (!state.nightActionDone) _resolveNpcNight();
    if (state.phase == GamePhase.night) _enterDay();
  }

  void startVoting() {
    if (state.phase != GamePhase.dayDiscussion) return;
    state = state.copyWith(
      phase: GamePhase.dayVoting,
      secondsLeft: 15,
      selectedPlayerId: null,
      message: 'زمان رأی‌گیری شروع شد. یک بازیکن را انتخاب کن.',
    );
    _startTimer();
  }

  void castVote() {
    if (state.phase != GamePhase.dayVoting) return;
    final targetId = state.selectedPlayerId;
    if (targetId == null) {
      state = state.copyWith(message: 'برای اخراج یک بازیکن رأی بده.');
      return;
    }
    final target = _find(targetId);
    if (target == null || !target.alive || target.isUser) return;
    state = state.copyWith(players: _setAlive(target.id, false), message: '${target.name} با بیشترین رأی از بازی خارج شد.', selectedPlayerId: null);
    _checkWinner();
    if (state.phase != GamePhase.ended) {
      state = state.copyWith(round: state.round + 1, phase: GamePhase.night, secondsLeft: 20, availableAction: _actionForRole(state.user?.role), nightActionDone: false, message: 'شب ${state.round + 1} شروع شد. ${_actionLabel(_actionForRole(state.user?.role))}');
      _startTimer();
    }
  }

  void _enterDay() {
    _checkWinner();
    if (state.phase == GamePhase.ended) return;
    state = state.copyWith(phase: GamePhase.dayDiscussion, secondsLeft: 15, selectedPlayerId: null, message: 'روز ${state.round} شروع شد؛ کشته‌شدگان شب اعلام شدند. زمان بحث شروع شد.', nightActionDone: false);
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
    } else if (mafia >= citizens && citizens > 0) {
      _timer?.cancel();
      state = state.copyWith(phase: GamePhase.ended, secondsLeft: 0, winner: 'مافیا', message: 'تعداد مافیا با شهروندان برابر شد. مافیا برنده شد.');
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
        if (state.phase == GamePhase.night) _enterDay();
        break;
      case GamePhase.dayDiscussion:
        startVoting();
        break;
      case GamePhase.dayVoting:
        _autoVote();
        break;
      case GamePhase.ended:
        break;
    }
  }

  void _autoVote() {
    final candidates = state.alivePlayers.where((p) => !p.isUser).toList();
    if (candidates.isEmpty) return;
    state = state.copyWith(selectedPlayerId: candidates.first.id);
    castVote();
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
      case NightAction.kill: return 'هدف را برای شلیک انتخاب کن.';
      case NightAction.save: return 'یک بازیکن را برای نجات انتخاب کن.';
      case NightAction.investigate: return 'یک بازیکن را برای استعلام انتخاب کن.';
      case NightAction.none: return 'شب توسط موتور بازی اجرا می‌شود.';
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

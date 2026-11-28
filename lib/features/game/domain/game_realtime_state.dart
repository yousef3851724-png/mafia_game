// lib/features/game/domain/game_realtime_state.dart
import 'package:equatable/equatable.dart';

import 'entities/game_phase.dart';
import 'entities/game_role.dart';

/// یک بازیکن در جریان بازی real-time
class GamePlayerRT extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final int seat;
  final bool alive;
  final bool isHost;
  final bool isMe;
  final int votesAgainst;
  final bool hasActed;

  const GamePlayerRT({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.seat = 0,
    this.alive = true,
    this.isHost = false,
    this.isMe = false,
    this.votesAgainst = 0,
    this.hasActed = false,
  });

  factory GamePlayerRT.fromJson(Map<String, dynamic> j, {String? myId}) {
    return GamePlayerRT(
      id: j['id'] as String,
      name: j['name'] as String? ?? 'بازیکن',
      avatarUrl: j['avatarUrl'] as String?,
      seat: j['seat'] as int? ?? 0,
      alive: j['alive'] as bool? ?? true,
      isHost: j['isHost'] as bool? ?? false,
      isMe: j['id'] == myId,
      votesAgainst: j['votesAgainst'] as int? ?? 0,
      hasActed: j['hasActed'] as bool? ?? false,
    );
  }

  GamePlayerRT copyWith({
    String? name,
    String? avatarUrl,
    int? seat,
    bool? alive,
    bool? isHost,
    bool? isMe,
    int? votesAgainst,
    bool? hasActed,
  }) {
    return GamePlayerRT(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      seat: seat ?? this.seat,
      alive: alive ?? this.alive,
      isHost: isHost ?? this.isHost,
      isMe: isMe ?? this.isMe,
      votesAgainst: votesAgainst ?? this.votesAgainst,
      hasActed: hasActed ?? this.hasActed,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, avatarUrl, seat, alive, isHost, isMe, votesAgainst, hasActed];
}

/// وضعیت کلی بازی real-time
class GameRealtimeState extends Equatable {
  final GamePhase phase;
  final int round;
  final int secondsLeft;
  final List<GamePlayerRT> players;

  /// نقش من (فقط بعد از تخصیص)
  final GameRole? myRole;

  /// هدف انتخابی من در شب/رأی
  final String? myTarget;

  /// آخرین رخداد قابل نمایش (مثلاً «کارآگاه X را بررسی کرد»)
  final String? lastEvent;

  /// آخرین اخراجی رأی‌گیری
  final String? lastEliminated;

  /// پیام خطا
  final String? error;

  const GameRealtimeState({
    this.phase = GamePhase.lobby,
    this.round = 0,
    this.secondsLeft = 0,
    this.players = const [],
    this.myRole,
    this.myTarget,
    this.lastEvent,
    this.lastEliminated,
    this.error,
  });

  GameRealtimeState copyWith({
    GamePhase? phase,
    int? round,
    int? secondsLeft,
    List<GamePlayerRT>? players,
    GameRole? myRole,
    String? myTarget,
    String? lastEvent,
    String? lastEliminated,
    String? error,
    bool clearMyTarget = false,
    bool clearError = false,
  }) {
    return GameRealtimeState(
      phase: phase ?? this.phase,
      round: round ?? this.round,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      players: players ?? this.players,
      myRole: myRole ?? this.myRole,
      myTarget: clearMyTarget ? null : (myTarget ?? this.myTarget),
      lastEvent: lastEvent ?? this.lastEvent,
      lastEliminated: lastEliminated ?? this.lastEliminated,
      error: clearError ? null : (error ?? this.error),
    );
  }

  GamePlayerRT? get me {
    try {
      return players.firstWhere((p) => p.isMe);
    } catch (_) {
      return null;
    }
  }

  List<GamePlayerRT> get alivePlayers =>
      players.where((p) => p.alive).toList();

  List<GamePlayerRT> get deadPlayers =>
      players.where((p) => !p.alive).toList();

  int get aliveCount => alivePlayers.length;

  /// آیا فاز شب است؟
  bool get isNight => phase == GamePhase.night;

  /// آیا فاز روز/بحث است؟
  bool get isDay =>
      phase == GamePhase.day || phase == GamePhase.discussion;

  /// آیا در حال رأی‌گیری هستیم؟
  bool get isVoting => phase == GamePhase.voting;

  /// آیا بازی تموم شده؟
  bool get isEnded =>
      phase == GamePhase.ended || phase == GamePhase.result;

  /// آیا من زنده‌ام؟
  bool get amAlive => me?.alive ?? false;

  /// آیا من مافیا هستم؟
  bool get amMafia => myRole == GameRole.mafia;

  @override
  List<Object?> get props => [
        phase,
        round,
        secondsLeft,
        players,
        myRole,
        myTarget,
        lastEvent,
        lastEliminated,
        error,
      ];
}

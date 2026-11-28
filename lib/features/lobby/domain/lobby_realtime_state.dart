// lib/features/lobby/domain/lobby_realtime_state.dart
import 'package:equatable/equatable.dart';

enum LobbyConnectionStatus { disconnected, connecting, connected, reconnecting, error }

class LobbyPlayerRT extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool ready;
  final bool isHost;
  final bool isAlive;
  final int seat;

  const LobbyPlayerRT({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.ready = false,
    this.isHost = false,
    this.isAlive = true,
    this.seat = 0,
  });

  factory LobbyPlayerRT.fromJson(Map<String, dynamic> j) => LobbyPlayerRT(
        id: j['id'] as String,
        name: j['name'] as String? ?? 'بازیکن',
        avatarUrl: j['avatarUrl'] as String?,
        ready: j['ready'] as bool? ?? false,
        isHost: j['isHost'] as bool? ?? false,
        isAlive: j['isAlive'] as bool? ?? true,
        seat: j['seat'] as int? ?? 0,
      );

  LobbyPlayerRT copyWith({
    String? name,
    String? avatarUrl,
    bool? ready,
    bool? isHost,
    bool? isAlive,
    int? seat,
  }) =>
      LobbyPlayerRT(
        id: id,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        ready: ready ?? this.ready,
        isHost: isHost ?? this.isHost,
        isAlive: isAlive ?? this.isAlive,
        seat: seat ?? this.seat,
      );

  @override
  List<Object?> get props => [id, name, avatarUrl, ready, isHost, isAlive, seat];
}

class LobbyRealtimeState extends Equatable {
  final LobbyConnectionStatus status;
  final String? roomId;
  final String? myId;
  final List<LobbyPlayerRT> players;
  final String? error;
  final DateTime? lastUpdate;

  const LobbyRealtimeState({
    this.status = LobbyConnectionStatus.disconnected,
    this.roomId,
    this.myId,
    this.players = const [],
    this.error,
    this.lastUpdate,
  });

  LobbyRealtimeState copyWith({
    LobbyConnectionStatus? status,
    String? roomId,
    String? myId,
    List<LobbyPlayerRT>? players,
    String? error,
    DateTime? lastUpdate,
  }) =>
      LobbyRealtimeState(
        status: status ?? this.status,
        roomId: roomId ?? this.roomId,
        myId: myId ?? this.myId,
        players: players ?? this.players,
        error: error,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );

  LobbyPlayerRT? get me {
    if (myId == null) return null;
    try {
      return players.firstWhere((p) => p.id == myId);
    } catch (_) {
      return null;
    }
  }

  bool get isHost => me?.isHost ?? false;
  bool get amReady => me?.ready ?? false;
  int get readyCount => players.where((p) => p.ready).length;
  bool get allReady => players.isNotEmpty && readyCount == players.length;

  @override
  List<Object?> get props =>
      [status, roomId, myId, players, error, lastUpdate];
}

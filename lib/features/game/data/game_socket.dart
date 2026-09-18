// lib/features/game/data/game_socket.dart
import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../domain/entities/game_phase.dart';
import '../domain/game_realtime_state.dart';
import '../domain/entities/game_role.dart';

/// سرویس WebSocket برای بازی real-time
/// همون اتصالی که توی lobby باز شد رو ادامه می‌ده
class GameSocket {
  GameSocket({
    required this.url,
    this.autoReconnect = true,
    this.reconnectDelay = const Duration(seconds: 3),
    this.mock = false,
  });

  final String url;
  final bool autoReconnect;
  final Duration reconnectDelay;
  final bool mock;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  Timer? _tickTimer;
  bool _closedByUser = false;
  int _secondsLeft = 0;

  String? _myId;

  final _stateCtrl = StreamController<GameRealtimeState>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();

  Stream<GameRealtimeState> get stateStream => _stateCtrl.stream;
  Stream<String> get errorStream => _errorCtrl.stream;

  bool get isConnected => _channel != null;

  // ============================================================
  // اتصال به بازی
  // ============================================================
  Future<void> connect({
    required String roomId,
    required String playerId,
    String? token,
  }) async {
    _closedByUser = false;
    _myId = playerId;
    

    if (mock) {
      _startMock();
      return;
    }

    try {
      final uri = Uri.parse(
        '$url?roomId=$roomId&playerId=$playerId'
        '${token != null ? "&token=$token" : ""}'
        '&mode=game',
      );
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          _errorCtrl.add(e.toString());
          _scheduleReconnect(roomId, playerId, token);
        },
        onDone: () {
          if (!_closedByUser) _scheduleReconnect(roomId, playerId, token);
        },
      );

      _send({'type': 'game_join', 'roomId': roomId, 'playerId': playerId});
    } catch (e) {
      _errorCtrl.add(e.toString());
      _scheduleReconnect(roomId, playerId, token);
    }
  }

  void _scheduleReconnect(String roomId, String playerId, String? token) {
    if (!autoReconnect || _closedByUser) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      connect(roomId: roomId, playerId: playerId, token: token);
    });
  }

  // ============================================================
  // دریافت پیام
  // ============================================================
  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'game_state':
          _handleState(data);
          break;
        case 'phase_changed':
          _handlePhaseChange(data);
          break;
        case 'eliminated':
          _handleEliminated(data);
          break;
        case 'error':
          _errorCtrl.add(data['message'] as String? ?? 'خطای ناشناخته');
          break;
        default:
          break;
      }
    } catch (e) {
      _errorCtrl.add('پیام نامعتبر: $e');
    }
  }

  void _handleState(Map<String, dynamic> data) {
    final state = _parseState(data);
    _stateCtrl.add(state);
    _startTicker(state.secondsLeft);
  }

  void _handlePhaseChange(Map<String, dynamic> data) {
    final phaseStr = data['phase'] as String?;
    final phase = _parsePhase(phaseStr);
    final current = _lastState ?? const GameRealtimeState();
    final newState = current.copyWith(
      phase: phase,
      round: data['round'] as int? ?? current.round,
      secondsLeft: data['seconds'] as int? ?? 0,
      lastEvent: data['message'] as String?,
    );
    _stateCtrl.add(newState);
    _startTicker(newState.secondsLeft);
  }

  void _handleEliminated(Map<String, dynamic> data) {
    final playerId = data['playerId'] as String?;
    if (playerId == null) return;
    final current = _lastState;
    if (current == null) return;

    final updatedPlayers = current.players.map((p) {
      if (p.id == playerId) return p.copyWith(alive: false);
      return p;
    }).toList();

    _stateCtrl.add(current.copyWith(
      players: updatedPlayers,
      lastEliminated: playerId,
      lastEvent: data['message'] as String?,
    ));
  }

  GameRealtimeState? _lastState;

  GameRealtimeState _parseState(Map<String, dynamic> data) {
    final phase = _parsePhase(data['phase'] as String?);
    final playersList = (data['players'] as List? ?? [])
        .map((e) => GamePlayerRT.fromJson(
              e as Map<String, dynamic>,
              myId: _myId,
            ))
        .toList();

    final myRoleStr = data['myRole'] as String?;
    final myRole = myRoleStr != null ? _parseRole(myRoleStr) : null;

    final state = GameRealtimeState(
      phase: phase,
      round: data['round'] as int? ?? 0,
      secondsLeft: data['seconds'] as int? ?? 0,
      players: playersList,
      myRole: myRole,
      myTarget: data['myTarget'] as String?,
      lastEvent: data['message'] as String?,
    );

    // ذخیره برای استفاده‌های بعدی
    _lastState = state;
    _stateCtrl.add(state);
    return state;
  }

  // ============================================================
  // Ticker برای شمارش معکوس
  // ============================================================
  void _startTicker(int seconds) {
    _tickTimer?.cancel();
    _secondsLeft = seconds;
    if (seconds <= 0) return;

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _secondsLeft--;
      final current = _lastState;
      if (current == null || _secondsLeft < 0) {
        t.cancel();
        return;
      }
      final newState = current.copyWith(secondsLeft: _secondsLeft);
      _lastState = newState;
      _stateCtrl.add(newState);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  // ============================================================
  // اکشن‌های بازیکن
  // ============================================================
  void _send(Map<String, dynamic> data) {
    if (mock) return;
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      _errorCtrl.add('ارسال ناموفق: $e');
    }
  }

  /// رأی دادن به یه بازیکن (توی فاز رأی‌گیری)
  void vote(String targetId) {
    _send({'type': 'vote', 'targetId': targetId});
    _applyMyTarget(targetId);
  }

  /// انجام اکشن شب (انتخاب هدف)
  void nightAction(String targetId) {
    _send({'type': 'night_action', 'targetId': targetId});
    _applyMyTarget(targetId);
  }

  /// رد کردن نوبت (skip)
  void skip() {
    _send({'type': 'skip'});
    final current = _lastState;
    if (current != null) {
      _lastState = current.copyWith(clearMyTarget: true);
      _stateCtrl.add(_lastState!);
    }
  }

  /// چت توی بازی
  void sendChat(String text) {
    _send({'type': 'chat', 'text': text});
  }

  void _applyMyTarget(String targetId) {
    final current = _lastState;
    if (current == null) return;
    _lastState = current.copyWith(myTarget: targetId);
    _stateCtrl.add(_lastState!);
  }

  // ============================================================
  // Mock mode
  // ============================================================
  void _startMock() {
    // فاز لابی
    var state = GameRealtimeState(
      phase: GamePhase.lobby,
      players: [
        GamePlayerRT(id: _myId ?? 'me', name: 'من', isHost: true, isMe: true, seat: 0),
        GamePlayerRT(id: 'p2', name: 'بازیکن ۲', seat: 1),
        GamePlayerRT(id: 'p3', name: 'بازیکن ۳', seat: 2),
        GamePlayerRT(id: 'p4', name: 'بازیکن ۴', seat: 3),
      ],
    );
    _lastState = state;
    _stateCtrl.add(state);

    // بعد از ۲ ثانیه برو به شب
    Future.delayed(const Duration(seconds: 2), () {
      final players = _lastState!.players
          .map((p) => p.copyWith(alive: true))
          .toList();
      _lastState = _lastState!.copyWith(
        phase: GamePhase.night,
        round: 1,
        secondsLeft: 30,
        players: players,
        myRole: GameRole.detective,
        lastEvent: 'شب فرا رسید. کارآگاه بیدار شو...',
      );
      _stateCtrl.add(_lastState!);
      _startTicker(30);
    });
  }

  // ============================================================
  // کمک‌کننده‌ها
  // ============================================================
  GamePhase _parsePhase(String? s) {
    switch (s) {
      case 'lobby':
        return GamePhase.lobby;
      case 'roleAssignment':
      case 'role_assignment':
        return GamePhase.roleAssignment;
      case 'night':
        return GamePhase.night;
      case 'day':
        return GamePhase.day;
      case 'discussion':
        return GamePhase.discussion;
      case 'voting':
        return GamePhase.voting;
      case 'result':
        return GamePhase.result;
      case 'ended':
        return GamePhase.ended;
      default:
        return GamePhase.lobby;
    }
  }

  GameRole _parseRole(String s) {
    switch (s) {
      case 'mafia':
        return GameRole.mafia;
      case 'detective':
        return GameRole.detective;
      case 'doctor':
        return GameRole.doctor;
      default:
        return GameRole.citizen;
    }
  }

  // ============================================================
  // قطع اتصال
  // ============================================================
  Future<void> disconnect() async {
    _closedByUser = true;
    _reconnectTimer?.cancel();
    _tickTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateCtrl.close();
    await _errorCtrl.close();
  }
}

// lib/features/lobby/data/lobby_socket.dart
import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../domain/lobby_realtime_state.dart';

/// سرویس WebSocket برای لابی با reconnect خودکار
class LobbySocket {
  LobbySocket({
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
  bool _closedByUser = false;

  final _statusCtrl = StreamController<LobbyConnectionStatus>.broadcast();
  final _playersCtrl = StreamController<List<LobbyPlayerRT>>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();

  Stream<LobbyConnectionStatus> get statusStream => _statusCtrl.stream;
  Stream<List<LobbyPlayerRT>> get playersStream => _playersCtrl.stream;
  Stream<String> get errorStream => _errorCtrl.stream;

  bool get isConnected => _channel != null;

  // ============================================================
  // اتصال
  // ============================================================
  Future<void> connect({required String roomId, required String playerId, String? token}) async {
    _closedByUser = false;
    _statusCtrl.add(LobbyConnectionStatus.connecting);

    if (mock) {
      _startMock(roomId, playerId);
      return;
    }

    try {
      final uri = Uri.parse('$url?roomId=$roomId&playerId=$playerId${token != null ? "&token=$token" : ""}');
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _statusCtrl.add(LobbyConnectionStatus.connected);

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          _errorCtrl.add(e.toString());
          _statusCtrl.add(LobbyConnectionStatus.error);
          _scheduleReconnect(roomId, playerId, token);
        },
        onDone: () {
          _statusCtrl.add(LobbyConnectionStatus.disconnected);
          if (!_closedByUser) {
            _scheduleReconnect(roomId, playerId, token);
          }
        },
      );

      // پیام خوش‌آمد
      _send({'type': 'join', 'roomId': roomId, 'playerId': playerId});
    } catch (e) {
      _errorCtrl.add(e.toString());
      _statusCtrl.add(LobbyConnectionStatus.error);
      _scheduleReconnect(roomId, playerId, token);
    }
  }

  void _scheduleReconnect(String roomId, String playerId, String? token) {
    if (!autoReconnect || _closedByUser) return;
    _reconnectTimer?.cancel();
    _statusCtrl.add(LobbyConnectionStatus.reconnecting);
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
        case 'players':
          final list = (data['players'] as List)
              .map((e) => LobbyPlayerRT.fromJson(e as Map<String, dynamic>))
              .toList();
          _playersCtrl.add(list);
          break;
        case 'error':
          _errorCtrl.add(data['message'] as String? ?? 'خطای ناشناخته');
          break;
        default:
          // نادیده گرفتن پیام‌های ناشناخته
          break;
      }
    } catch (e) {
      _errorCtrl.add('پیام نامعتبر: $e');
    }
  }

  // ============================================================
  // ارسال
  // ============================================================
  void _send(Map<String, dynamic> data) {
    if (mock) return;
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      _errorCtrl.add('ارسال ناموفق: $e');
    }
  }

  void setReady(bool ready) => _send({'type': 'ready', 'value': ready});
  void kick(String playerId) => _send({'type': 'kick', 'playerId': playerId});
  void startGame() => _send({'type': 'start'});
  void sendChat(String text) => _send({'type': 'chat', 'text': text});
  void changeSeat(int seat) => _send({'type': 'seat', 'seat': seat});

  // ============================================================
  // Mock mode (برای تست بدون سرور)
  // ============================================================
  void _startMock(String roomId, String playerId) {
    _statusCtrl.add(LobbyConnectionStatus.connected);
    _playersCtrl.add([
      LobbyPlayerRT(id: playerId, name: 'من', isHost: true, seat: 0),
      LobbyPlayerRT(id: 'p2', name: 'بازیکن ۲', ready: true, seat: 1),
      LobbyPlayerRT(id: 'p3', name: 'بازیکن ۳', seat: 2),
    ]);
  }

  // ============================================================
  // قطع اتصال
  // ============================================================
  Future<void> disconnect() async {
    _closedByUser = true;
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _statusCtrl.add(LobbyConnectionStatus.disconnected);
  }

  Future<void> dispose() async {
    await disconnect();
    await _statusCtrl.close();
    await _playersCtrl.close();
    await _errorCtrl.close();
  }
}

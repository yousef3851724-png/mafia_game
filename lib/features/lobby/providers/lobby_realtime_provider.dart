// lib/features/lobby/providers/lobby_realtime_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lobby_socket.dart';
import '../domain/lobby_realtime_state.dart';

const kLobbyWsUrl = 'wss://your-server.example.com/lobby';
const kLobbyUseMock = true;

final lobbyRealtimeProvider =
    StateNotifierProvider.autoDispose<LobbyRealtimeController, LobbyRealtimeState>(
  (ref) {
    final controller = LobbyRealtimeController();
    ref.onDispose(() => controller.dispose());
    return controller;
  },
);

class LobbyRealtimeController extends StateNotifier<LobbyRealtimeState> {
  LobbyRealtimeController() : super(const LobbyRealtimeState());

  LobbySocket? _socket;
  StreamSubscription? _statusSub;
  StreamSubscription? _playersSub;
  StreamSubscription? _errorSub;

  Future<void> join({
    required String roomId,
    required String playerId,
    String? token,
  }) async {
    if (_socket != null) {
      await _socket!.disconnect();
    }

    _socket = LobbySocket(
      url: kLobbyWsUrl,
      autoReconnect: true,
      mock: kLobbyUseMock,
    );

    _statusSub = _socket!.statusStream.listen((status) {
      state = state.copyWith(status: status);
    });

    _playersSub = _socket!.playersStream.listen((players) {
      state = state.copyWith(
        players: players,
        lastUpdate: DateTime.now(),
      );
    });

    _errorSub = _socket!.errorStream.listen((error) {
      state = state.copyWith(error: error);
    });

    await _socket!.connect(
      roomId: roomId,
      playerId: playerId,
      token: token,
    );

    state = state.copyWith(roomId: roomId, myId: playerId);
  }

  Future<void> leave() async {
    await _socket?.disconnect();
    _socket = null;
    state = const LobbyRealtimeState();
  }

  void toggleReady() {
    final current = state.amReady;
    _socket?.setReady(!current);
    if (state.myId != null) {
      final updated = state.players.map((p) {
        if (p.id == state.myId) return p.copyWith(ready: !current);
        return p;
      }).toList();
      state = state.copyWith(players: updated);
    }
  }

  void kick(String playerId) {
    if (!state.isHost) return;
    _socket?.kick(playerId);
  }

  void startGame() {
    if (!state.isHost || !state.allReady) return;
    _socket?.startGame();
  }

  void sendChat(String text) {
    if (text.trim().isEmpty) return;
    _socket?.sendChat(text.trim());
  }

  void changeSeat(int seat) {
    _socket?.changeSeat(seat);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _playersSub?.cancel();
    _errorSub?.cancel();
    _socket?.dispose();
    super.dispose();
  }
}

final lobbyStatusProvider = Provider.autoDispose<LobbyConnectionStatus>(
  (ref) => ref.watch(lobbyRealtimeProvider.select((s) => s.status)),
);

final lobbyPlayersProvider = Provider.autoDispose<List<LobbyPlayerRT>>(
  (ref) => ref.watch(lobbyRealtimeProvider.select((s) => s.players)),
);

final lobbyAmReadyProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(lobbyRealtimeProvider.select((s) => s.amReady)),
);

final lobbyIsHostProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(lobbyRealtimeProvider.select((s) => s.isHost)),
);

final lobbyAllReadyProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(lobbyRealtimeProvider.select((s) => s.allReady)),
);
final lobbyErrorProvider = Provider.autoDispose<String?>(
  (ref) => ref.watch(lobbyRealtimeProvider.select((s) => s.error)),
);

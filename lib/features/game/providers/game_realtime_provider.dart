// lib/features/game/providers/game_realtime_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_socket.dart';
import '../domain/entities/game_phase.dart';
import '../domain/entities/game_role.dart';
import '../domain/game_realtime_state.dart';

const kGameWsUrl = 'wss://your-server.example.com/lobby';
const kGameUseMock = true;

final gameRealtimeProvider =
    StateNotifierProvider.autoDispose<GameRealtimeController, GameRealtimeState>(
  (ref) {
    final controller = GameRealtimeController();
    ref.onDispose(() => controller.dispose());
    return controller;
  },
);

class GameRealtimeController extends StateNotifier<GameRealtimeState> {
  GameRealtimeController() : super(const GameRealtimeState());

  GameSocket? _socket;
  StreamSubscription? _stateSub;
  StreamSubscription? _errorSub;

  Future<void> join({
    required String roomId,
    required String playerId,
    String? token,
  }) async {
    if (_socket != null) {
      await _socket!.disconnect();
    }

    _socket = GameSocket(
      url: kGameWsUrl,
      autoReconnect: true,
      mock: kGameUseMock,
    );

    _stateSub = _socket!.stateStream.listen((s) {
      state = s;
    });

    _errorSub = _socket!.errorStream.listen((e) {
      state = state.copyWith(error: e);
    });

    await _socket!.connect(
      roomId: roomId,
      playerId: playerId,
      token: token,
    );
  }

  void vote(String targetId) {
    if (!state.isVoting) return;
    if (!state.amAlive) return;
    _socket?.vote(targetId);
  }

  void nightAction(String targetId) {
    if (!state.isNight) return;
    if (!state.amAlive) return;
    _socket?.nightAction(targetId);
  }

  void skip() {
    if (!state.amAlive) return;
    _socket?.skip();
  }

  void sendChat(String text) {
    if (text.trim().isEmpty) return;
    _socket?.sendChat(text.trim());
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> leave() async {
    await _socket?.disconnect();
    _socket = null;
    state = const GameRealtimeState();
  }

  List<GamePlayerRT> getTargets() {
    return state.alivePlayers.where((p) => !p.isMe).toList();
  }

  bool canAct() {
    if (!state.amAlive) return false;
    switch (state.phase) {
      case GamePhase.night:
        return state.myRole == GameRole.mafia ||
            state.myRole == GameRole.detective ||
            state.myRole == GameRole.doctor;
      case GamePhase.voting:
        return true;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _errorSub?.cancel();
    _socket?.dispose();
    super.dispose();
  }
}

final gamePhaseProvider = Provider.autoDispose<GamePhase>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.phase)),
);

final gamePlayersProvider = Provider.autoDispose<List<GamePlayerRT>>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.players)),
);

final gameMyRoleProvider = Provider.autoDispose<GameRole?>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.myRole)),
);

final gameAmAliveProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.amAlive)),
);

final gameSecondsProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.secondsLeft)),
);

final gameRoundProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.round)),
);

final gameErrorProvider = Provider.autoDispose<String?>(
  (ref) => ref.watch(gameRealtimeProvider.select((s) => s.error)),
);

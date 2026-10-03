// lib/features/lobby/providers/lobby_realtime_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lobby_socket.dart';
import '../domain/lobby_realtime_state.dart';

// آدرس سرور WebSocket.
// - اگر APK روی همان گوشی که سرور است: 127.0.0.1
// - از گوشی دوم: IP محلی گوشی اول (مثلاً 192.168.1.42)
const kLobbyWsUrl = 'ws://127.0.0.1:8080/lobby';

// mock خاموش، تا به سرور واقعی وصل شود
const kLobbyUseMock = false;

final lobbyRealtimeProvider = Provider<LobbySocket>((ref) {
  final socket = LobbySocket(
    url: kLobbyWsUrl,
    mock: kLobbyUseMock,
  );
  ref.onDispose(socket.dispose);
  return socket;
});

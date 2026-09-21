import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/lobby_domain.dart';

class LobbyController extends StateNotifier<AsyncValue<List<Lobby>>> {
  LobbyController() : super(const AsyncValue.loading());

  Future<void> fetchLobbies() async {
    try {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncValue.data([
        Lobby(id: '1', name: 'Lobby 1', players: 6, maxPlayers: 20, status: 'waiting'),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final lobbyControllerProvider = StateNotifierProvider<LobbyController, AsyncValue<List<Lobby>>>((ref) {
  final controller = LobbyController();
  controller.fetchLobbies();
  return controller;
});

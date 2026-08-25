import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';

// یک لیست اولیه برای شروع بازی
class PlayerNotifier extends StateNotifier<List<Player>> {
  PlayerNotifier() : super([]);

  void addPlayer(String name) {
    state = [...state, Player(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, role: '')];
  }

  void removePlayer(String id) {
    state = state.where((player) => player.id != id).toList();
  }

  void clearPlayers() {
    state = [];
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>((ref) {
  return PlayerNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../database/database_helper.dart';

class PlayerNotifier extends StateNotifier<List<Player>> {
  PlayerNotifier() : super([]) {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await DatabaseHelper.instance.getPlayers();
    state = players;
  }

  void addPlayer(String name) {
    final player = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: '',
    );
    state = [...state, player];
    DatabaseHelper.instance.insertPlayer(player); // ذخیره در دیتابیس
  }

  void removePlayer(String id) {
    state = state.where((player) => player.id != id).toList();
    // (برای حذف از دیتابیس نیاز به کد اضافه‌تر است که بعداً اضافه می‌کنیم)
  }

  void clearPlayers() {
    state = [];
    DatabaseHelper.instance.clearPlayers();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>((ref) {
  return PlayerNotifier();
});

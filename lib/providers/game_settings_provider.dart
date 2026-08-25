import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameSettings {
  final int minPlayers;
  final int maxPlayers;
  final bool isSoundEnabled;

  GameSettings({
    this.minPlayers = 6,
    this.maxPlayers = 16,
    this.isSoundEnabled = true,
  });
}

class GameSettingsNotifier extends StateNotifier<GameSettings> {
  GameSettingsNotifier() : super(GameSettings());

  void toggleSound() {
    state = GameSettings(
      minPlayers: state.minPlayers,
      maxPlayers: state.maxPlayers,
      isSoundEnabled: !state.isSoundEnabled,
    );
  }
}

final gameSettingsProvider = StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
  return GameSettingsNotifier();
});

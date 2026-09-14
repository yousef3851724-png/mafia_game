
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_provider.g.dart';

enum GamePhase { lobby, night, day, voting, gameOver }

class GameState {
  final String roomId;
  final GamePhase phase;
  final List<String> players;
  final Map<String, String> roles;

  GameState({
    required this.roomId,
    this.phase = GamePhase.lobby,
    this.players = const [],
    this.roles = const {},
  });
}

@riverpod
class GameNotifier extends _$GameNotifier {
  @override
  GameState build(String roomId) {
    return GameState(roomId: roomId);
  }

  void updatePhase(GamePhase newPhase) {
    state = GameState(
      roomId: state.roomId,
      phase: newPhase,
      players: state.players,
      roles: state.roles,
    );
  }
}

import 'dart:async';
import 'game_state.dart';
import '../../domain/entities/player.dart';
import '../../domain/usecases/join_room_usecase.dart';
import '../../domain/usecases/submit_vote_usecase.dart';

class GameBloc {
  final JoinRoomUseCase joinRoomUseCase;
  final SubmitVoteUseCase submitVoteUseCase;

  final _stateController = StreamController<GameState>.broadcast();
  GameState _state = const GameState();

  GameBloc({
    required this.joinRoomUseCase,
    required this.submitVoteUseCase,
  }) {
    _stateController.add(_state);
  }

  Stream<GameState> get stateStream => _stateController.stream;
  GameState get state => _state;

  void _emit(GameState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  Future<void> joinGame(String roomId, String playerName) async {
    _emit(_state.copyWith(status: GameStatus.loading));
    try {
      await joinRoomUseCase(roomId: roomId, playerName: playerName);
      // شبیه‌سازی بازیکنان اولیه
      final mockPlayers = [
        const Player(id: '1', name: 'پدرخوانده', role: 'مافیا'),
        const Player(id: '2', name: 'کارآگاه', role: 'شهروند'),
        const Player(id: '3', name: 'دکتر', role: 'شهروند'),
        const Player(id: '4', name: 'تک تیرانداز', role: 'شهروند'),
      ];
      _emit(_state.copyWith(status: GameStatus.active, players: mockPlayers));
    } catch (e) {
      _emit(_state.copyWith(status: GameStatus.error, errorMessage: e.toString()));
    }
  }

  void selectPlayer(String playerId) {
    _emit(_state.copyWith(selectedPlayerId: playerId));
  }

  Future<void> vote(String roomId, String voterId, String targetId) async {
    await submitVoteUseCase(
      roomId: roomId,
      voterId: voterId,
      targetPlayerId: targetId,
    );
  }

  void dispose() {
    _stateController.close();
  }
}

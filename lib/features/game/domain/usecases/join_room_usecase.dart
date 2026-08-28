import '../repositories/i_game_repository.dart';

class JoinRoomUseCase {
  final IGameRepository repository;

  JoinRoomUseCase(this.repository);

  Future<void> call({required String roomId, required String playerName}) {
    return repository.joinRoom(roomId, playerName);
  }
}

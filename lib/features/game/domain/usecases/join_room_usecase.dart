import '../repositories/i_game_repository.dart';

class JoinRoomUseCase {
  final IGameRepository repository;

  const JoinRoomUseCase(this.repository);

  Future<String> call({required String roomId, required String playerName}) {
    return repository.joinRoom(roomId, playerName);
  }
}

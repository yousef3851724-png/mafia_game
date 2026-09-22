import '../repositories/i_game_repository.dart';

class LeaveRoomUseCase {
  final IGameRepository repository;

  const LeaveRoomUseCase(this.repository);

  Future<void> call({required String roomId, required String playerId}) {
    return repository.leaveRoom(roomId, playerId);
  }
}

import '../repositories/i_game_repository.dart';

class SubmitVoteUseCase {
  final IGameRepository repository;

  const SubmitVoteUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String voterId,
    required String targetPlayerId,
  }) {
    return repository.submitVote(roomId, voterId, targetPlayerId);
  }
}

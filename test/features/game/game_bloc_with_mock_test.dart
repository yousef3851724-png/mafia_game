import 'package:flutter_test/flutter_test.dart';

import 'package:mafia_game/features/game/presentation/state/game_bloc.dart';
import 'package:mafia_game/features/game/data/repositories/game_repository_mock.dart';
import 'package:mafia_game/features/game/domain/usecases/join_room_usecase.dart';
import 'package:mafia_game/features/game/domain/usecases/submit_vote_usecase.dart';
import 'package:mafia_game/features/game/domain/usecases/leave_room_usecase.dart';

void main() {
  test('GameBloc integrates with GameRepositoryMock', () async {
    final repo = GameRepositoryMock(latencyMs: 10);
    final bloc = GameBloc(
      repository: repo,
      joinRoomUseCase: JoinRoomUseCase(repo),
      submitVoteUseCase: SubmitVoteUseCase(repo),
      leaveRoomUseCase: LeaveRoomUseCase(repo),
    );

    // join a player
    final playerId = await repo.joinRoom('test', 'Alice');

    // ensure players stream emits
    final players = await repo.watchPlayers().first;
    expect(players.any((p) => p.id == playerId), true);

    // submit vote
    await repo.submitVote('test', playerId, 'optionA');
    final votes = await repo.watchVotes().first;
    expect(votes['optionA'], 1);

    // leave room
    await repo.leaveRoom('test', playerId);
    final playersAfter = await repo.watchPlayers().first;
    expect(playersAfter.any((p) => p.id == playerId), false);

    await bloc.close();
    await repo.dispose();
  });
}

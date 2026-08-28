import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/game_local_datasource.dart';
import 'data/datasources/game_remote_datasource.dart';
import 'data/repositories/game_repository_impl.dart';
import 'domain/usecases/join_room_usecase.dart';
import 'domain/usecases/leave_room_usecase.dart';
import 'domain/usecases/submit_vote_usecase.dart';
import 'presentation/state/game_bloc.dart';

/// Dependency-injection factory for the Game feature.
class GameModule {
  const GameModule._();

  static Future<GameBloc> createBloc({
    required SharedPreferences preferences,
  }) async {
    final remoteDataSource = GameRemoteDataSourceImpl();
    final localDataSource = GameLocalDataSourceImpl(preferences);
    final repository = GameRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    return GameBloc(
      repository: repository,
      joinRoomUseCase: JoinRoomUseCase(repository),
      submitVoteUseCase: SubmitVoteUseCase(repository),
      leaveRoomUseCase: LeaveRoomUseCase(repository),
    );
  }
}

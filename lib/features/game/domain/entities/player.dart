"lib/features/game/domain/entities/player.dart"

import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final bool isHost;
  final String? vote;

  const Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.vote,
  });

  Player copyWith({
    String? id,
    String? name,
    bool? isHost,
    String? vote,
    bool clearVote = false,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      vote: clearVote ? null : (vote ?? this.vote),
    );
  }

  @override
  List<Object?> get props => [id, name, isHost, vote];
}

"lib/features/game/domain/repositories/i_game_repository.dart"

import '../entities/player.dart';

abstract class IGameRepository {
  Stream<List<Player>> watchPlayers();

  Stream<Map<String, int>> watchVotes();

  Future<String> joinRoom(
    String roomId,
    String playerName,
  );

  Future<void> submitVote(
    String roomId,
    String playerId,
    String option,
  );

  Future<void> leaveRoom(
    String roomId,
    String playerId,
  );

  Future<void> dispose();
}

"lib/features/game/domain/usecases/join_room_usecase.dart"

import '../repositories/i_game_repository.dart';

class JoinRoomUseCase {
  final IGameRepository repository;

  const JoinRoomUseCase(this.repository);

  Future<String> call(
    String roomId,
    String playerName,
  ) {
    return repository.joinRoom(roomId, playerName);
  }
}

"lib/features/game/domain/usecases/submit_vote_usecase.dart"

import '../repositories/i_game_repository.dart';

class SubmitVoteUseCase {
  final IGameRepository repository;

  const SubmitVoteUseCase(this.repository);

  Future<void> call(
    String roomId,
    String playerId,
    String option,
  ) {
    return repository.submitVote(
      roomId,
      playerId,
      option,
    );
  }
}

"lib/features/game/domain/usecases/leave_room_usecase.dart"

import '../repositories/i_game_repository.dart';

class LeaveRoomUseCase {
  final IGameRepository repository;

  const LeaveRoomUseCase(this.repository);

  Future<void> call(
    String roomId,
    String playerId,
  ) {
    return repository.leaveRoom(
      roomId,
      playerId,
    );
  }
}
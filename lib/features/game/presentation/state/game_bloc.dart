import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/player.dart';
import '../../domain/repositories/i_game_repository.dart';
import '../../domain/usecases/join_room_usecase.dart';
import '../../domain/usecases/leave_room_usecase.dart';
import '../../domain/usecases/submit_vote_usecase.dart';
import 'game_state.dart';

abstract class GameEvent {
  const GameEvent();
}

class JoinRoomRequested extends GameEvent {
  final String roomId;
  final String playerName;

  const JoinRoomRequested({required this.roomId, required this.playerName});
}

class VoteRequested extends GameEvent {
  final String option;

  const VoteRequested(this.option);
}

class LeaveRoomRequested extends GameEvent {
  const LeaveRoomRequested();
}

class GameBloc extends Bloc<GameEvent, GameState> {
  final JoinRoomUseCase joinRoomUseCase;
  final SubmitVoteUseCase submitVoteUseCase;
  final LeaveRoomUseCase leaveRoomUseCase;
  final IGameRepository repository;

  StreamSubscription<List<Player>>? _playersSubscription;
  StreamSubscription<Map<String, int>>? _votesSubscription;

  String _roomId = '';
  String _currentPlayerId = '';
  List<Player> _players = const [];
  Map<String, int> _votes = const {};

  GameBloc({
    required this.joinRoomUseCase,
    required this.submitVoteUseCase,
    required this.leaveRoomUseCase,
    required this.repository,
  }) : super(const GameState()) {
    on<JoinRoomRequested>(_onJoinRoom);
    on<VoteRequested>(_onVote);
    on<LeaveRoomRequested>(_onLeaveRoom);
  }

  Future<void> _subscribeToGame() async {
    await _playersSubscription?.cancel();
    await _votesSubscription?.cancel();

    _playersSubscription = repository.watchPlayers().listen((players) {
      _players = List.unmodifiable(players);
      if (isClosed) return;
      add(_InternalPlayersUpdated(_players));
    });

    _votesSubscription = repository.watchVotes().listen((votes) {
      _votes = Map.unmodifiable(votes);
      if (isClosed) return;
      add(_InternalVotesUpdated(_votes));
    });
  }

  Future<void> _onJoinRoom(
    JoinRoomRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(
      status: GameStatus.loading,
      roomId: event.roomId.trim(),
      clearError: true,
    ));

    try {
      _roomId = event.roomId.trim();
      await _subscribeToGame();
      _currentPlayerId = await joinRoomUseCase(
        roomId: _roomId,
        playerName: event.playerName,
      );

      emit(state.copyWith(
        status: GameStatus.loaded,
        players: _players,
        votes: _votes,
        currentPlayerId: _currentPlayerId,
        roomId: _roomId,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onVote(
    VoteRequested event,
    Emitter<GameState> emit,
  ) async {
    if (_roomId.isEmpty || _currentPlayerId.isEmpty) return;
    if (!_players.any((p) => p.id == _currentPlayerId)) return;
    if (!_players.any((p) => p.vote == null && p.id == _currentPlayerId)) return;

    try {
      await submitVoteUseCase(
        roomId: _roomId,
        voterId: _currentPlayerId,
        targetPlayerId: event.option,
      );
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLeaveRoom(
    LeaveRoomRequested event,
    Emitter<GameState> emit,
  ) async {
    try {
      if (_roomId.isNotEmpty && _currentPlayerId.isNotEmpty) {
        await leaveRoomUseCase(
          roomId: _roomId,
          playerId: _currentPlayerId,
        );
      }
      emit(const GameState());
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _playersSubscription?.cancel();
    await _votesSubscription?.cancel();
    await repository.dispose();
    return super.close();
  }
}

class _InternalPlayersUpdated extends GameEvent {
  final List<Player> players;
  const _InternalPlayersUpdated(this.players);
}

class _InternalVotesUpdated extends GameEvent {
  final Map<String, int> votes;
  const _InternalVotesUpdated(this.votes);
}

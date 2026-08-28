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

class _PlayersUpdated extends GameEvent {
  final List<Player> players;
  const _PlayersUpdated(this.players);
}

class _VotesUpdated extends GameEvent {
  final Map<String, int> votes;
  const _VotesUpdated(this.votes);
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
    on<_PlayersUpdated>(_onPlayersUpdated);
    on<_VotesUpdated>(_onVotesUpdated);
  }

  Future<void> _subscribeToGame() async {
    await _playersSubscription?.cancel();
    await _votesSubscription?.cancel();

    _playersSubscription = repository.watchPlayers().listen((players) {
      _players = List.unmodifiable(players);
      if (!isClosed) add(_PlayersUpdated(_players));
    });

    _votesSubscription = repository.watchVotes().listen((votes) {
      _votes = Map.unmodifiable(votes);
      if (!isClosed) add(_VotesUpdated(_votes));
    });
  }

  Future<void> _onJoinRoom(
    JoinRoomRequested event,
    Emitter<GameState> emit,
  ) async {
    final roomId = event.roomId.trim();
    final playerName = event.playerName.trim();

    if (roomId.isEmpty || playerName.isEmpty) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'شناسه اتاق و نام بازیکن الزامی است.',
      ));
      return;
    }

    emit(state.copyWith(
      status: GameStatus.loading,
      roomId: roomId,
      clearError: true,
    ));

    try {
      _roomId = roomId;
      await _subscribeToGame();
      _currentPlayerId = await joinRoomUseCase(
        roomId: roomId,
        playerName: playerName,
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

    final me = _players.where((p) => p.id == _currentPlayerId).firstOrNull;
    if (me == null || me.vote != null) return;

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

  void _onPlayersUpdated(
    _PlayersUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(
      status: state.status == GameStatus.loading
          ? GameStatus.loading
          : GameStatus.loaded,
      players: event.players,
      currentPlayerId: _currentPlayerId,
      roomId: _roomId,
      clearError: true,
    ));
  }

  void _onVotesUpdated(
    _VotesUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(
      status: state.status == GameStatus.loading
          ? GameStatus.loading
          : GameStatus.loaded,
      votes: event.votes,
      currentPlayerId: _currentPlayerId,
      roomId: _roomId,
      clearError: true,
    ));
  }

  @override
  Future<void> close() async {
    await _playersSubscription?.cancel();
    await _votesSubscription?.cancel();
    await repository.dispose();
    return super.close();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

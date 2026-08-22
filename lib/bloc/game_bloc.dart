import 'package:equatable/equatable.dart';
import '../logic/game_engine.dart';
import '../models/role_model.dart';

abstract class GameState extends Equatable {
  const GameState();
  @override
  List<Object?> get props => [];
}

class GameInitialState extends GameState {}

class GameInProgressState extends GameState {
  final GameEngine engine;
  final List<String> playerNames;
  final Map<int, RoleModel> playerRoles;
  final String? investigationResult;

  const GameInProgressState({
    required this.engine,
    required this.playerNames,
    required this.playerRoles,
    this.investigationResult,
  });

  @override
  List<Object?> get props => [engine, playerNames, playerRoles, investigationResult];
}

class GameOverState extends GameState {
  final String winner;
  const GameOverState({required this.winner});
  @override
  List<Object?> get props => [winner];
}
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mafia_game/bloc/game_event.dart';
import 'package:mafia_game/bloc/game_state.dart';
import 'package:mafia_game/logic/game_engine.dart';
import 'package:mafia_game/logic/role_assigner.dart';
import 'package:mafia_game/models/role_model.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitialState()) {
    on<StartGameEvent>(_onStartGame);
    on<KillPlayerEvent>(_onKillPlayer);
    on<HealPlayerEvent>(_onHealPlayer);
    on<InvestigatePlayerEvent>(_onInvestigatePlayer);
    on<VotePlayerEvent>(_onVotePlayer);
    on<NextPhaseEvent>(_onNextPhase);
  }

  void _onStartGame(StartGameEvent event, Emitter<GameState> emit) {
    var roles = RoleAssigner.assignRolesToPlayers(event.playerNames);
    var engine = GameEngine(playerRoles: roles);

    Map<int, RoleModel> playerRoles = {};
    roles.forEach((id, role) {
      playerRoles[id] = RoleModel.fromRole(role);
    });

    emit(GameInProgressState(
      engine: engine,
      playerNames: event.playerNames,
      playerRoles: playerRoles,
    ));
  }

  void _onKillPlayer(KillPlayerEvent event, Emitter<GameState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;
      currentState.engine.killPlayer(event.playerId);
      _checkGameOver(emit, currentState);
    }
  }

  void _onHealPlayer(HealPlayerEvent event, Emitter<GameState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;
      currentState.engine.healPlayer(event.playerId);
      emit(currentState);
    }
  }

  void _onInvestigatePlayer(InvestigatePlayerEvent event, Emitter<GameState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;
      bool isMafia = currentState.engine.investigatePlayer(event.playerId);
      emit(GameInProgressState(
        engine: currentState.engine,
        playerNames: currentState.playerNames,
        playerRoles: currentState.playerRoles,
        investigationResult: isMafia ? '🔴 مافیاست!' : '🟢 شهروند است.',
      ));
    }
  }

  void _onVotePlayer(VotePlayerEvent event, Emitter<GameState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;
      currentState.engine.startVoting(event.votes);
      _checkGameOver(emit, currentState);
    }
  }

  void _onNextPhase(NextPhaseEvent event, Emitter<GameState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;
      currentState.engine.toggleDayNight();
      emit(GameInProgressState(
        engine: currentState.engine,
        playerNames: currentState.playerNames,
        playerRoles: currentState.playerRoles,
        investigationResult: null,
      ));
    }
  }

  void _checkGameOver(Emitter<GameState> emit, GameInProgressState state) {
    if (state.engine.isGameOver()) {
      emit(GameOverState(winner: state.engine.getWinner()));
    } else {
      emit(state);
    }
  }
}

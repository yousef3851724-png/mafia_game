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

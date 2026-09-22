import 'package:equatable/equatable.dart';
import 'game_phase.dart';
import 'game_role.dart';
import 'player.dart';

class GameSession extends Equatable {
  final String roomId;
  final List<Player> players;
  final PhaseState phaseState;
  final List<AssignedRole> assignedRoles;
  final int round;

  const GameSession({
    required this.roomId,
    this.players = const [],
    this.phaseState = const PhaseState(),
    this.assignedRoles = const [],
    this.round = 0,
  });

  GameSession copyWith({
    String? roomId,
    List<Player>? players,
    PhaseState? phaseState,
    List<AssignedRole>? assignedRoles,
    int? round,
  }) {
    return GameSession(
      roomId: roomId ?? this.roomId,
      players: players ?? this.players,
      phaseState: phaseState ?? this.phaseState,
      assignedRoles: assignedRoles ?? this.assignedRoles,
      round: round ?? this.round,
    );
  }

  @override
  List<Object?> get props => [roomId, players, phaseState, assignedRoles, round];
}

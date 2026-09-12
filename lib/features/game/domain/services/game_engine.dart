import '../entities/game_phase.dart';
import '../entities/game_role.dart';
import '../entities/game_session.dart';

class GameEngine {
  GameSession endGame(GameSession session) {
    return session.copyWith(
      phaseState: PhaseState(
        phase: GamePhase.ended,
        startedAt: DateTime.now(),
      ),
    );
  }

  GameRole? roleOf(GameSession session, String playerId) {
    for (final assignment in session.assignedRoles) {
      if (assignment.playerId == playerId) {
        return assignment.role;
      }
    }
    return null;
  }

  int countTeam(GameSession session, Team team) {
    return session.assignedRoles
        .where((assignment) => assignment.role.team == team)
        .length;
  }

  List<GameRole> _buildRolePool(int playerCount) {
    final mafiaCount = playerCount >= 7 ? 2 : 1;
    final roles = <GameRole>[...List.filled(mafiaCount, GameRole.mafia)];

    if (playerCount >= 5) {
      roles.add(GameRole.detective);
    }

    if (playerCount >= 6) {
      roles.add(GameRole.doctor);
    }

    while (roles.length < playerCount) {
      roles.add(GameRole.citizen);
    }

    return roles;
  }
}

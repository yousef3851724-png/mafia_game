import 'dart:math';

import '../entities/game_phase.dart';
import '../entities/game_role.dart';
import '../entities/game_session.dart';
import '../entities/player.dart';

class GameEngine {
  static const int minimumPlayers = 4;

  GameSession createSession(String roomId) {
    return GameSession(roomId: roomId);
  }

  GameSession addPlayer(GameSession session, Player player) {
    if (session.phaseState.phase != GamePhase.lobby) {
      throw StateError('امکان افزودن بازیکن پس از شروع بازی وجود ندارد.');
    }
    if (session.players.any((item) => item.id == player.id)) return session;

    final newPlayer = player.copyWith(
      isHost: session.players.isEmpty || player.isHost,
    );
    return session.copyWith(players: [...session.players, newPlayer]);
  }

  GameSession removePlayer(GameSession session, String playerId) {
    if (session.phaseState.phase != GamePhase.lobby) {
      throw StateError('امکان حذف بازیکن پس از شروع بازی وجود ندارد.');
    }

    final remaining = session.players.where((p) => p.id != playerId).toList();
    if (remaining.isNotEmpty && !remaining.any((p) => p.isHost)) {
      remaining[0] = remaining[0].copyWith(isHost: true);
    }
    return session.copyWith(players: remaining);
  }

  GameSession startGame(GameSession session) {
    if (session.phaseState.phase != GamePhase.lobby) {
      throw StateError('بازی قبلاً شروع شده است.');
    }
    if (session.players.length < minimumPlayers) {
      throw StateError('برای شروع بازی حداقل $minimumPlayers بازیکن لازم است.');
    }

    final roles = _buildRolePool(session.players.length)..shuffle(Random());
    final assignments = <AssignedRole>[];
    for (var i = 0; i < session.players.length; i++) {
      assignments.add(
        AssignedRole(playerId: session.players[i].id, role: roles[i]),
      );
    }

    return session.copyWith(
      assignedRoles: assignments,
      phaseState: PhaseState(
        phase: GamePhase.roleAssignment,
        startedAt: DateTime.now(),
      ),
      round: 1,
    );
  }

  GameSession advancePhase(GameSession session) {
    final current = session.phaseState.phase;
    if (current == GamePhase.ended) return session;

    final next = switch (current) {
      GamePhase.lobby => GamePhase.roleAssignment,
      GamePhase.roleAssignment => GamePhase.night,
      GamePhase.night => GamePhase.day,
      GamePhase.day => GamePhase.discussion,
      GamePhase.discussion => GamePhase.voting,
      GamePhase.voting => GamePhase.result,
      GamePhase.result => GamePhase.night,
      GamePhase.ended => GamePhase.ended,
    };

    return session.copyWith(
      phaseState: PhaseState(phase: next, startedAt: DateTime.now()),
      round: next == GamePhase.night && current == GamePhase.result
          ? session.round + 1
          : session.round,
    );
  }

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
      if (assignment.playerId == playerId) return assignment.role;
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

    if (playerCount >= 5) roles.add(GameRole.detective);
    if (playerCount >= 6) roles.add(GameRole.doctor);

    while (roles.length < playerCount) {
      roles.add(GameRole.citizen);
    }
    return roles;
  }
}

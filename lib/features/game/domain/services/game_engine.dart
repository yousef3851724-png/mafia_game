import 'dart:math';

import '../entities/game_phase.dart';
import '../entities/game_role.dart';
import '../entities/game_session.dart';
import '../entities/player.dart';

class GameEngine {
  final Random _random;

  GameEngine({Random? random}) : _random = random ?? Random();

  static const minimumPlayers = 4;

  GameSession createSession(String roomId) {
    final id = roomId.trim();
    if (id.isEmpty) {
      throw ArgumentError('Room ID cannot be empty.');
    }
    return GameSession(roomId: id);
  }

  GameSession addPlayer(GameSession session, Player player) {
    if (player.name.trim().isEmpty) {
      throw ArgumentError('Player name cannot be empty.');
    }
    if (session.players.any((item) => item.id == player.id)) {
      return session;
    }
    final isFirst = session.players.isEmpty;
    final normalized = player.copyWith(isHost: isFirst || player.isHost);
    return session.copyWith(players: [...session.players, normalized]);
  }

  GameSession removePlayer(GameSession session, String playerId) {
    final remaining = session.players.where((p) => p.id != playerId).toList();
    if (remaining.isNotEmpty && !remaining.any((p) => p.isHost)) {
      remaining[0] = remaining[0].copyWith(isHost: true);
    }
    return session.copyWith(players: remaining);
  }

  GameSession startGame(GameSession session) {
    if (session.players.length < minimumPlayers) {
      throw StateError('At least $minimumPlayers players are required.');
    }

    final roles = _buildRolePool(session.players.length);
    roles.shuffle(_random);

    final assignments = <AssignedRole>[];
    for (var i = 0; i < session.players.length; i++) {
      assignments.add(AssignedRole(
        playerId: session.players[i].id,
        role: roles[i],
      ));
    }

    return session.copyWith(
      assignedRoles: assignments,
      phaseState: PhaseState(
        phase: GamePhase.night,
        startedAt: DateTime.now(),
      ),
      round: 1,
    );
  }

  GameSession advancePhase(GameSession session) {
    final next = switch (session.phaseState.phase) {
      GamePhase.lobby => GamePhase.roleAssignment,
      GamePhase.roleAssignment => GamePhase.night,
      GamePhase.night => GamePhase.day,
      GamePhase.day => GamePhase.discussion,
      GamePhase.discussion => GamePhase.voting,
      GamePhase.voting => GamePhase.result,
      GamePhase.result => GamePhase.night,
      GamePhase.ended => GamePhase.ended,
    };

    final nextRound = next == GamePhase.night &&
            session.phaseState.phase == GamePhase.result
        ? session.round + 1
        : session.round;

    return session.copyWith(
      phaseState: session.phaseState.copyWith(
        phase: next,
        startedAt: DateTime.now(),
      ),
      round: nextRound,
    );
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

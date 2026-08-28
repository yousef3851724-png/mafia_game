import 'dart:math';

import '../entities/game_phase.dart';
import '../entities/game_role.dart';
import '../entities/game_session.dart';
import '../entities/player.dart';

/// Pure business engine for the Mafia game.
///
/// This class intentionally has no Flutter, Bloc, Firebase or Socket.io
/// dependency so it can be unit-tested independently.
class GameEngine {
  final Random _random;

  GameEngine({Random? random}) : _random = random ?? Random();

  static const int minimumPlayers = 4;

  GameSession createSession(String roomId) {
    final id = roomId.trim();
    if (id.isEmpty) {
      throw ArgumentError('Room ID cannot be empty.');
    }
    return GameSession(roomId: id);
  }

  GameSession addPlayer(GameSession session, Player player) {
    final name = player.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Player name cannot be empty.');
    }

    if (session.phaseState.phase != GamePhase.lobby) {
      throw StateError('Players can only join during the lobby.');
    }

    if (session.players.any((item) => item.id == player.id)) {
      return session;
    }

    final isFirst = session.players.isEmpty;
    final normalized = Player(
      id: player.id,
      name: name,
      isHost: isFirst || player.isHost,
      vote: null,
    );

    return session.copyWith(
      players: [...session.players, normalized],
    );
  }

  GameSession removePlayer(GameSession session, String playerId) {
    final remaining = session.players
        .where((player) => player.id != playerId)
        .toList(growable: true);

    if (remaining.length == session.players.length) {
      return session;
    }

    // If the host leaves, the first remaining player becomes host.
    if (remaining.isNotEmpty && !remaining.any((player) => player.isHost)) {
      final nextHost = remaining.first;
      remaining[0] = nextHost.copyWith(isHost: true);
    }

    return session.copyWith(players: remaining);
  }

  /// Assigns roles and moves the session to the role-assignment phase.
  ///
  /// The role assignment is deliberately a separate phase. Presentation
  /// decides how/when the private role card is shown to each player.
  GameSession startGame(GameSession session) {
    if (session.phaseState.phase != GamePhase.lobby) {
      throw StateError('Game can only start from the lobby.');
    }

    if (session.players.length < minimumPlayers) {
      throw StateError(
        'At least $minimumPlayers players are required to start the game.',
      );
    }

    final roles = _buildRolePool(session.players.length)..shuffle(_random);
    final assignments = <AssignedRole>[];

    for (var i = 0; i < session.players.length; i++) {
      assignments.add(
        AssignedRole(
          playerId: session.players[i].id,
          role: roles[i],
        ),
      );
    }

    return session.copyWith(
      assignedRoles: List.unmodifiable(assignments),
      phaseState: PhaseState(
        phase: GamePhase.roleAssignment,
        startedAt: DateTime.now(),
      ),
      round: 1,
    );
  }

  /// Advances the game through its normal lifecycle.
  GameSession advancePhase(GameSession session) {
    final current = session.phaseState.phase;

    if (current == GamePhase.ended) {
      return session;
    }

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

    final nextRound = current == GamePhase.result && next == GamePhase.night
        ? session.round + 1
        : session.round;

    return session.copyWith(
      phaseState: PhaseState(
        phase: next,
        startedAt: DateTime.now(),
        duration: _defaultDuration(next),
      ),
      round: nextRound,
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
      if (assignment.playerId == playerId) {
        return assignment.role;
      }
    }
    return null;
  }

  int countTeam(GameSession session, RoleTeam team) {
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

  Duration _defaultDuration(GamePhase phase) {
    switch (phase) {
      case GamePhase.lobby:
        return Duration.zero;
      case GamePhase.roleAssignment:
        return const Duration(seconds: 15);
      case GamePhase.night:
        return const Duration(seconds: 60);
      case GamePhase.day:
        return const Duration(seconds: 30);
      case GamePhase.discussion:
        return const Duration(minutes: 3);
      case GamePhase.voting:
        return const Duration(minutes: 1);
      case GamePhase.result:
        return const Duration(seconds: 10);
      case GamePhase.ended:
        return Duration.zero;
    }
  }
}

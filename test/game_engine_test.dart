import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mafia_game/core/models/app_models.dart';
import 'package:mafia_game/features/game/game_state.dart';
import 'package:mafia_game/features/game/player_avatar.dart';

void main() {
  test('game engine creates a valid lobby table with leader and Radical staff badges', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(gameControllerProvider.notifier);
    controller.start(playerCount: 8);
    final state = container.read(gameControllerProvider);

    expect(state.initialized, isTrue);
    expect(state.phase, GamePhase.night);
    expect(state.round, 1);
    expect(state.players, hasLength(8));
    expect(state.alivePlayers, hasLength(8));
    expect(state.players.where((p) => p.isLeader), hasLength(1));
    expect(state.players.where((p) => p.isStaff), hasLength(1));
    expect(state.user?.isLeader, isTrue);
    expect(state.availableAction, isA<NightAction>());
  });

  test('player badges survive immutable state updates', () {
    final player = GamePlayer(
      id: 'p1',
      name: 'بازیکن',
      role: 'شهروند',
      appRole: roleForName('شهروند'),
      seat: 1,
      isUser: true,
      alive: true,
      avatar: const PlayerAvatar(id: 'avatar_shadow', displayName: 'بازیکن', seed: 1),
      isLeader: true,
      isStaff: false,
    );

    final updated = player.copyWith(alive: false, votesReceived: 2);
    expect(updated.isLeader, isTrue);
    expect(updated.isStaff, isFalse);
    expect(updated.alive, isFalse);
    expect(updated.votesReceived, 2);
  });
}

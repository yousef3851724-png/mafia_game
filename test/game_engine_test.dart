import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mafia_radical/core/models/app_models.dart';
import 'package:mafia_radical/features/game/game_state.dart';
import 'package:mafia_radical/features/game/player_avatar.dart';

void main() {
  group('GameController', () {
    test('starts a valid table through the real provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(gameControllerProvider.notifier);
      controller.start(playerCount: 8);
      final state = container.read(gameControllerProvider);

      expect(state.initialized, isTrue);
      expect(state.phase, GamePhase.night);
      expect(state.round, 1);
      expect(state.secondsLeft, 20);
      expect(state.players, hasLength(8));
      expect(state.alivePlayers, hasLength(8));
      expect(state.user, isNotNull);
      expect(state.user!.isUser, isTrue);
      expect(state.players.where((player) => player.isLeader), hasLength(1));
      expect(state.players.where((player) => player.isStaff), hasLength(1));
      expect(state.availableAction, isA<NightAction>());
    });

    test('selectPlayer accepts only a living non-user player', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(gameControllerProvider.notifier);
      controller.start(playerCount: 6);
      final before = container.read(gameControllerProvider);
      final target = before.players.firstWhere((player) => !player.isUser);

      controller.selectPlayer(target.id);
      expect(container.read(gameControllerProvider).selectedPlayerId, target.id);

      controller.selectPlayer(before.user!.id);
      expect(container.read(gameControllerProvider).selectedPlayerId, target.id);
    });
  });

  test('GamePlayer preserves real avatar and lobby badges across copyWith', () {
    final player = GamePlayer(
      id: 'p1',
      name: 'بازیکن',
      role: 'شهروند',
      appRole: roleForName('شهروند'),
      seat: 1,
      isUser: true,
      alive: true,
      avatar: const PlayerAvatar(
        id: 'avatar_shadow',
        displayName: 'بازیکن',
        assetPath: null,
        imageUrl: null,
        female: false,
        seed: 1,
      ),
      isLeader: true,
      isStaff: false,
    );

    final updated = player.copyWith(alive: false, votesReceived: 2);

    expect(updated.isLeader, isTrue);
    expect(updated.isStaff, isFalse);
    expect(updated.alive, isFalse);
    expect(updated.votesReceived, 2);
    expect(updated.avatar.id, 'avatar_shadow');
    expect(updated.appRole.name, 'شهروند');
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mafia_radical/core/models/app_models.dart';
import 'package:mafia_radical/features/game/game_state.dart';
import 'package:mafia_radical/features/game/player_avatar.dart';
import 'package:mafia_radical/features/scenarios/scenario_game_screen.dart';

void main() {
  group('GameController', () {
    test('starts a valid table through the real provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(gameControllerProvider.notifier);
      controller.start(playerCount: 8, seed: 42);
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
      expect(state.players.map((player) => player.seat).toSet(), {1, 2, 3, 4, 5, 6, 7, 8});
    });

    test('selectPlayer accepts only a living non-user player', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(gameControllerProvider.notifier);
      controller.start(playerCount: 6, seed: 7);
      final before = container.read(gameControllerProvider);
      final target = before.players.firstWhere((player) => !player.isUser);

      controller.selectPlayer(target.id);
      expect(container.read(gameControllerProvider).selectedPlayerId, target.id);

      controller.selectPlayer(before.user!.id);
      expect(container.read(gameControllerProvider).selectedPlayerId, target.id);
    });

    test('different seeds change role-to-seat mapping and user seat', () {
      final firstContainer = ProviderContainer();
      final secondContainer = ProviderContainer();
      addTearDown(firstContainer.dispose);
      addTearDown(secondContainer.dispose);

      firstContainer.read(gameControllerProvider.notifier).start(playerCount: 20, seed: 101);
      secondContainer.read(gameControllerProvider.notifier).start(playerCount: 20, seed: 202);

      final first = firstContainer.read(gameControllerProvider);
      final second = secondContainer.read(gameControllerProvider);
      final firstMapping = first.players.map((p) => '${p.seat}:${p.role}').join('|');
      final secondMapping = second.players.map((p) => '${p.seat}:${p.role}').join('|');

      expect(firstMapping, isNot(secondMapping));
      expect(first.user!.seat, isNot(second.user!.seat));
      expect(first.players.map((p) => p.seat).toSet(), hasLength(20));
      expect(second.players.map((p) => p.seat).toSet(), hasLength(20));
    });

    test('100 seeded games distribute mafia uniformly across seats', () {
      const playerCount = 10;
      const simulations = 100;
      final mafiaBySeat = List<int>.filled(playerCount, 0);
      final userSeatCounts = List<int>.filled(playerCount, 0);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      for (var seed = 1; seed <= simulations; seed++) {
        controller.start(playerCount: playerCount, seed: seed);
        final state = container.read(gameControllerProvider);
        expect(state.players.where((p) => p.role == 'مافیا'), hasLength(3));

        for (final player in state.players) {
          if (player.role == 'مافیا') mafiaBySeat[player.seat - 1]++;
          if (player.isUser) userSeatCounts[player.seat - 1]++;
        }
      }

      // 300 mafia assignments over 10 seats should not collapse into a seat pattern.
      // The bounds are intentionally broad so this is a distribution sanity check,
      // not a requirement to manufacture an artificially anti-clustered table.
      expect(mafiaBySeat.reduce((a, b) => a + b), 300);
      expect(mafiaBySeat.every((count) => count >= 12 && count <= 48), isTrue,
          reason: 'Mafia assignments are unexpectedly concentrated by seat: $mafiaBySeat');
      expect(mafiaBySeat.reduce((a, b) => a > b ? a : b) - mafiaBySeat.reduce((a, b) => a < b ? a : b), lessThanOrEqualTo(24),
          reason: 'Mafia distribution varies too much by seat: $mafiaBySeat');

      expect(userSeatCounts.reduce((a, b) => a + b), simulations);
      expect(userSeatCounts.every((count) => count >= 2 && count <= 20), isTrue,
          reason: 'User seat is unexpectedly concentrated: $userSeatCounts');
    });

    test('role counts remain valid while roles are independent from seats', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(gameControllerProvider.notifier);

      controller.start(playerCount: 10, seed: 11);
      final first = container.read(gameControllerProvider);
      controller.start(playerCount: 10, seed: 12);
      final second = container.read(gameControllerProvider);

      for (final state in [first, second]) {
        expect(state.players.where((p) => p.role == 'مافیا'), hasLength(3));
        expect(state.players.where((p) => p.role == 'دکتر'), hasLength(1));
        expect(state.players.where((p) => p.role == 'کارآگاه'), hasLength(1));
        expect(state.players, hasLength(10));
      }
      expect(first.players.map((p) => p.role).join('|'), isNot(second.players.map((p) => p.role).join('|')));
    });
  });

  group('GameTableLayout', () {
    for (final count in [6, 10, 15, 20]) {
      test('keeps $count seats inside the canvas without overlap', () {
        final offsets = GameTableLayout.offsetsFor(count);
        expect(offsets, hasLength(count));
        expect(offsets.every(GameTableLayout.fitsCanvas), isTrue);

        for (var i = 0; i < offsets.length; i++) {
          for (var j = i + 1; j < offsets.length; j++) {
            final a = GameTableLayout.seatRect(offsets[i]);
            final b = GameTableLayout.seatRect(offsets[j]);
            expect(a.overlaps(b), isFalse, reason: 'seats $i and $j overlap for $count players');
          }
        }
      });
    }
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

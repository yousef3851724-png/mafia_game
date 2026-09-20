// lib/features/game/presentation/game_realtime_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/radical_theme.dart';
import '../domain/entities/game_phase.dart';
import '../domain/entities/game_role.dart';
import '../domain/game_realtime_state.dart';
import '../providers/game_realtime_provider.dart';

class GameRealtimeScreen extends ConsumerStatefulWidget {
  const GameRealtimeScreen({
    super.key,
    required this.roomId,
    required this.playerId,
    this.playerName = 'من',
  });

  final String roomId;
  final String playerId;
  final String playerName;

  @override
  ConsumerState<GameRealtimeScreen> createState() => _GameRealtimeScreenState();
}

class _GameRealtimeScreenState extends ConsumerState<GameRealtimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameRealtimeProvider.notifier).join(
            roomId: widget.roomId,
            playerId: widget.playerId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameRealtimeProvider);
    final controller = ref.read(gameRealtimeProvider.notifier);

    return Scaffold(
      backgroundColor: RadicalTheme.ink,
      appBar: AppBar(
        backgroundColor: RadicalTheme.panel,
        title: Text('${state.phase.title} — راند ${state.round}'),
        actions: [
          if (state.secondsLeft > 0)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: state.secondsLeft <= 5
                    ? Colors.red.withValues(alpha: 0.3)
                    : RadicalTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.secondsLeft <= 5
                      ? Colors.red
                      : RadicalTheme.gold,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer,
                      size: 14,
                      color: state.secondsLeft <= 5
                          ? Colors.red
                          : RadicalTheme.gold),
                  const SizedBox(width: 4),
                  Text(
                    '${state.secondsLeft}s',
                    style: TextStyle(
                      color: state.secondsLeft <= 5
                          ? Colors.red
                          : RadicalTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null) _errorBanner(state, controller),
          _phaseHeader(state),
          if (state.myRole != null) _myRoleCard(state),
          Expanded(child: _playersList(state)),
          _actionBar(state, controller),
        ],
      ),
    );
  }

  Widget _errorBanner(GameRealtimeState state, GameRealtimeController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.red.shade900,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(state.error!,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => c.clearError(),
          ),
        ],
      ),
    );
  }

  Widget _phaseHeader(GameRealtimeState state) {
    final icon = switch (state.phase) {
      GamePhase.night => Icons.nightlight_round,
      GamePhase.day => Icons.wb_sunny,
      GamePhase.discussion => Icons.chat_bubble_outline,
      GamePhase.voting => Icons.how_to_vote,
      GamePhase.ended => Icons.flag,
      GamePhase.result => Icons.emoji_events,
      _ => Icons.info_outline,
    };
    final color = switch (state.phase) {
      GamePhase.night => Colors.indigo,
      GamePhase.day => Colors.orange,
      GamePhase.voting => RadicalTheme.gold,
      _ => RadicalTheme.violetBright,
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            state.phase.title,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.lastEvent != null) ...[
            const SizedBox(height: 8),
            Text(
              state.lastEvent!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RadicalTheme.smoke, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _myRoleCard(GameRealtimeState state) {
    final role = state.myRole!;
    final team = role.team;
    final color = team == Team.mafia
        ? Colors.red
        : team == Team.citizens
            ? Colors.green
            : RadicalTheme.gold;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.badge, color: color, size: 24),
          const SizedBox(width: 12),
          Text('نقش شما: ',
              style: TextStyle(color: RadicalTheme.smoke, fontSize: 13)),
          Text(
            role.title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (!state.amAlive)
            const Chip(
              label: Text('مرده',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _playersList(GameRealtimeState state) {
    final controller = ref.read(gameRealtimeProvider.notifier);
    final targets = controller.getTargets();
    final targetIds = targets.map((p) => p.id).toSet();

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = state.players[i];
        final canTarget = targetIds.contains(p.id) && controller.canAct();
        final isMyTarget = state.myTarget == p.id;

        return _PlayerCard(
          player: p,
          canTarget: canTarget,
          isMyTarget: isMyTarget,
          phase: state.phase,
          onTap: canTarget
              ? () {
                  if (state.isVoting) {
                    controller.vote(p.id);
                  } else if (state.isNight) {
                    controller.nightAction(p.id);
                  }
                }
              : null,
        );
      },
    );
  }

  Widget _actionBar(GameRealtimeState state, GameRealtimeController c) {
    if (state.isEnded) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: RadicalTheme.panel,
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    c.leave();
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('بازگشت به خانه'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RadicalTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: RadicalTheme.panel,
        border: Border(top: BorderSide(color: RadicalTheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              '${state.aliveCount} زنده',
              style: const TextStyle(color: RadicalTheme.smoke),
            ),
            const Spacer(),
            if (state.myTarget != null)
              Text(
                'انتخاب: ${state.players.firstWhere((p) => p.id == state.myTarget).name}',
                style: const TextStyle(
                    color: RadicalTheme.gold, fontWeight: FontWeight.bold),
              )
            else if (c.canAct())
              const Text('یه بازیکن رو انتخاب کن',
                  style: TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
            const SizedBox(width: 12),
            if (c.canAct())
              TextButton(
                onPressed: () => c.skip(),
                child: const Text('رد کردن',
                    style: TextStyle(color: RadicalTheme.smoke)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.canTarget,
    required this.isMyTarget,
    required this.phase,
    this.onTap,
  });

  final GamePlayerRT player;
  final bool canTarget;
  final bool isMyTarget;
  final GamePhase phase;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dead = !player.alive;
    final borderColor = isMyTarget
        ? RadicalTheme.gold
        : player.isMe
            ? RadicalTheme.violetBright
            : dead
                ? Colors.grey.shade800
                : RadicalTheme.line;

    return Opacity(
      opacity: dead ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: player.isMe ? RadicalTheme.panel3 : RadicalTheme.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isMyTarget ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        dead ? Colors.grey.shade700 : RadicalTheme.violet,
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name.characters.first
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (dead)
                    const Positioned.fill(
                      child: Icon(Icons.close,
                          color: Colors.white, size: 28),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (player.isHost) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.star,
                              color: RadicalTheme.gold, size: 14),
                        ],
                        if (player.isMe) ...[
                          const SizedBox(width: 6),
                          const Text('(من)',
                              style: TextStyle(
                                  color: RadicalTheme.smoke, fontSize: 11)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'صندلی ${player.seat + 1}',
                      style: const TextStyle(
                          color: RadicalTheme.smoke, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (canTarget && !isMyTarget)
                const Icon(Icons.touch_app,
                    color: RadicalTheme.gold, size: 20),
              if (isMyTarget)
                const Icon(Icons.check_circle,
                    color: RadicalTheme.gold, size: 22),
              if (dead)
                const Icon(Icons.dangerous,
                    color: Colors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

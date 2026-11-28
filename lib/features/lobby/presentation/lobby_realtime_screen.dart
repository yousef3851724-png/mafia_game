import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/radical_theme.dart';
import '../domain/lobby_realtime_state.dart';
import '../providers/lobby_realtime_provider.dart';

class LobbyRealtimeScreen extends ConsumerStatefulWidget {
  const LobbyRealtimeScreen({
    super.key,
    required this.roomId,
    required this.playerId,
    this.playerName = 'من',
  });

  final String roomId;
  final String playerId;
  final String playerName;

  @override
  ConsumerState<LobbyRealtimeScreen> createState() => _LobbyRealtimeScreenState();
}

class _LobbyRealtimeScreenState extends ConsumerState<LobbyRealtimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lobbyRealtimeProvider.notifier).join(
            roomId: widget.roomId,
            playerId: widget.playerId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lobbyRealtimeProvider);
    final controller = ref.read(lobbyRealtimeProvider.notifier);

    return Scaffold(
      backgroundColor: RadicalTheme.ink,
      appBar: AppBar(
        backgroundColor: RadicalTheme.panel,
        title: Text('لابی — ${widget.roomId}'),
        actions: [
          _StatusBadge(status: state.status),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.red.shade900,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => controller.clearError(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.players.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: RadicalTheme.gold),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.players.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _PlayerTile(
                      player: state.players[i],
                      isMe: state.players[i].id == state.myId,
                      canKick: state.isHost && state.players[i].id != state.myId,
                      onKick: () => controller.kick(state.players[i].id),
                    ),
                  ),
          ),
          _BottomBar(
            state: state,
            onReady: () => controller.toggleReady(),
            onStart: () {
              controller.startGame();
              context.go("/game/${widget.roomId}");
            },
            onLeave: () {
              controller.leave();
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final LobbyConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      LobbyConnectionStatus.connected => Colors.green,
      LobbyConnectionStatus.connecting => Colors.orange,
      LobbyConnectionStatus.reconnecting => Colors.orange,
      LobbyConnectionStatus.error => Colors.red,
      LobbyConnectionStatus.disconnected => Colors.grey,
    };
    final String label = switch (status) {
      LobbyConnectionStatus.connected => 'متصل',
      LobbyConnectionStatus.connecting => 'اتصال...',
      LobbyConnectionStatus.reconnecting => 'اتصال مجدد...',
      LobbyConnectionStatus.error => 'خطا',
      LobbyConnectionStatus.disconnected => 'قطع',
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.isMe,
    required this.canKick,
    required this.onKick,
  });

  final LobbyPlayerRT player;
  final bool isMe;
  final bool canKick;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? RadicalTheme.panel3 : RadicalTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.ready ? Colors.green : RadicalTheme.line,
          width: player.ready ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: RadicalTheme.violet,
            child: Text(
              player.name.isNotEmpty ? player.name.characters.first : '?',
              style: const TextStyle(color: Colors.white),
            ),
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
                      const Icon(Icons.star, color: RadicalTheme.gold, size: 16),
                    ],
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      const Text('(من)',
                          style: TextStyle(
                              color: RadicalTheme.smoke, fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'صندلی ${player.seat + 1}',
                  style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12),
                ),
              ],
            ),
          ),
          if (player.ready)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const Icon(Icons.hourglass_empty, color: RadicalTheme.smoke),
          if (canKick) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onKick,
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.state,
    required this.onReady,
    required this.onStart,
    required this.onLeave,
  });

  final LobbyRealtimeState state;
  final VoidCallback onReady;
  final VoidCallback onStart;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final canStart = state.isHost && state.allReady;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.red,
        border: Border(top: BorderSide(color: Colors.yellow, width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            TextButton.icon(
              onPressed: onLeave,
              icon: const Icon(Icons.exit_to_app, color: RadicalTheme.smoke),
              label: const Text('خروج',
                  style: TextStyle(color: RadicalTheme.smoke)),
            ),
            const Spacer(),
            Text(
              '${state.readyCount}/${state.players.length}',
              style: const TextStyle(color: RadicalTheme.smoke),
            ),
            const SizedBox(width: 12),
            if (state.isHost)
              ElevatedButton.icon(
                onPressed: canStart ? onStart : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('شروع بازی'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RadicalTheme.gold,
                  foregroundColor: Colors.black,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onReady,
                icon: Icon(state.amReady ? Icons.cancel : Icons.check),
                label: Text(state.amReady ? 'لغو آماده' : 'آماده'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.amReady
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/radical_theme.dart';
import '../providers/lobby_realtime_provider.dart';

class LobbyRealtimeScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String playerId;

  const LobbyRealtimeScreen({
    super.key,
    required this.roomId,
    required this.playerId,
  });

  @override
  ConsumerState<LobbyRealtimeScreen> createState() => _LobbyRealtimeScreenState();
}

class _LobbyRealtimeScreenState extends ConsumerState<LobbyRealtimeScreen> {
  final _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(lobbyRealtimeProvider.notifier).join(
          roomId: widget.roomId,
          playerId: widget.playerId,
        ));
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lobbyRealtimeProvider);
    final controller = ref.read(lobbyRealtimeProvider.notifier);

    return Scaffold(
      backgroundColor: RadicalTheme.ink,
      appBar: AppBar(
        title: Text('لابی ' + widget.roomId),
        actions: [
          IconButton(
            tooltip: 'خروج',
            onPressed: controller.leave,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              actions: [
                TextButton(
                  onPressed: controller.clearError,
                  child: const Text('بستن'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Icon(
                  state.status == LobbyConnectionStatus.connected
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  color: state.status == LobbyConnectionStatus.connected
                      ? Colors.greenAccent
                      : RadicalTheme.smoke,
                ),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(state.status),
                  style: const TextStyle(color: RadicalTheme.smoke),
                ),
                const Spacer(),
                Text(
                  state.players.length.toString() + ' بازیکن',
                  style: const TextStyle(
                    color: RadicalTheme.goldBright,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.players.isEmpty
                ? const Center(
                    child: Text(
                      'در انتظار بازیکنان...',
                      style: TextStyle(color: RadicalTheme.smoke),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.players.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final player = state.players[index];
                      final canKick = state.isHost && player.id != widget.playerId;
                      return _PlayerTile(
                        player: player,
                        isMe: player.id == widget.playerId,
                        canKick: canKick,
                        onKick: () => controller.kick(player.id),
                      );
                    },
                  ),
          ),
          if (state.isHost)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: state.allReady ? controller.startGame : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('شروع بازی'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      controller.sendChat(value);
                      _chatController.clear();
                    },
                    decoration: const InputDecoration(hintText: 'پیام در لابی...'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    controller.sendChat(_chatController.text);
                    _chatController.clear();
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: state.amReady ? 'لغو آمادگی' : 'آماده‌ام',
                  onPressed: controller.toggleReady,
                  icon: Icon(
                    state.amReady
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(LobbyConnectionStatus status) {
    switch (status) {
      case LobbyConnectionStatus.connected:
        return 'متصل';
      case LobbyConnectionStatus.connecting:
        return 'در حال اتصال';
      case LobbyConnectionStatus.reconnecting:
        return 'در حال اتصال مجدد';
      case LobbyConnectionStatus.error:
        return 'خطا در اتصال';
      case LobbyConnectionStatus.disconnected:
        return 'قطع شده';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/game_bloc.dart';
import '../state/game_state.dart';
import '../widgets/player_avatar_card.dart';

class GameRoomScreen extends StatefulWidget {
  final String roomId;
  final String playerName;
  final GameBloc bloc;

  const GameRoomScreen({
    super.key,
    required this.roomId,
    required this.playerName,
    required this.bloc,
  });

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  String? selectedOption;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _joined) return;
      _joined = true;
      context.read<GameBloc>().add(
            JoinRoomRequested(
              roomId: widget.roomId,
              playerName: widget.playerName,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state.status == GameStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('اتاق ${widget.roomId}'),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'خروج',
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    context.read<GameBloc>().add(const LeaveRoomRequested());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GameState state) {
    if (state.status == GameStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == GameStatus.error && state.players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(state.errorMessage ?? 'خطای ناشناخته'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<GameBloc>().add(
                      JoinRoomRequested(
                        roomId: widget.roomId,
                        playerName: widget.playerName,
                      ),
                    ),
                child: const Text('تلاش دوباره'),
              ),
            ],
          ),
        ),
      );
    }

    final players = state.players;
    final hasVoted = players
        .where((player) => player.id == state.currentPlayerId)
        .any((player) => player.vote != null);

    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.amber),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'فاز روز: گفت‌وگو و رأی‌گیری',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('${players.length} بازیکن'),
              ],
            ),
          ),
          Expanded(
            child: players.isEmpty
                ? const Center(child: Text('هنوز بازیکنی وارد اتاق نشده است.'))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return PlayerAvatarCard(
                        player: player,
                        isSelected: selectedOption == player.id,
                        onTap: () {
                          if (hasVoted || player.id == state.currentPlayerId) return;
                          setState(() => selectedOption = player.id);
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: selectedOption == null || hasVoted
                    ? null
                    : () {
                        final option = selectedOption!;
                        context.read<GameBloc>().add(VoteRequested(option));
                        setState(() => selectedOption = null);
                      },
                icon: const Icon(Icons.how_to_vote),
                label: Text(hasVoted ? 'رأی ثبت شده است' : 'ثبت رأی'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

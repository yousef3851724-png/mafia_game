import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_game/bloc/game_bloc.dart';
import 'package:mafia_game/bloc/game_event.dart';
import 'package:mafia_game/bloc/game_state.dart';
import 'package:mafia_game/models/role_model.dart';
import 'package:mafia_game/database/app_database.dart';

class GameScreen extends StatefulWidget {
  final List<String> playerNames;
  const GameScreen({super.key, required this.playerNames});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(StartGameEvent(playerNames: widget.playerNames));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎭 بازی مافیا'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              if (state is GameInProgressState) {
                return TextButton(
                  onPressed: () {
                    context.read<GameBloc>().add(NextPhaseEvent());
                  },
                  child: Text(
                    state.engine.isNight ? '☀️ روز' : '🌙 شب',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameOverState) {
            _showGameOverDialog(context, state.winner);
          }
        },
        builder: (context, state) {
          if (state is GameInProgressState) {
            return Column(
              children: [
                _buildStatusBar(state),
                if (state.investigationResult != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.amber.shade100,
                    child: Text(
                      state.investigationResult!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.playerNames.length,
                    itemBuilder: (context, index) {
                      int playerId = index;
                      bool isAlive = state.engine.alivePlayers.contains(playerId);
                      RoleModel? role = state.playerRoles[playerId];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: isAlive ? Colors.transparent : Colors.grey.shade300,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isAlive ? Colors.deepPurple : Colors.grey,
                            child: Text(
                              isAlive ? '${index + 1}' : '💀',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            widget.playerNames[index],
                            style: TextStyle(
                              decoration: isAlive ? null : TextDecoration.lineThrough,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: isAlive ? Text(role?.name ?? '') : null,
                          trailing: isAlive
                              ? _buildActionButtons(state, playerId)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                if (!state.engine.isNight)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<GameBloc>().add(NextPhaseEvent());
                      },
                      icon: const Icon(Icons.nightlight_round),
                      label: const Text('شروع شب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatusBar(GameInProgressState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.deepPurple.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('👥 ${state.engine.alivePlayers.length} زنده'),
              Text('🌙 شب ${state.engine.nightCounter}'),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: state.engine.isNight ? Colors.indigo.shade900 : Colors.orange.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              state.engine.isNight ? '🌃 شب' : '☀️ روز',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GameInProgressState state, int playerId) {
    bool isNight = state.engine.isNight;
    Role? role = state.engine.getPlayerRole(playerId);

    List<Widget> buttons = [];

    if (isNight) {
      if (role == Role.mafia) {
        buttons.add(
          IconButton(
            icon: const Icon(Icons.kill, color: Colors.red),
            onPressed: () {
              _showPlayerSelectionDialog(
                context,
                state,
                'انتخاب قربانی',
                (id) {
                  context.read<GameBloc>().add(KillPlayerEvent(playerId: id));
                },
              );
            },
          ),
        );
      }
      if (role == Role.doctor) {
        buttons.add(
          IconButton(
            icon: const Icon(Icons.healing, color: Colors.green),
            onPressed: () {
              _showPlayerSelectionDialog(
                context,
                state,
                'انتخاب فرد برای نجات',
                (id) {
                  context.read<GameBloc>().add(HealPlayerEvent(playerId: id));
                },
              );
            },
          ),
        );
      }
      if (role == Role.detective) {
        buttons.add(
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              _showPlayerSelectionDialog(
                context,
                state,
                'انتخاب فرد برای بررسی',
                (id) {
                  context.read<GameBloc>().add(InvestigatePlayerEvent(playerId: id));
                },
              );
            },
          ),
        );
      }
    } else {
      buttons.add(
        IconButton(
          icon: const Icon(Icons.how_to_vote, color: Colors.orange),
          onPressed: () {
            _showVoteDialog(context, state, playerId);
          },
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }

  void _showPlayerSelectionDialog(
    BuildContext context,
    GameInProgressState state,
    String title,
    Function(int) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.engine.alivePlayers.length,
            itemBuilder: (context, index) {
              int id = state.engine.alivePlayers[index];
              return ListTile(
                title: Text(widget.playerNames[id]),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(id);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showVoteDialog(
    BuildContext context,
    GameInProgressState state,
    int voterId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🗳️ رأی‌گیری'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.engine.alivePlayers.length,
            itemBuilder: (context, index) {
              int id = state.engine.alivePlayers[index];
              if (id == voterId) return const SizedBox.shrink();
              return ListTile(
                title: Text(widget.playerNames[id]),
                onTap: () {
                  Navigator.pop(context);
                  context.read<GameBloc>().add(
                    VotePlayerEvent(votes: {voterId: 1}),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, String winner) {
    // ذخیره در دیتابیس
    final db = AppDatabase();
    final state = context.read<GameBloc>().state;
    if (state is GameInProgressState) {
      db.saveGameHistory(
        players: widget.playerNames,
        winner: winner,
        nights: state.engine.nightCounter,
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🏁 بازی تمام شد!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'برنده: $winner',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('بازگشت به خانه'),
          ),
        ],
      ),
    );
  }
}

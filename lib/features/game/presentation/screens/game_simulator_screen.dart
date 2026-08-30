import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/game_bloc.dart';
import '../../data/repositories/game_repository_mock.dart';
import '../state/game_state.dart';

/// Simulator screen that interacts directly with GameRepositoryMock for quick manual testing.
class GameSimulatorScreen extends StatefulWidget {
  const GameSimulatorScreen({super.key});

  @override
  State<GameSimulatorScreen> createState() => _GameSimulatorScreenState();
}

class _GameSimulatorScreenState extends State<GameSimulatorScreen> {
  late final GameRepositoryMock _mock;
  late final GameBloc _bloc;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mock = GameRepositoryMock(latencyMs: 100);
    _bloc = GameBloc(
      repository: _mock,
      joinRoomUseCase: JoinRoomUseCase(_mock as dynamic),
      submitVoteUseCase: SubmitVoteUseCase(_mock as dynamic),
      leaveRoomUseCase: LeaveRoomUseCase(_mock as dynamic),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _mock.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await _mock.joinRoom('sim', name);
    _nameController.clear();
    setState(() {});
  }

  void _addBot() {
    _mock.addBotPlayer(name: 'Bot-${DateTime.now().millisecondsSinceEpoch % 1000}');
    setState(() {});
  }

  void _togglePhase() {
    _mock.simulatePhaseChange();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Game Simulator')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Player name')),
                  ),
                  ElevatedButton(onPressed: _addPlayer, child: const Text('Add')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addBot, child: const Text('Add Bot')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(onPressed: _togglePhase, child: const Text('Toggle Phase')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => _mock.reset(), child: const Text('Reset')),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List>(
                  stream: _mock.watchPlayers(),
                  builder: (context, snapshot) {
                    final players = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final p = players[index];
                        return ListTile(
                          title: Text('${p.name} (${p.id})'),
                          subtitle: Text('vote: ${p.vote ?? '-'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.how_to_vote),
                                onPressed: () async {
                                  // vote for first non-self player (simple demo)
                                  final target = players.firstWhere((x) => x.id != p.id, orElse: () => null);
                                  if (target == null) return;
                                  await _mock.submitVote('sim', p.id as String, target.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _mock.removePlayer(p.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              StreamBuilder<Map<String, int>>(
                stream: _mock.watchVotes(),
                builder: (context, snap) {
                  final votes = snap.data ?? {};
                  return Text('Votes: ${votes.entries.map((e) => '${e.key}:${e.value}').join(', ')}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

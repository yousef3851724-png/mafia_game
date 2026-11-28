import 'package:flutter/material.dart';

import '../../core/models/scenario_catalog.dart';
import 'game_logic.dart';

class PassAndPlayGameScreen extends StatefulWidget {
  final String scenarioId;
  final int playerCount;

  const PassAndPlayGameScreen({
    super.key,
    required this.scenarioId,
    required this.playerCount,
  });

  @override
  State<PassAndPlayGameScreen> createState() => _PassAndPlayGameScreenState();
}

class _PassAndPlayGameScreenState extends State<PassAndPlayGameScreen> {
  late GameState _state;

  @override
  void initState() {
    super.initState();
    final scenario = ScenarioCatalog.byId(widget.scenarioId);
    final players = GameLogic.buildPlayers(
      scenario: scenario,
      playerCount: widget.playerCount,
      names: const [],
    );
    _state = GameState(scenario: scenario, players: players);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('بازی - ${_state.scenario.displayNameFa}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('فاز: ${_state.phase.name}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('بازیکن‌های زنده: ${_state.alivePlayers.length}'),
            Text('مافیاهای زنده: ${_state.aliveMafia.length}'),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _state.players.length,
                itemBuilder: (context, i) {
                  final p = _state.players[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('نقش: ${p.role.name}'),
                    trailing: Icon(
                      p.isAlive ? Icons.favorite : Icons.close,
                      color: p.isAlive ? Colors.red : Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

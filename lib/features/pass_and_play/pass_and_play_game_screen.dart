import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/models/scenario_catalog.dart';
import 'game_logic.dart';

class PassAndPlayGameScreen extends ConsumerStatefulWidget {
  final String scenarioId;
  final int playerCount;
  const PassAndPlayGameScreen({required this.scenarioId, required this.playerCount, super.key});
  @override
  ConsumerState<PassAndPlayGameScreen> createState() => _PassAndPlayGameScreenState();
}

class _PassAndPlayGameScreenState extends ConsumerState<PassAndPlayGameScreen> {
  late GameState gameState;
  late GameLogic gameLogic;

  @override
  void initState() {
    super.initState();
    final scenario = ScenarioCatalog.byId(widget.scenarioId);
    gameLogic = GameLogic(scenario: scenario!, playerCount: widget.playerCount);
    gameState = gameLogic.initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('روز ${gameState.dayNumber}'), backgroundColor: RadicalTheme.panel),
      body: Container(
        decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
        child: gameState.isGameOver ? _buildGameOver() : gameState.isNight ? _buildNightPhase() : _buildDayPhase(),
      ),
    );
  }

  Widget _buildDayPhase() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('☀️ روز ${gameState.dayNumber}', style: RadicalTheme.textTheme.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text('رای‌گیری: کی رو حذف کنیم؟', style: RadicalTheme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ..._buildPlayerVoteButtons(),
      ],
    );
  }

  List<Widget> _buildPlayerVoteButtons() {
    return gameState.alivePlayers.map((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton(
          onPressed: () => _castVote(p.id),
          style: ElevatedButton.styleFrom(backgroundColor: RadicalTheme.panel, padding: const EdgeInsets.all(12)),
          child: Text('${p.name} (${p.role})', style: const TextStyle(color: Colors.white)),
        ),
      );
    }).toList();
  }

  Widget _buildNightPhase() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌙 شب ${gameState.dayNumber}', style: RadicalTheme.textTheme.displaySmall),
          const SizedBox(height: 32),
          const Text('مافیا درحال تصمیم گیری است...', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => _nextPhase(), child: const Text('ادامه')),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(gameState.winner == 'mafia' ? '🏴 مافیا برد!' : '👮 شهروند برد!', style: RadicalTheme.textTheme.displayLarge),
          const SizedBox(height: 32),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home), label: const Text('خانه')),
        ],
      ),
    );
  }

  void _castVote(String playerId) => setState(() => gameState = gameLogic.castVote(gameState, playerId));
  void _nextPhase() => setState(() => gameState = gameLogic.nextPhase(gameState));
}

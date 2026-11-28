import 'package:flutter/material.dart';

import '../scenarios/custom_scenario_system.dart';
import '../scenarios/radical_game_screen.dart';
import '../scenarios/scenario_catalog.dart';

/// Public game-table route. The existing engine-backed game view is kept behind this boundary.
class GameTableScreen extends StatelessWidget {
  final ScenarioDefinition? scenario;
  final CustomScenario? customScenario;
  final ScenarioMode mode;
  final int playerCount;

  const GameTableScreen({super.key, this.scenario, this.customScenario, required this.mode, required this.playerCount});

  @override
  Widget build(BuildContext context) => RadicalGameScreen(
    scenario: scenario,
    customScenario: customScenario,
    mode: mode,
    playerCount: playerCount,
  );
}

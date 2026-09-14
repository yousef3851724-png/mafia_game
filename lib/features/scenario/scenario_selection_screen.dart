import 'package:flutter/material.dart';

import '../scenarios/scenario_lobby_screen.dart';

/// Public route for scenario selection. The legacy implementation remains isolated behind this feature boundary.
class ScenarioSelectionScreen extends StatelessWidget {
  final String ownerId;
  const ScenarioSelectionScreen({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) => ScenarioLobbyScreen(ownerId: ownerId);
}

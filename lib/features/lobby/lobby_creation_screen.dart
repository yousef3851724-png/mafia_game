import 'package:flutter/material.dart';

import '../scenarios/scenario_lobby_screen.dart';

class LobbyCreationScreen extends StatelessWidget {
  final String ownerId;
  const LobbyCreationScreen({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) => CustomScenarioBuilderScreen(ownerId: ownerId);
}

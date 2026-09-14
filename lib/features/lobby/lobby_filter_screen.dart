import 'package:flutter/material.dart';

import '../lobbies/lobby_hub_screen.dart';

/// Lobby discovery route. Filtering/selection remains owned by the lobby feature.
class LobbyFilterScreen extends StatelessWidget {
  final String ownerId;
  const LobbyFilterScreen({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) => LobbyHubScreen(ownerId: ownerId);
}

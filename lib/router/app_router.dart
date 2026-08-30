// Router helper that registers the GameSimulatorScreen route.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/game/presentation/screens/game_simulator_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))),
      ),
      GoRoute(
        path: '/simulator',
        builder: (context, state) => const GameSimulatorScreen(),
      ),
    ],
  );
}

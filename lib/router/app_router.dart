import 'package:go_router/go_router.dart';
import 'package:mafia_game/screens/home_screen.dart';
import 'package:mafia_game/screens/game_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) {
        final playerNames = state.extra as List<String>? ?? [];
        return GameScreen(playerNames: playerNames);
      },
    ),
  ],
);

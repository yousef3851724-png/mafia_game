import 'package:go_router/go_router.dart';
import 'package:mafia_game/screens/home_screen.dart';
import 'package:mafia_game/screens/game_screen.dart';
import 'package:mafia_game/screens/splash_screen.dart';
import 'package:mafia_game/screens/settings_screen.dart';
import 'package:mafia_game/screens/history_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
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
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);

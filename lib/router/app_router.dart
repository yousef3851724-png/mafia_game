import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../features/lobby/presentation/lobby_realtime_screen.dart';
import '../features/game/presentation/game_realtime_screen.dart';

class RadicalRoutes {
  RadicalRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const lobby = '/lobby/:roomId';
  static const game = '/game/:roomId';
}

final GoRouter radicalRouter = GoRouter(
  initialLocation: RadicalRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RadicalRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.lobby,
      name: 'lobby',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId'] ?? 'demo';
        return LobbyRealtimeScreen(
          roomId: roomId,
          playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
        );
      },
    ),
    GoRoute(
      path: RadicalRoutes.game,
      name: 'game',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId'] ?? 'demo';
        return GameRealtimeScreen(
          roomId: roomId,
          playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
        );
      },
    ),
  ],
);

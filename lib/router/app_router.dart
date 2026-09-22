import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../features/profile/avatar_selection_screen.dart';
import '../features/cosmetics/presentation/screens/frame_showcase_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../features/lobby/presentation/lobby_realtime_screen.dart';
import '../features/game/presentation/game_realtime_screen.dart';
import '../features/pass_and_play/pass_and_play_screen.dart';
import '../features/pass_and_play/pass_and_play_game_screen.dart';

class RadicalRoutes {
  RadicalRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const avatarSelection = '/avatar-selection';
  static const frameShop = '/frame-shop';
  static const passAndPlay = '/pass-and-play';
  static const passAndPlayGame = '/pass-and-play/game/:scenarioId/:playerCount';
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
      path: RadicalRoutes.avatarSelection,
      name: 'avatar-selection',
      builder: (context, state) => const AvatarSelectionScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.frameShop,
      name: 'frame-shop',
      builder: (context, state) => const FrameShowcaseScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.passAndPlay,
      name: 'pass-and-play',
      builder: (context, state) => const PassAndPlayScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.passAndPlayGame,
      name: 'pass-and-play-game',
      builder: (context, state) {
        final scenarioId = state.pathParameters['scenarioId'] ?? 'classic';
        final playerCount =
            int.parse(state.pathParameters['playerCount'] ?? '6');
        return PassAndPlayGameScreen(
          scenarioId: scenarioId,
          playerCount: playerCount,
        );
      },
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

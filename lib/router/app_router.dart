mkdir -p lib/router

import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';

class RadicalRoutes {
  RadicalRoutes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
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
  ],
);


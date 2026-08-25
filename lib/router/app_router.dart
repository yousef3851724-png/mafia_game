import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/setup/setup_screen.dart';
import '../features/role_reveal/role_reveal_screen.dart';
import '../features/night/night_phase_screen.dart';
import '../features/day/day_phase_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
    GoRoute(path: '/role-reveal', builder: (context, state) => const RoleRevealScreen()),
    GoRoute(path: '/night', builder: (context, state) => const NightPhaseScreen()),
    GoRoute(path: '/day', builder: (context, state) => const DayPhaseScreen()),
  ],
);

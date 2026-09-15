import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../features/home/cinematic_home_screen.dart';

/// نام‌های مسیر به‌صورت متمرکز.
class RadicalRoutes {
  RadicalRoutes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
}

/// Router مرکزی Radical.
/// مقصد onboarding فعلاً یک صفحه‌ی داخلی ساده است تا مسیر قابل اجرا باشد؛
/// در مرحله‌ی onboarding کامل با صفحه‌ی واقعی جایگزین می‌شود.
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
      builder: (context, state) => const _OnboardingRouteScreen(),
    ),
    GoRoute(
      path: RadicalRoutes.home,
      name: 'home',
      builder: (context, state) => const CinematicHomeScreen(),
    ),
  ],
);

class _OnboardingRouteScreen extends StatelessWidget {
  const _OnboardingRouteScreen();

  @override
  Widget build(context) => const Scaffold(
        body: Center(child: Text('آنبوردینگ')),
      );
}

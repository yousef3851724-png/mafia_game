import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../features/home/cinematic_home_screen.dart';
import '../core/theme/radical_theme.dart';

/// نام‌های مسیر به‌صورت متمرکز.
class RadicalRoutes {
  RadicalRoutes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
}

/// Router مرکزی Radical.
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

/// آداپتور موقتِ قابل‌اجرا برای مسیر onboarding.
/// این صفحه عمداً جریان فعلی بازی را دستکاری نمی‌کند و در مرحله‌ی onboarding
/// کامل با صفحه‌ی نهایی جایگزین می‌شود.
class _OnboardingRouteScreen extends StatelessWidget {
  const _OnboardingRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadicalTheme.ink,
      body: Center(
        child: FilledButton(
          onPressed: () => context.go(RadicalRoutes.home),
          child: const Text('ورود به مافیا رادیکال'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/radical_theme.dart';
import '../../router/app_router.dart';

/// صفحه‌ی شروع اپ: لوگوی انیمیشنی + تشخیص خودکار مقصد بعدی.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = Tween<double>(begin: .7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, .6)),
    );
    _controller.forward();
    _resolveNextRoute();
  }

  Future<void> _resolveNextRoute() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 1800));
    final hasSeenOnboarding = await ref.read(hasSeenOnboardingProvider.future);
    await minDelay;
    if (!mounted) return;
    context.go(hasSeenOnboarding ? RadicalRoutes.home : RadicalRoutes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _fade.value,
              child: Transform.scale(scale: _scale.value, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadicalTheme.goldButtonGradient,
                    boxShadow: RadicalTheme.goldGlow(blur: 30, opacity: .45),
                  ),
                  child: const Icon(Icons.theater_comedy, size: 58, color: RadicalTheme.gold),
                ),
                const SizedBox(height: 24),
                const Text('مافیا رادیکال', style: TextStyle(color: RadicalTheme.goldBright, fontSize: 34, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('بازی نقش، فریب و اتحاد', style: TextStyle(color: RadicalTheme.smoke, fontSize: 13)),
                const SizedBox(height: 40),
                SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: RadicalTheme.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(RadicalTheme.gold),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

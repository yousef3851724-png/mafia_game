import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/theme/radical_theme.dart';
import '../../router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  final _service = OnboardingService();
  int _index = 0;

  static const _slides = [
    (Icons.auto_awesome, 'افسانه وارد شهر شد', 'در مافیا رادیکال، هر بازیکن یک هویت، یک راز و یک تصمیم سرنوشت‌ساز دارد.'),
    (Icons.groups_rounded, 'اتحاد بساز', 'بازیکنان را بشناس، نشانه‌ها را کنار هم بگذار و در گفت‌وگوها حقیقت را پیدا کن.'),
    (Icons.visibility_off_rounded, 'نقشت را پنهان کن', 'مافیا، شهروند، کارآگاه و نقش‌های ویژه؛ هیچ‌کس آن چیزی نیست که در نگاه اول به نظر می‌رسد.'),
    (Icons.local_fire_department_rounded, 'وقت بازی است', 'آواتار، فریم و هویت خودت را انتخاب کن و وارد یک میز واقعی رادیکال شو.'),
  ];

  Future<void> _finish() async {
    await _service.setOnboardingSeen();
    if (!mounted) return;
    context.go(RadicalRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: _finish, child: const Text('رد کردن')),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final item = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(colors: [Color(0xFF33263D), Color(0xFF0B0C11)]),
                                border: Border.all(color: RadicalTheme.gold.withValues(alpha: .55), width: 1.5),
                                boxShadow: RadicalTheme.goldGlow(blur: 36, opacity: .22),
                              ),
                              child: Icon(item.$1, size: 76, color: RadicalTheme.goldBright),
                            ),
                            const SizedBox(height: 44),
                            Text(item.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 16),
                            Text(item.$3, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RadicalTheme.smoke)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index ? RadicalTheme.gold : RadicalTheme.smoke.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _index == _slides.length - 1
                          ? _finish
                          : () => _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic),
                      child: Text(_index == _slides.length - 1 ? 'شروع بازی' : 'ادامه'),
                    ),
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

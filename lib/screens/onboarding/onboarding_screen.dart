cat > lib/screens/onboarding/onboarding_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../core/theme/radical_theme.dart';

class _OnboardData {
  final IconData icon;
  final String titleFa;
  final String descriptionFa;

  const _OnboardData({
    required this.icon,
    required this.titleFa,
    required this.descriptionFa,
  });
}

const List<_OnboardData> _pages = [
  _OnboardData(
    icon: Icons.masks_outlined,
    titleFa: 'به دنیای مافیا رادیکال خوش اومدی',
    descriptionFa:
        'یک بازی اجتماعیِ نقش‌محور برای دورهمی با دوستان؛ هرکس یک نقش مخفی داره و باید حقیقت رو کشف کنه.',
  ),
  _OnboardData(
    icon: Icons.auto_awesome,
    titleFa: 'نقش‌هایی از دل اسطوره‌های ایرانی',
    descriptionFa:
        'از سیمرغ تا دیو سپید؛ هر نقش قدرت و هدف خودش رو داره. با تیم خودت هماهنگ شو یا تنها بازی کن.',
  ),
  _OnboardData(
    icon: Icons.groups_2_outlined,
    titleFa: 'لابی‌های آنلاین زنده',
    descriptionFa:
        'یک لابی بساز یا به یکی بپیوند، شب و روزهای بازی رو با صدای هم‌بازی‌هات تجربه کن.',
  ),
  _OnboardData(
    icon: Icons.diamond_outlined,
    titleFa: 'اقتصاد سکه و الماس',
    descriptionFa:
        'با بازی کردن سکه جمع کن، فریم و شخصیت باز کن و در فروشگاه چیزهای ویژه به‌دست بیار.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingServiceProvider).setOnboardingSeen();
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'رد کردن',
                      style: RadicalTheme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _OnboardPage(data: _pages[i]),
                ),
              ),
              _Dots(count: _pages.length, activeIndex: _index),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(_isLast ? 'بزن بریم' : 'بعدی'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RadicalTheme.glass,
              border: Border.all(color: RadicalTheme.glassBorder, width: 1.5),
              boxShadow: RadicalTheme.goldGlow(blur: 24, opacity: 0.2),
            ),
            child: Icon(data.icon, size: 62, color: RadicalTheme.gold),
          ),
          const SizedBox(height: 36),
          Text(
            data.titleFa,
            textAlign: TextAlign.center,
            style: RadicalTheme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          Text(
            data.descriptionFa,
            textAlign: TextAlign.center,
            style: RadicalTheme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _Dots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? RadicalTheme.gold : RadicalTheme.glass,
          ),
        );
      }),
    );
  }
}
EOF
echo "✅ onboarding_screen.dart ساخته شد"
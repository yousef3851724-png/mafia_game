mkdir -p lib/screens/onboarding
cat > lib/screens/onboarding/onboarding_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../core/theme/radical_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == 3;

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
                    child: Text('رد کردن', style: RadicalTheme.textTheme.bodyMedium),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: const [
                    _OnboardPage(icon: Icons.masks_outlined, title: 'به دنیای مافیا رادیکال خوش اومدی', desc: 'یک بازی اجتماعیِ نقش‌محور برای دورهمی با دوستان'),
                    _OnboardPage(icon: Icons.auto_awesome, title: 'نقش‌هایی از دل اسطوره‌های ایرانی', desc: 'از سیمرغ تا دیو سپید؛ هر نقش قدرت و هدف خودش رو داره'),
                    _OnboardPage(icon: Icons.groups_2_outlined, title: 'لابی‌های آنلاین زنده', desc: 'یک لابی بساز یا به یکی بپیوند'),
                    _OnboardPage(icon: Icons.diamond_outlined, title: 'اقتصاد سکه و الماس', desc: 'با بازی کردن سکه جمع کن'),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isActive = i == _index;
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
              ),
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
  final IconData icon;
  final String title;
  final String desc;
  
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.desc,
  });

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
            child: Icon(icon, size: 62, color: RadicalTheme.gold),
          ),
          const SizedBox(height: 36),
          Text(title, textAlign: TextAlign.center, style: RadicalTheme.textTheme.headlineMedium),
          const SizedBox(height: 14),
          Text(desc, textAlign: TextAlign.center, style: RadicalTheme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
EOF
echo "✅ onboarding_screen.dart ساخته شد"
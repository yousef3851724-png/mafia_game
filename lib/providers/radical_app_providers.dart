import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

/// سرویس آنبوردینگ به‌صورت Singleton در scope مربوط به Riverpod.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

/// وضعیت اولیه اپ: آیا آنبوردینگ دیده شده؟
/// این Provider برای تصمیم‌گیری Splash/Startup استفاده می‌شود.
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingServiceProvider);
  return service.hasSeenOnboarding();
});

/// تب فعال در نوار پایین صفحه‌ی خانه.
enum RadicalHomeTab { home, lobby, shop, profile }

final homeTabProvider = StateProvider<RadicalHomeTab>((ref) {
  return RadicalHomeTab.home;
});

/// کیف پول بازیکن؛ لایه‌ی اولیه‌ی اقتصاد بازی.
/// بعداً می‌تواند بدون تغییر UI به سرویس اقتصاد واقعی متصل شود.
class RadicalWallet {
  final int coins;
  final int diamonds;

  const RadicalWallet({required this.coins, required this.diamonds});
}

final walletProvider = StateProvider<RadicalWallet>((ref) {
  return const RadicalWallet(coins: 1250, diamonds: 40);
});

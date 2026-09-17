
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingServiceProvider);
  return service.hasSeenOnboarding();
});

enum RadicalHomeTab { home, lobby, shop, profile }

final homeTabProvider = StateProvider<RadicalHomeTab>((ref) {
  return RadicalHomeTab.home;
});

class RadicalWallet {
  final int coins;
  final int diamonds;
  const RadicalWallet({required this.coins, required this.diamonds});
}

final walletProvider = StateProvider<RadicalWallet>((ref) {
  return const RadicalWallet(coins: 1250, diamonds: 40);
});


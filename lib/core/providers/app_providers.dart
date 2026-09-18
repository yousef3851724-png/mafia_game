import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

/// Onboarding service as a Riverpod singleton.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

/// Whether onboarding has been seen (Splash / startup gate).
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingServiceProvider);
  return service.hasSeenOnboarding();
});

/// Active tab in the home bottom navigation.
enum RadicalHomeTab { home, lobby, shop, profile }

final homeTabProvider = StateProvider<RadicalHomeTab>((ref) {
  return RadicalHomeTab.home;
});

/// Player wallet; initial economy layer (can later connect to a real service).
class RadicalWallet {
  final int coins;
  final int diamonds;

  const RadicalWallet({required this.coins, required this.diamonds});
}

final walletProvider = StateProvider<RadicalWallet>((ref) {
  return const RadicalWallet(coins: 1250, diamonds: 40);
});


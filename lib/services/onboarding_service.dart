mkdir -p lib/core/services
cat > lib/core/services/onboarding_service.dart << 'EOF'
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _kHasSeenOnboarding = 'has_seen_onboarding';
  static const _kPlayerName = 'player_display_name';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasSeenOnboarding) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasSeenOnboarding, true);
  }

  Future<String?> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPlayerName);
  }

  Future<void> setPlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlayerName, name);
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHasSeenOnboarding);
    await prefs.remove(_kPlayerName);
  }
}
EOF
echo "✅ onboarding_service.dart ساخته شد"
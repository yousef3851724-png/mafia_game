import 'package:shared_preferences/shared_preferences.dart';

/// سرویس مدیریت وضعیت‌های ماندگار مربوط به شروع اپ:
/// آیا کاربر آنبوردینگ را دیده؟ آیا نامی برای پروفایل ثبت کرده است؟
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

  /// برای تست/دیباگ: ریست کامل وضعیت شروع اپ
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHasSeenOnboarding);
    await prefs.remove(_kPlayerName);
  }
}

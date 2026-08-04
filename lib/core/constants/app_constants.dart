/// ثابت‌های عمومی اپلیکیشن
class AppConstants {
  AppConstants._();

  static const String appName = 'مافیا رادیکال';
  static const String appVersion = '1.0.0';
  static const String dbName = 'mafia_radical.db';
  static const int dbVersion = 1;

  static const String prefsFirstRunKey = 'first_run';
  static const String prefsSoundKey = 'sound_enabled';
  static const String prefsVibrationKey = 'vibration_enabled';
  static const String prefsThemeKey = 'theme_mode';
  static const String prefsLastGameKey = 'last_game_id';

  static const Duration splashDuration = Duration(milliseconds: 1800);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}

/// ثابت‌های مرتبط با قوانین و منطق بازی مافیا رادیکال
class GameConstants {
  GameConstants._();

  static const int minPlayers = 6;
  static const int maxPlayers = 20;
  static const int defaultPlayers = 10;

  // زمان پیش‌فرض فازها (به ثانیه)
  static const int defaultNightDuration = 60;
  static const int defaultDayDiscussionDuration = 300;
  static const int defaultDefenseDuration = 60;
  static const int defaultVotingDuration = 45;
  static const int defaultGodfatherInquiryDuration = 20;

  // محدودیت تعداد نقش‌های خاص بر اساس تعداد بازیکن (مبنای ست رادیکال)
  static const Map<int, int> mafiaCountByPlayers = {
    6: 2,
    7: 2,
    8: 2,
    9: 3,
    10: 3,
    11: 3,
    12: 4,
    13: 4,
    14: 4,
    15: 5,
    16: 5,
    17: 5,
    18: 6,
    19: 6,
    20: 6,
  };
}

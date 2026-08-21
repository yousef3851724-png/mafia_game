/// ثابت‌های عمومی اپلیکیشن مافیا رادیکال
class AppConstants {
  AppConstants._();

  // اطلاعات برنامه
  static const String appName = 'مافیا رادیکال';
  static const String appVersion = '1.0.0';

  // دیتابیس محلی
  static const String dbName = 'mafia_radical.db';
  static const int dbVersion = 1;

  // SharedPreferences Keys
  static const String prefsFirstRunKey = 'first_run';
  static const String prefsSoundKey = 'sound_enabled';
  static const String prefsVibrationKey = 'vibration_enabled';
  static const String prefsThemeKey = 'theme_mode';
  static const String prefsLastGameKey = 'last_game_id';

  // زمان‌بندی رابط کاربری
  static const Duration splashDuration = Duration(milliseconds: 1800);
  static const Duration defaultAnimationDuration =
      Duration(milliseconds: 300);
}

/// ثابت‌ها و قوانین اصلی بازی مافیا رادیکال
class GameConstants {
  GameConstants._();

  // محدودیت تعداد بازیکنان
  static const int minPlayers = 6;
  static const int maxPlayers = 20;
  static const int defaultPlayers = 10;

  // زمان‌های پیش‌فرض مراحل بازی - بر حسب ثانیه
  static const int defaultNightDuration = 60;
  static const int defaultDayDiscussionDuration = 300;
  static const int defaultDefenseDuration = 60;
  static const int defaultVotingDuration = 45;
  static const int defaultGodfatherInquiryDuration = 20;

  /// تعداد مافیا بر اساس تعداد کل بازیکنان.
  ///
  /// این جدول برای یک سناریوی متعادل اولیه طراحی شده است.
  static const Map<int, int> mafiaByPlayers = {
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

  /// تعداد مافیا را با اعتبارسنجی تعداد بازیکنان برمی‌گرداند.
  ///
  /// اگر تعداد بازیکنان خارج از بازه‌ی مجاز باشد، خطا می‌دهد.
  static int getMafiaCount(int playerCount) {
    if (playerCount < minPlayers || playerCount > maxPlayers) {
      throw ArgumentError(
        'تعداد بازیکنان باید بین $minPlayers تا $maxPlayers باشد.',
      );
    }

    return mafiaByPlayers[playerCount]!;
  }

  /// تعداد شهروندان را بر اساس تعداد کل بازیکنان محاسبه می‌کند.
  static int getCitizenCount(int playerCount) {
    return playerCount - getMafiaCount(playerCount);
  }

  /// بررسی می‌کند تعداد واردشده برای بازیکنان معتبر است یا نه.
  static bool isValidPlayerCount(int playerCount) {
    return playerCount >= minPlayers && playerCount <= maxPlayers;
  }
}

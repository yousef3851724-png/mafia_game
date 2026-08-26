import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../logger/app_logger.dart';

/// سرویس ذخیره‌سازی ساده (تنظیمات کاربر، فلگ‌ها و ...)
class LocalStorageService {
  LocalStorageService._internal();
  static final LocalStorageService instance = LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      AppLogger.e('خطا در راه‌اندازی SharedPreferences', e, st);
      throw const StorageException('امکان راه‌اندازی حافظه محلی وجود نداشت');
    }
  }

  SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw const StorageException(
        'LocalStorageService باید قبل از استفاده init شود',
      );
    }
    return prefs;
  }

  bool get isFirstRun => _instance.getBool(AppConstants.prefsFirstRunKey) ?? true;
  Future<void> setFirstRunCompleted() =>
      _instance.setBool(AppConstants.prefsFirstRunKey, false);

  bool get isSoundEnabled => _instance.getBool(AppConstants.prefsSoundKey) ?? true;
  Future<void> setSoundEnabled(bool value) =>
      _instance.setBool(AppConstants.prefsSoundKey, value);

  bool get isVibrationEnabled =>
      _instance.getBool(AppConstants.prefsVibrationKey) ?? true;
  Future<void> setVibrationEnabled(bool value) =>
      _instance.setBool(AppConstants.prefsVibrationKey, value);

  String? get lastGameId => _instance.getString(AppConstants.prefsLastGameKey);
  Future<void> setLastGameId(String id) =>
      _instance.setString(AppConstants.prefsLastGameKey, id);
}

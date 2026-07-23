import 'package:logger/logger.dart';
import '../config/app_config.dart';

/// لاگر مرکزی اپ - در حالت production غیرفعال می‌شود
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void d(String message) {
    if (AppConfig.enableLogging) _logger.d(message);
  }

  static void i(String message) {
    if (AppConfig.enableLogging) _logger.i(message);
  }

  static void w(String message) {
    if (AppConfig.enableLogging) _logger.w(message);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    // در Section مربوط به Crash Reporting، اینجا به Sentry/Crashlytics وصل می‌شود
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'dependency_injection/injection_container.dart';
import 'logger/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // پیکربندی محیط اجرا (dev/staging/production)
  AppConfig.init(appFlavor: AppFlavor.production);

  // قفل چرخش صفحه در حالت پرتره برای تجربه بهتر حین بازی
  await SystemChromeSetup.lockToPortrait();

  // جلوگیری از خاموش شدن صفحه حین بازی (مهم برای فاز شب/رأی‌گیری)
  await WakelockPlus.enable();

  // راه‌اندازی دیتابیس، storage و سرویس‌های سراسری
  await initDependencies();

  FlutterError.onError = (details) {
    AppLogger.e('Flutter Error', details.exception, details.stack);
  };

  runApp(
    const ProviderScope(
      child: MafiaRadicalApp(),
    ),
  );
}

/// کلاس کمکی برای تنظیمات سیستمی صفحه
class SystemChromeSetup {
  SystemChromeSetup._();

  static Future<void> lockToPortrait() async {
    // پیاده‌سازی کامل (SystemChrome.setPreferredOrientations) در Section-02
    // به همراه تنظیمات نوار وضعیت/ناوبری اضافه می‌شود.
  }
}

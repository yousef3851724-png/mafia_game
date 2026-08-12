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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/game_controller.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const MafiaApp(),
    ),
  );
}

class MafiaApp extends StatelessWidget {
  const MafiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مافیا',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red[900],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[800],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
          contentTextStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

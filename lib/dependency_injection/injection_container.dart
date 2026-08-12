import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

final GetIt sl = GetIt.instance;

/// راه‌اندازی تمام سرویس‌های سراسری اپ - در main.dart قبل از runApp فراخوانی می‌شود
Future<void> initDependencies() async {
  // ---------- Storage ----------
  await LocalStorageService.instance.init();
  sl.registerSingleton<LocalStorageService>(LocalStorageService.instance);
  sl.registerSingleton<SecureStorageService>(SecureStorageService.instance);

  // ---------- Database ----------
  sl.registerSingleton<AppDatabase>(AppDatabase.instance);
  await sl<AppDatabase>().database; // warm-up: باز کردن اتصال از همان ابتدا

  // Repository ها و Provider های مربوط به منطق بازی در Section-02 اینجا اضافه می‌شوند
}
name: mafia_game
description: A complete Mafia game with AI
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  flutter_animate: ^4.5.0
  shared_preferences: ^2.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true

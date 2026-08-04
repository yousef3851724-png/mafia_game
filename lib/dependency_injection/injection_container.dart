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

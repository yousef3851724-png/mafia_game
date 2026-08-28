import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database_helper.dart';
import '../storage/shared_prefs_service.dart';
import '../storage/secure_storage_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);
  getIt.registerSingleton<SharedPrefsService>(SharedPrefsService(sharedPrefs));

  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<SecureStorageService>(SecureStorageService(secureStorage));

  // Database
  final databaseHelper = DatabaseHelper();
  await databaseHelper.initDatabase();
  getIt.registerSingleton<DatabaseHelper>(databaseHelper);

  // Repositories
  // (در بخش‌های بعدی اضافه می‌شوند)
}

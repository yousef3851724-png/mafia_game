import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ذخیره‌سازی امن - برای اطلاعات حساس (توکن‌های حالت آنلاین در Section بعدی)
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _authTokenKey = 'auth_token';

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _authTokenKey, value: token);

  Future<String?> getAuthToken() => _storage.read(key: _authTokenKey);

  Future<void> clearAuthToken() => _storage.delete(key: _authTokenKey);

  Future<void> clearAll() => _storage.deleteAll();
}

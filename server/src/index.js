import 'dart:convert';
import 'package:http/http.dart' as http;

/// آدرس Worker را بعد از دیپلوی از لاگ GitHub Actions بردار و اینجا بگذار.
const String kServerUrl = 'https://mafia-radical-server.SUBDOMAIN.workers.dev';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthUser {
  final String id;
  final String username;
  final int coins;
  final int diamonds;
  AuthUser(this.id, this.username, this.coins, this.diamonds);
}

class AuthResult {
  final String token;
  final AuthUser user;
  AuthResult(this.token, this.user);
}

class AuthApi {
  static Future<AuthResult> login(String username, String password) =>
      _post('/auth/login', username, password);

  static Future<AuthResult> register(String username, String password) =>
      _post('/auth/register', username, password);

  static Future<AuthResult> _post(
      String path, String username, String password) async {
    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$kServerUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthException('اتصال به سرور برقرار نشد');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final u = data['user'];
      return AuthResult(
        data['token'],
        AuthUser(u['id'], u['username'], u['coins'] ?? 0, u['diamonds'] ?? 0),
      );
    }
    throw AuthException(data['error']?.toString() ?? 'خطای ناشناخته');
  }
}
// استفاده در دکمه «ورود امن»:
//
// try {
//   final r = await AuthApi.login(userCtrl.text, passCtrl.text);
//   // r.token را ذخیره کن (مثلاً flutter_secure_storage) و برو صفحه‌ی بعد
// } on AuthException catch (e) {
//   ScaffoldMessenger.of(context)
//       .showSnackBar(SnackBar(content: Text(e.message)));
// }
//
// اتصال WebSocket به اتاق:
// WebSocketChannel.connect(Uri.parse(
//   '${kServerUrl.replaceFirst('https', 'wss')}/ws/123456?token=${r.token}'));

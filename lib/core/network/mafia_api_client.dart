import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// HTTP client for the deployed Mafia Radical backend.
///
/// Configure the origin at build time, for example:
/// --dart-define=MAFIA_API_BASE_URL=https://your-api.example.com
/// Do not put credentials or tokens in the source code.
class MafiaApiClient {
  MafiaApiClient({
    String? baseUrl,
    HttpClient? httpClient,
  })  : baseUrl = (baseUrl ??
                const String.fromEnvironment('MAFIA_API_BASE_URL'))
            .trim()
            .replaceFirst(RegExp(r'/+$'), ''),
        _client = httpClient ?? HttpClient();

  final String baseUrl;
  final HttpClient _client;
  String? _token;

  bool get isConfigured {
    final uri = Uri.tryParse(baseUrl);
    return uri != null &&
        uri.hasScheme &&
        uri.hasAuthority &&
        (uri.scheme == 'https' ||
            (uri.scheme == 'http' && _isLocalHost(uri.host)));
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  static bool _isLocalHost(String host) =>
      host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';

  void setAccessToken(String? token) {
    final value = token?.trim();
    _token = value == null || value.isEmpty ? null : value;
  }

  void signOut() => _token = null;

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? referralCode,
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
      if (referralCode != null && referralCode.trim().isNotEmpty)
        'referralCode': referralCode.trim(),
    };
    final result = await _request('POST', '/api/v1/auth/register', body: body);
    _saveTokenFrom(result);
    return result;
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final result = await _request('POST', '/api/v1/auth/login', body: {
      'username': username,
      'password': password,
    });
    _saveTokenFrom(result);
    return result;
  }

  Future<Map<String, dynamic>> me() =>
      _request('GET', '/api/v1/me', authenticated: true);

  Future<List<Map<String, dynamic>>> listRooms() async {
    final result = await _request('GET', '/api/v1/rooms', authenticated: true);
    final rooms = result['rooms'];
    if (rooms is! List) {
      throw const MafiaApiException('INVALID_RESPONSE', 'پاسخ فهرست لابی‌ها معتبر نیست.');
    }
    return rooms.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> createRoom({int maxPlayers = 20}) async {
    if (maxPlayers < 4 || maxPlayers > 20) {
      throw const MafiaApiException('INVALID_ARGUMENT', 'ظرفیت لابی باید بین ۴ تا ۲۰ نفر باشد.');
    }
    return _request('POST', '/api/v1/rooms',
        authenticated: true, body: {'maxPlayers': maxPlayers});
  }

  Future<Map<String, dynamic>> joinRoom(String code) =>
      _request('POST', '/api/v1/rooms/join',
          authenticated: true, body: {'code': code.trim().toUpperCase()});

  Future<Map<String, dynamic>> setReady(String code, bool ready) =>
      _request('POST', '/api/v1/rooms/${Uri.encodeComponent(code.trim().toUpperCase())}/ready',
          authenticated: true, body: {'ready': ready});

  Future<Map<String, dynamic>> startRoom(String code) =>
      _request('POST', '/api/v1/rooms/${Uri.encodeComponent(code.trim().toUpperCase())}/start',
          authenticated: true, body: const <String, dynamic>{});

  Future<Map<String, dynamic>> roomState(String code) =>
      _request('GET', '/api/v1/rooms/${Uri.encodeComponent(code.trim().toUpperCase())}/state',
          authenticated: true);

  /// Builds the authenticated lobby WebSocket URL. The backend accepts a
  /// token in the query string, so callers must use WSS in production and
  /// avoid logging this URI because it contains the access token.
  Uri lobbyWebSocketUri(String roomCode) {
    _requireConfigured();
    if (!isAuthenticated) {
      throw const MafiaApiException('UNAUTHENTICATED', 'ابتدا وارد حساب شوید.');
    }
    final origin = Uri.parse(baseUrl);
    final scheme = origin.scheme == 'https' ? 'wss' : 'ws';
    if (scheme != 'wss' && !_isLocalHost(origin.host)) {
      throw const MafiaApiException('INSECURE_TRANSPORT', 'اتصال WebSocket در محیط واقعی باید امن باشد.');
    }
    return origin.replace(
      scheme: scheme,
      path: '/lobby',
      queryParameters: {'roomCode': roomCode.trim().toUpperCase(), 'token': _token},
    );
  }

  void _saveTokenFrom(Map<String, dynamic> result) {
    final token = result['token'];
    if (token is String && token.isNotEmpty) _token = token;
  }

  void _requireConfigured() {
    if (!isConfigured) {
      throw const MafiaApiException(
        'API_NOT_CONFIGURED',
        'نشانی سرور تنظیم نشده است. هنگام ساخت برنامه MAFIA_API_BASE_URL را تعیین کنید.',
      );
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    bool authenticated = false,
    Map<String, dynamic>? body,
  }) async {
    _requireConfigured();
    if (authenticated && !isAuthenticated) {
      throw const MafiaApiException('UNAUTHENTICATED', 'ابتدا وارد حساب شوید.');
    }

    HttpClientRequest request;
    try {
      request = await _client.openUrl(method, Uri.parse(baseUrl).resolve(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (body != null) request.headers.contentType = ContentType.json;
      if (authenticated) request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_token');
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(const Duration(seconds: 15));
      final text = await response.transform(utf8.decoder).join();
      dynamic decoded;
      if (text.isNotEmpty) {
        try {
          decoded = jsonDecode(text);
        } on FormatException {
          throw const MafiaApiException('INVALID_RESPONSE', 'پاسخ سرور قابل‌خواندن نیست.');
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded is Map ? decoded['error'] : null;
        final code = error is Map && error['code'] is String
            ? error['code'] as String
            : 'HTTP_${response.statusCode}';
        final message = error is Map && error['message'] is String
            ? error['message'] as String
            : 'درخواست به سرور ناموفق بود.';
        throw MafiaApiException(code, message, statusCode: response.statusCode);
      }
      if (decoded is! Map<String, dynamic>) {
        throw const MafiaApiException('INVALID_RESPONSE', 'ساختار پاسخ سرور معتبر نیست.');
      }
      return decoded;
    } on SocketException {
      throw const MafiaApiException('NETWORK_ERROR', 'اتصال به سرور برقرار نشد.');
    } on TimeoutException {
      throw const MafiaApiException('TIMEOUT', 'پاسخ سرور بیش از حد طول کشید.');
    }
  }

  void close() {
    _client.close(force: true);
    _token = null;
  }
}

class MafiaApiException implements Exception {
  const MafiaApiException(this.code, this.message, {this.statusCode});

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'MafiaApiException($code): $message';
}

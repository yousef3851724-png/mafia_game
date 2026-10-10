import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_logo.dart';
import '../../router/app_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _referral = TextEditingController();
  static const _apiBase = String.fromEnvironment('API_BASE_URL');
  bool _register = false, _busy = false, _hidePassword = true;
  String? _error;

  @override
  void dispose() { _username.dispose(); _password.dispose(); _referral.dispose(); super.dispose(); }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (_apiBase.trim().isEmpty) {
      setState(() => _error = 'آدرس سرور تنظیم نشده است؛ API_BASE_URL را هنگام ساخت برنامه تعیین کنید.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final endpoint = _register ? 'register' : 'login';
      final body = <String, dynamic>{'username': _username.text.trim(), 'password': _password.text};
      if (_register && _referral.text.trim().isNotEmpty) body['referralCode'] = _referral.text.trim();
      final response = await http.post(
        Uri.parse('$_apiBase/api/v1/auth/$endpoint'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data is Map && data['error'] is Map ? data['error']['message']?.toString() : null;
        throw Exception(message ?? 'درخواست ناموفق بود (HTTP ${response.statusCode}).');
      }
      if (data is! Map || data['token'] is! String) throw Exception('پاسخ سرور معتبر نیست.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mafia_radical_access_token', data['token'] as String);
      final player = data['player'];
      if (player is Map && player['id'] != null) await prefs.setString('mafia_radical_player_id', player['id'].toString());
      if (mounted) context.go(RadicalRoutes.home);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
      child: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Form(
          key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(child: RadicalLogoMark(size: 100)),
            const SizedBox(height: 14),
            Text('مافیا رادیکال', textAlign: TextAlign.center, style: RadicalTheme.textTheme.headlineMedium?.copyWith(color: RadicalTheme.cream, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(_register ? 'ساخت حساب کاربری' : 'ورود به حساب کاربری', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [ButtonSegment(value: false, label: Text('ورود')), ButtonSegment(value: true, label: Text('ثبت‌نام'))],
              selected: {_register},
              onSelectionChanged: _busy ? null : (s) => setState(() { _register = s.first; _error = null; }),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _username, textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'نام کاربری', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => (v?.trim().length ?? 0) < 3 || (v?.trim().length ?? 0) > 24 ? 'نام کاربری باید ۳ تا ۲۴ نویسه باشد.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password, obscureText: _hidePassword,
              textInputAction: _register ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted: (_) { if (!_register) _submit(); },
              decoration: InputDecoration(labelText: 'گذرواژه', prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
              validator: (v) => (v?.length ?? 0) < 10 ? 'گذرواژه باید حداقل ۱۰ نویسه باشد.' : null,
            ),
            if (_register) ...[
              const SizedBox(height: 14),
              TextFormField(controller: _referral, decoration: const InputDecoration(labelText: 'کد دعوت (اختیاری)', prefixIcon: Icon(Icons.card_giftcard_outlined))),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: RadicalTheme.crimsonBright)),
            ],
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const CircularProgressIndicator() : Text(_register ? 'ساخت حساب' : 'ورود امن')),
            const SizedBox(height: 12),
            Text('اعتبارسنجی واقعی از طریق سرور انجام می‌شود؛ ورود نمایشی فعال نیست.', textAlign: TextAlign.center, style: RadicalTheme.textTheme.bodySmall?.copyWith(color: RadicalTheme.smoke)),
          ]),
        )),
      ))),
    ),
  );
}

import 'core/providers/wallet_persistence.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/scenarios/scenario_lobby_screen.dart';
import 'router/app_router.dart';
import 'core/theme/radical_theme.dart';

void main() {
  var appStarted = false;
  var appStarted = false;

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 10));

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              'خطا رخ داد:\n\n${details.exceptionAsString()}\n\n${details.stack}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );
    };

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
    };

    appStarted = true;
    appStarted = true;
    runApp(const ProviderScope(child: WalletPersistence(child: MafiaRadicalApp())));
  }, (error, stack) {
    debugPrint('UNCAUGHT ASYNC ERROR: $error\n$stack');
    if (appStarted == false) { appStarted = true; runApp(_StartupErrorApp('$error $stack')); }
    if (!appStarted) {
      appStarted = true;
      runApp(_StartupErrorApp('$error\n\n$stack'));
    }
  });
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              'خطا هنگام شروع برنامه:\n\n$message',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مافیا رادیکال',
      debugShowCheckedModeBanner: false,
      theme: RadicalTheme.dark(),
      routerConfig: radicalRouter,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}

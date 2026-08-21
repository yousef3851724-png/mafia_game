import 'package:flutter/material.dart';
import 'core/router/router.dart';

void main() {
  runApp(const MafiaRadicalApp());
}

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'مافیا رادیکال',
      routerConfig: router,
    );
  }
}

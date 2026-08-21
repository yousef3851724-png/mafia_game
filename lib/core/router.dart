import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Scaffold(
          body: Center(
            child: Text('Mafia Radical'),
          ),
        );
      },
    ),
  ],
);

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}

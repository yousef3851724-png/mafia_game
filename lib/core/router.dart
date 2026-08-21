import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    // مسیرهای بعدی در Section-02 به بعد اضافه می‌شوند
  ],
);

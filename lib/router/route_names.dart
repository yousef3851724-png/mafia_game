import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart'; // بعداً این فایل رو می‌سازیم

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

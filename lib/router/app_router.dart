import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../features/home/screens/home_screen.dart';
import '../features/shop/screens/shop_screen.dart';
import '../features/reconnect/screens/reconnect_screen.dart';
import '../features/lobby/screens/lobby_waiting_screen.dart';
import '../features/lobby/widgets/round_table_widget.dart';
import '../features/lobby/widgets/player_seat_widget.dart';

/// ⚠️ توجه: صفحات واقعی (Splash, Home, Setup, GameBoard و ...) در Section-02
/// (لایه‌ی features/screens) پیاده‌سازی و جایگزین این Placeholder ها می‌شوند.
/// این فایل فقط ساختار مسیریابی نهایی پروژه را مشخص می‌کند تا پروژه از همین
/// الان قابل اجرا و کامپایل باشد.

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(در Section بعدی پیاده‌سازی می‌شود)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      name: RouteNames.splash,
      path: RoutePaths.splash,
      builder: (context, state) => const _PlaceholderScreen(title: 'اسپلش'),
    ),
    GoRoute(
      name: RouteNames.home,
      path: RoutePaths.home,
      builder: (context, state) => HomeScreen(
        onOpenShop: () => context.pushNamed(RouteNames.shop),
        onFriendlyLobby: () => context.pushNamed(RouteNames.lobbyWaiting),
        onQuickGame: () => context.pushNamed(RouteNames.lobbyWaiting),
      ),
    ),
    GoRoute(
      name: RouteNames.shop,
      path: RoutePaths.shop,
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      name: RouteNames.reconnect,
      path: RoutePaths.reconnect,
      builder: (context, state) => ReconnectScreen(
        onEnterGame: () => context.goNamed(RouteNames.gameBoard),
        onBackToLobby: () => context.goNamed(RouteNames.lobbyWaiting),
      ),
    ),
    GoRoute(
      name: RouteNames.lobbyWaiting,
      path: RoutePaths.lobbyWaiting,
      builder: (context, state) => LobbyWaitingScreen(
        lobbyName: 'لابی دوستانه',
        lobbyCode: '5487',
        hostName: 'مافیا_خفن',
        onStartGame: () => context.pushNamed(RouteNames.roleAssignment),
        seats: const [
          SeatData(seatNumber: 1, playerName: 'مافیا_خفن', status: SeatStatus.ready, isHost: true),
          SeatData(seatNumber: 2, playerName: 'دختر_منطقی', status: SeatStatus.ready),
          SeatData(seatNumber: 3, playerName: 'قاضی_داد', status: SeatStatus.ready),
          SeatData(seatNumber: 4, playerName: 'سایه_شب', status: SeatStatus.notReady),
          SeatData(seatNumber: 5, playerName: 'ملکه_یخ', status: SeatStatus.ready),
          SeatData(seatNumber: 6, playerName: 'قاتل_بی‌نام', status: SeatStatus.notReady),
          SeatData(seatNumber: 7, playerName: 'پدرخوانده', status: SeatStatus.ready),
          SeatData(seatNumber: 8, playerName: 'راز_نهان', status: SeatStatus.notReady),
          SeatData(seatNumber: 9, playerName: 'مصمم_اصلی', status: SeatStatus.ready),
          SeatData(seatNumber: 10, status: SeatStatus.empty),
        ],
      ),
    ),
    GoRoute(
      name: RouteNames.setup,
      path: RoutePaths.setup,
      builder: (context, state) => const _PlaceholderScreen(title: 'تنظیم بازی'),
    ),
    GoRoute(
      name: RouteNames.roleAssignment,
      path: RoutePaths.roleAssignment,
      builder: (context, state) => const _PlaceholderScreen(title: 'تخصیص نقش'),
    ),
    GoRoute(
      name: RouteNames.roleReveal,
      path: RoutePaths.roleReveal,
      builder: (context, state) => const _PlaceholderScreen(title: 'نمایش نقش'),
    ),
    GoRoute(
      name: RouteNames.gameBoard,
      path: RoutePaths.gameBoard,
      builder: (context, state) => const _PlaceholderScreen(title: 'صفحه بازی'),
    ),
    GoRoute(
      name: RouteNames.nightPhase,
      path: RoutePaths.nightPhase,
      builder: (context, state) => const _PlaceholderScreen(title: 'فاز شب'),
    ),
    GoRoute(
      name: RouteNames.dayPhase,
      path: RoutePaths.dayPhase,
      builder: (context, state) => const _PlaceholderScreen(title: 'فاز روز'),
    ),
    GoRoute(
      name: RouteNames.voting,
      path: RoutePaths.voting,
      builder: (context, state) => const _PlaceholderScreen(title: 'رأی‌گیری'),
    ),
    GoRoute(
      name: RouteNames.gameResult,
      path: RoutePaths.gameResult,
      builder: (context, state) => const _PlaceholderScreen(title: 'نتیجه بازی'),
    ),
    GoRoute(
      name: RouteNames.settings,
      path: RoutePaths.settings,
      builder: (context, state) => const _PlaceholderScreen(title: 'تنظیمات'),
    ),
    GoRoute(
      name: RouteNames.roleGuide,
      path: RoutePaths.roleGuide,
      builder: (context, state) => const _PlaceholderScreen(title: 'راهنمای نقش‌ها'),
    ),
    GoRoute(
      name: RouteNames.history,
      path: RoutePaths.history,
      builder: (context, state) => const _PlaceholderScreen(title: 'تاریخچه بازی‌ها'),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('مسیر یافت نشد: ${state.uri}')),
  ),
);

import 'package:flutter/material.dart';
import '../../core/theme/radical_theme.dart';
import 'screens/avatar_shop_screen.dart';
import 'screens/frame_shop_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadicalTheme.background,
      appBar: AppBar(
        title: const Text('فروشگاه'),
        backgroundColor: RadicalTheme.panel,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'آواتارها'),
            Tab(text: 'فریم‌ها'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AvatarShopScreen(),
          FrameShopScreen(),
        ],
      ),
    );
  }
}

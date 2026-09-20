import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_scaffold.dart';
import 'screens/frame_shop_screen.dart';

class RadicalStoreScreen extends ConsumerStatefulWidget {
  const RadicalStoreScreen({super.key});

  @override
  ConsumerState<RadicalStoreScreen> createState() =>
      _RadicalStoreScreenState();
}

class _RadicalStoreScreenState extends ConsumerState<RadicalStoreScreen>
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
    return RadicalScaffold(
      title: 'فروشگاه',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'آواتارها'),
              Tab(text: 'فریم‌ها'),
            ],
            labelColor: RadicalTheme.gold,
            unselectedLabelColor: RadicalTheme.ink.withOpacity(0.5),
            indicatorColor: RadicalTheme.gold,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Avatars tab (placeholder)
                Center(
                  child: Text(
                    'آواتارها به‌زودی...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: RadicalTheme.ink.withOpacity(0.5),
                        ),
                  ),
                ),
                // Frames tab
                const FrameShopScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

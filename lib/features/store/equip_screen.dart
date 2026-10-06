import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/radical_theme.dart';
import 'controllers/store_controller.dart';
import 'store_hub_screen.dart';
import 'store_items.dart';

class EquipScreen extends ConsumerWidget {
  const EquipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: RadicalTheme.ink,
          appBar: AppBar(
            title: const Text('انتخاب آواتار و فریم'),
            backgroundColor: RadicalTheme.panel,
            bottom: const TabBar(
                tabs: [Tab(text: 'آواتارها'), Tab(text: 'فریم‌ها')]),
          ),
          body: const TabBarView(children: [
            _OwnedGrid(category: StoreCategory.avatar),
            _OwnedGrid(category: StoreCategory.frame),
          ]),
        ),
      ),
    );
  }
}

class _OwnedGrid extends ConsumerWidget {
  final StoreCategory category;
  const _OwnedGrid({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(storeControllerProvider);
    final owned = StoreItems.of(category).where(st.isOwned).toList();
    if (owned.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هنوز چیزی نخریده‌ای'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StoreHubScreen()),
              ),
              child: const Text('رفتن به فروشگاه'),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: owned.length,
      itemBuilder: (context, i) {
        final item = owned[i];
        final on = st.isEquipped(item);
        return GestureDetector(
          onTap: () =>
              ref.read(storeControllerProvider.notifier).equip(item),
          child: Container(
            decoration: BoxDecoration(
              color: RadicalTheme.panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: on ? RadicalTheme.goldBright : RadicalTheme.line,
                width: on ? 2.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(item.assetPath, fit: BoxFit.contain),
                ),
                Text(on ? 'تجهیز شده' : item.nameFa,
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }
}

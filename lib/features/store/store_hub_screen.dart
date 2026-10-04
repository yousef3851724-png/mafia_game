import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/radical_theme.dart';
import 'controllers/store_controller.dart';
import 'store_items.dart';

String faNum(int n) {
  const en = '0123456789';
  const fa = '۰۱۲۳۴۵۶۷۸۹';
  var s = n.toString();
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(en[i], fa[i]);
  }
  return s;
}

String categoryTitle(StoreCategory c) {
  switch (c) {
    case StoreCategory.avatar:
      return 'آواتارها';
    case StoreCategory.frame:
      return 'فریم‌ها';
    case StoreCategory.sticker:
      return 'استیکرها';
    case StoreCategory.gif:
      return 'گیف‌ها';
    case StoreCategory.tombstone:
      return 'سنگ قبرها';
  }
}

class StoreHubScreen extends ConsumerWidget {
  const StoreHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = StoreCategory.values;
    final wallet = ref.watch(walletProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: cats.length,
        child: Scaffold(
          backgroundColor: RadicalTheme.ink,
          appBar: AppBar(
            title: const Text('فروشگاه'),
            backgroundColor: RadicalTheme.panel,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Center(
                  child: Text(
                      '${faNum(wallet.coins)} سکه  •  ${faNum(wallet.diamonds)} الماس',
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: [for (final c in cats) Tab(text: categoryTitle(c))],
            ),
          ),
          body: TabBarView(
            children: [for (final c in cats) _CategoryGrid(category: c)],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  final StoreCategory category;
  const _CategoryGrid({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = StoreItems.of(category);
    final st = ref.watch(storeControllerProvider);
    if (items.isEmpty) {
      return const Center(
        child: Text('به‌زودی',
            style: TextStyle(fontSize: 18, color: Colors.white54)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.72,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final owned = st.isOwned(item);
        final equipped = st.isEquipped(item);
        final unit = item.currency == StoreCurrency.coins ? 'سکه' : 'الماس';
        return GestureDetector(
          onTap: () async {
            final c = ref.read(storeControllerProvider.notifier);
            final messenger = ScaffoldMessenger.of(context);
            if (owned) {
              await c.equip(item);
              messenger.showSnackBar(const SnackBar(content: Text('تجهیز شد')));
            } else {
              final ok = await c.buy(item);
              final msg = ref.read(storeControllerProvider).message;
              messenger.showSnackBar(
                SnackBar(
                    content: Text(ok ? 'خرید انجام شد' : (msg ?? 'خرید انجام نشد'))),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: RadicalTheme.panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: equipped ? RadicalTheme.goldBright : RadicalTheme.line,
                width: equipped ? 2.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(item.assetPath,
                      fit: BoxFit.contain, filterQuality: FilterQuality.high),
                ),
                const SizedBox(height: 4),
                Text(item.nameFa,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  equipped
                      ? 'تجهیز شده'
                      : owned
                          ? 'تجهیز'
                          : '${faNum(item.price)} $unit',
                  style: TextStyle(
                    fontSize: 11,
                    color: owned ? RadicalTheme.goldBright : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

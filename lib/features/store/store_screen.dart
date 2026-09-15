import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/widgets/radical_scaffold.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int coins = 0;
  final owned = <String>{'avatar_shadow'};
  static const products = <_Product>[
    _Product('avatar_shadow','سایه شب','آواتار',100,'assets/images/avatar_shadow.svg',Icons.person_rounded),
    _Product('avatar_detective','بازرس','آواتار',200,'assets/images/avatar_detective.svg',Icons.search_rounded),
    _Product('avatar_crimson','قرمز مرموز','آواتار',300,'assets/images/avatar_crimson.svg',Icons.local_fire_department_rounded),
    _Product('avatar_gold','طلایی رادیکال','آواتار VIP',500,'assets/images/avatar_gold.svg',Icons.workspace_premium_rounded),
    _Product('frame_fire','فریم آتش','فریم',180,null,Icons.local_fire_department_rounded),
    _Product('frame_lightning','فریم صاعقه','فریم',180,null,Icons.bolt_rounded),
    _Product('sticker_mvp','استیکر MVP','استیکر',120,null,Icons.emoji_events_rounded),
    _Product('sticker_sus','استیکر مشکوک','استیکر',90,null,Icons.visibility_rounded),
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getStringList('owned_store_items');
    if (!mounted) return;
    setState(() {
      coins = p.getInt('player_coins') ?? 1000;
      if (saved != null) owned.addAll(saved);
    });
  }

  Future<void> _tap(_Product item) async {
    final p = await SharedPreferences.getInstance();
    if (!owned.contains(item.id)) {
      if (coins < item.price) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سکه کافی نیست.')));
        return;
      }
      coins -= item.price;
      owned.add(item.id);
      await p.setInt('player_coins', coins);
      await p.setStringList('owned_store_items', owned.toList());
    }
    if (item.category == 'آواتار' || item.category == 'آواتار VIP') {
      await p.setString('selected_store_avatar', item.id);
    } else if (item.category == 'فریم') {
      await p.setString('selected_frame', item.id);
    } else {
      await p.setString('selected_sticker', item.id);
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} فعال شد ✓')));
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: RadicalScaffold(
      appBar: AppBar(title: const Text('فروشگاه رادیکال')),
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: RadicalTheme.glass(accent: true),
            child: Row(children: [
              const Icon(Icons.monetization_on_rounded, color: RadicalTheme.goldBright, size: 32),
              const SizedBox(width: 10),
              const Expanded(child: Text('موجودی سکه', style: TextStyle(fontWeight: FontWeight.w800))),
              Text('$coins', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: RadicalTheme.goldBright)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('آیتم‌های رادیکال', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .78),
            itemBuilder: (_, i) {
              final item = products[i];
              final isOwned = owned.contains(item.id);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: RadicalTheme.line)),
                child: Column(children: [
                  Expanded(child: item.asset == null ? Icon(item.icon, size: 64, color: RadicalTheme.goldBright) : ClipRRect(borderRadius: BorderRadius.circular(16), child: SvgPicture.asset(item.asset!, fit: BoxFit.contain))),
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(item.category, style: const TextStyle(fontSize: 11, color: RadicalTheme.smoke)),
                  const SizedBox(height: 7),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _tap(item), child: Text(isOwned ? 'فعال‌سازی' : '${item.price} سکه'))),
                ]),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _Product {
  final String id, name, category;
  final int price;
  final String? asset;
  final IconData icon;
  const _Product(this.id, this.name, this.category, this.price, this.asset, this.icon);
}

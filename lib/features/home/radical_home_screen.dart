import 'package:flutter/material.dart';
import '../scenarios/scenario_lobby_screen.dart';

class RadicalHomeScreen extends StatefulWidget {
  const RadicalHomeScreen({super.key});
  @override
  State<RadicalHomeScreen> createState() => _RadicalHomeScreenState();
}

class _RadicalHomeScreenState extends State<RadicalHomeScreen> {
  int _tab = 0;
  void _openLobby() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator')));

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[_HomeTab(onPlay: _openLobby, onStore: () => setState(() => _tab = 1)), const RadicalStoreScreen(), const _ProfileTab()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080B12),
        body: SafeArea(child: pages[_tab]),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF101621),
          indicatorColor: const Color(0x33D4AF87),
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'فروشگاه'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'پروفایل'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onStore;
  const _HomeTab({required this.onPlay, required this.onStore});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverPadding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), sliver: SliverToBoxAdapter(child: _Header(onStore: onStore))),
    SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _HeroCard(onPlay: onPlay))),
    SliverPadding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), sliver: SliverToBoxAdapter(child: Text('دسترسی سریع', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))),
    SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverGrid.count(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.25, children: [
      _ActionCard(icon: Icons.play_circle_fill, title: 'شروع بازی', subtitle: 'انتخاب سناریو و لابی', onTap: onPlay),
      _ActionCard(icon: Icons.storefront, title: 'فروشگاه', subtitle: 'آواتار و آیتم‌های ویژه', onTap: onStore),
      _ActionCard(icon: Icons.auto_awesome, title: 'سناریوها', subtitle: 'کلاسیک و مدرن', onTap: onPlay),
      _ActionCard(icon: Icons.emoji_events, title: 'رقابتی', subtitle: 'امتیاز و رتبه فصل', onTap: onPlay),
    ])),
    SliverPadding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), sliver: SliverToBoxAdapter(child: _FeatureBanner())),
  ]);
}

class _Header extends StatelessWidget {
  final VoidCallback onStore;
  const _Header({required this.onStore});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFD4AF87), Color(0xFF6E4B2A)])), child: const Icon(Icons.theater_comedy, color: Colors.black, size: 30)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مافیا رادیکال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text('وقتشه بازی رو شروع کنیم 🔥', style: TextStyle(color: Colors.white54))])),
    IconButton(onPressed: onStore, icon: const Icon(Icons.shopping_bag_outlined)),
  ]);
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onPlay;
  const _HeroCard({required this.onPlay});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF3A2730), Color(0xFF171D29)]), border: Border.all(color: Color(0x33D4AF87))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('🎭 فصل جدید مافیا', style: TextStyle(color: Color(0xFFD4AF87), fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const Text('سناریوت رو انتخاب کن\nو وارد بازی شو', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1.15)),
    const SizedBox(height: 18),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onPlay, icon: const Icon(Icons.play_arrow_rounded), label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('شروع بازی', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))))),
  ]));
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111722), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFFD4AF87), size: 34), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12))])));
}

class _FeatureBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF111722), borderRadius: BorderRadius.circular(22)), child: const Row(children: [Icon(Icons.shield_outlined, color: Color(0xFFD4AF87), size: 34), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تجربه کامل بازی', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('سناریو، نقش‌ها، لابی، رأی‌گیری و فروشگاه در یک محیط یکپارچه.', style: TextStyle(color: Colors.white54, height: 1.4))]))]));
}

class RadicalStoreScreen extends StatefulWidget {
  const RadicalStoreScreen({super.key});
  @override
  State<RadicalStoreScreen> createState() => _RadicalStoreScreenState();
}

class _RadicalStoreScreenState extends State<RadicalStoreScreen> {
  int coins = 120;
  final owned = <String>{};
  final products = const [
    ('آواتار مافیا', 'avatar_mafia', '🕴️', 80), ('آواتار کارآگاه', 'avatar_detective', '🕵️', 80), ('آواتار دلقک', 'avatar_clown', '🤡', 120),
    ('فریم طلایی', 'frame_gold', '✨', 150), ('فریم شب خونین', 'frame_night', '🌙', 180), ('بسته ۵۰۰ سکه', 'coins_500', '🪙', 400),
  ];
  void buy(String id, int price) {
    if (owned.contains(id)) return;
    if (coins < price) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سکه کافی نیست.'))); return; }
    setState(() { coins -= price; owned.add(id); });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('با موفقیت خریداری شد ✅')));
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), children: [
    Row(children: [const Expanded(child: Text('فروشگاه', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: const Color(0xFF191F2B), borderRadius: BorderRadius.circular(18)), child: Text('🪙 $coins', style: const TextStyle(fontWeight: FontWeight.bold)))]),
    const SizedBox(height: 8), const Text('آواتارها و آیتم‌های اختصاصی خودت رو بگیر.', style: TextStyle(color: Colors.white54)), const SizedBox(height: 20),
    ...products.map((p) => Card(color: const Color(0xFF111722), margin: const EdgeInsets.only(bottom: 12), child: ListTile(contentPadding: const EdgeInsets.all(12), leading: CircleAvatar(radius: 27, backgroundColor: const Color(0xFF242B38), child: Text(p.$3, style: const TextStyle(fontSize: 25))), title: Text(p.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('آیتم ویژه • ${p.$4} 🪙'), trailing: FilledButton(onPressed: owned.contains(p.$2) ? null : () => buy(p.$2, p.$4), child: Text(owned.contains(p.$2) ? 'دارم' : 'خرید')))),
  ]);
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [SizedBox(height: 30), CircleAvatar(radius: 48, backgroundColor: Color(0xFF242B38), child: Icon(Icons.person, size: 52, color: Color(0xFFD4AF87))), SizedBox(height: 14), Center(child: Text('بازیکن رادیکال', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900))), SizedBox(height: 6), Center(child: Text('سطح 1 • تازه‌وارد', style: TextStyle(color: Colors.white54))), SizedBox(height: 30), Card(child: ListTile(leading: Icon(Icons.emoji_events), title: Text('رتبه فصل'), subtitle: Text('Associate 🎖️'))), Card(child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('کلکسیون'), subtitle: Text('آواتارها و فریم‌های خریداری‌شده')))]);
}

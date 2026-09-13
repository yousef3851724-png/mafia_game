import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../scenarios/scenario_lobby_screen.dart';

class RadicalHomeScreen extends StatefulWidget {
  const RadicalHomeScreen({super.key});
  @override
  State<RadicalHomeScreen> createState() => _RadicalHomeScreenState();
}

class _RadicalHomeScreenState extends State<RadicalHomeScreen> {
  int _tab = 0;
  String _avatar = '🎭';
  int _level = 1;

  Future<void> _loadProfile() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _avatar = p.getString('selected_avatar') ?? '🎭';
      _level = p.getInt('player_level') ?? 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _openLobby() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(avatar: _avatar, level: _level, onPlay: _openLobby, onStore: () => setState(() => _tab = 1)),
      RadicalStoreScreen(onChanged: _loadProfile),
      _ProfileTab(avatar: _avatar, level: _level, onChanged: _loadProfile),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF070A10),
        body: SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: pages[_tab])),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF0D121B),
          indicatorColor: const Color(0x26D4AF87),
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
  final String avatar;
  final int level;
  final VoidCallback onPlay;
  final VoidCallback onStore;
  const _HomeTab({required this.avatar, required this.level, required this.onPlay, required this.onStore});

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            sliver: SliverToBoxAdapter(child: _Header(avatar: avatar, level: level, onStore: onStore)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverToBoxAdapter(child: _HeroCard(onPlay: onPlay)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
            sliver: SliverToBoxAdapter(child: Text('دسترسی سریع', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.18,
              children: [
                _ActionCard(icon: Icons.play_circle_fill, title: 'شروع بازی', subtitle: 'سناریو و لابی', onTap: onPlay),
                _ActionCard(icon: Icons.storefront, title: 'فروشگاه', subtitle: 'آواتار و آیتم ویژه', onTap: onStore),
                _ActionCard(icon: Icons.auto_awesome, title: 'سناریوها', subtitle: 'کلاسیک و مدرن', onTap: onPlay),
                _ActionCard(icon: Icons.emoji_events, title: 'رقابتی', subtitle: 'امتیاز و رتبه', onTap: onPlay),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            sliver: SliverToBoxAdapter(child: _FeatureBanner()),
          ),
        ],
      );
}

class _Header extends StatelessWidget {
  final String avatar;
  final int level;
  final VoidCallback onStore;
  const _Header({required this.avatar, required this.level, required this.onStore});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFE4C18F), Color(0xFF76502C)]), boxShadow: const [BoxShadow(color: Color(0x35D4AF87), blurRadius: 16)]), child: Center(child: Text(avatar, style: const TextStyle(fontSize: 28)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('مافیا رادیکال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text('سطح $level • آماده‌ای برای بازی؟', style: const TextStyle(color: Colors.white54)),
        ])),
        IconButton(onPressed: onStore, icon: const Icon(Icons.shopping_bag_outlined)),
      ]);
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onPlay;
  const _HeroCard({required this.onPlay});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF3A2730), Color(0xFF121824)]), border: Border.all(color: const Color(0x35D4AF87)), boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 22, offset: Offset(0, 10))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🎭 فصل جدید مافیا', style: TextStyle(color: Color(0xFFD4AF87), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('سناریوت رو انتخاب کن\nو وارد بازی شو', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.12)),
          const SizedBox(height: 8),
          const Text('نقش بگیر، بلوف بزن، رأی بده و برنده شو.', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onPlay, icon: const Icon(Icons.play_arrow_rounded), label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('شروع بازی', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))))),
        ]),
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF101620),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFFD4AF87), size: 34), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12))]))),
      );
}

class _FeatureBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF101620), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)), child: const Row(children: [Icon(Icons.shield_outlined, color: Color(0xFFD4AF87), size: 34), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تجربه کامل بازی', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('سناریو، نقش‌ها، لابی، رأی‌گیری، پروفایل و فروشگاه در یک محیط یکپارچه.', style: TextStyle(color: Colors.white54, height: 1.4))]))]));
}

class RadicalStoreScreen extends StatefulWidget {
  final Future<void> Function()? onChanged;
  const RadicalStoreScreen({super.key, this.onChanged});
  @override
  State<RadicalStoreScreen> createState() => _RadicalStoreScreenState();
}

class _RadicalStoreScreenState extends State<RadicalStoreScreen> {
  int coins = 120;
  final owned = <String>{};
  final products = const [
    ('آواتار مافیا', 'avatar_mafia', '🕴️', 80),
    ('آواتار کارآگاه', 'avatar_detective', '🕵️', 80),
    ('آواتار دلقک', 'avatar_clown', '🤡', 120),
    ('آواتار رئیس', 'avatar_boss', '🎩', 180),
    ('فریم طلایی', 'frame_gold', '✨', 150),
    ('فریم شب خونین', 'frame_night', '🌙', 180),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      coins = p.getInt('store_coins') ?? 120;
      owned.addAll(p.getStringList('owned_items') ?? const []);
    });
  }

  Future<void> buy(String id, int price, String avatar) async {
    if (owned.contains(id)) return;
    if (coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سکه کافی نیست.')));
      return;
    }
    final p = await SharedPreferences.getInstance();
    final next = coins - price;
    final nextOwned = {...owned, id}.toList();
    await p.setInt('store_coins', next);
    await p.setStringList('owned_items', nextOwned);
    if (id.startsWith('avatar_')) await p.setString('selected_avatar', avatar);
    if (!mounted) return;
    setState(() { coins = next; owned.add(id); });
    await widget.onChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خرید با موفقیت انجام شد ✅')));
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 30), children: [
        Row(children: [const Expanded(child: Text('فروشگاه', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: const Color(0xFF191F2B), borderRadius: BorderRadius.circular(18)), child: Text('🪙 $coins', style: const TextStyle(fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 6),
        const Text('کلکسیونت را بساز و ظاهر بازیکنت را شخصی کن.', style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 20),
        ...products.map((p) => Card(color: const Color(0xFF101620), margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: ListTile(contentPadding: const EdgeInsets.all(12), leading: CircleAvatar(radius: 28, backgroundColor: const Color(0xFF252D3A), child: Text(p.$3, style: const TextStyle(fontSize: 25))), title: Text(p.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text('${p.$4} 🪙 • آیتم ویژه')), trailing: FilledButton(onPressed: owned.contains(p.$2) ? null : () => buy(p.$2, p.$4, p.$3), child: Text(owned.contains(p.$2) ? 'دارم' : 'خرید')))),
      ]);
}

class _ProfileTab extends StatelessWidget {
  final String avatar;
  final int level;
  final Future<void> Function() onChanged;
  const _ProfileTab({required this.avatar, required this.level, required this.onChanged});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 26, 18, 30), children: [
        Center(child: Container(width: 112, height: 112, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFE4C18F), Color(0xFF76502C)]), boxShadow: const [BoxShadow(color: Color(0x45D4AF87), blurRadius: 25)]), child: Center(child: Text(avatar, style: const TextStyle(fontSize: 54))))),
        const SizedBox(height: 16),
        const Center(child: Text('بازیکن رادیکال', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
        const SizedBox(height: 5),
        Center(child: Text('سطح $level • عضو فصل جاری', style: const TextStyle(color: Colors.white54))),
        const SizedBox(height: 26),
        const _ProfileCard(icon: Icons.emoji_events, title: 'رتبه فصل', value: 'تازه‌وارد 🎖️'),
        const SizedBox(height: 10),
        const _ProfileCard(icon: Icons.inventory_2_outlined, title: 'کلکسیون', value: 'آواتارها و فریم‌های خریداری‌شده'),
        const SizedBox(height: 10),
        _ProfileCard(icon: Icons.refresh, title: 'همگام‌سازی', value: 'اطلاعات خرید روی همین دستگاه ذخیره می‌شود', onTap: onChanged),
      ]);
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Future<void> Function()? onTap;
  const _ProfileCard({required this.icon, required this.title, required this.value, this.onTap});
  @override
  Widget build(BuildContext context) => Card(color: const Color(0xFF101620), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: ListTile(leading: Icon(icon, color: const Color(0xFFD4AF87)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(value), trailing: onTap == null ? null : IconButton(icon: const Icon(Icons.sync), onPressed: onTap)));
}

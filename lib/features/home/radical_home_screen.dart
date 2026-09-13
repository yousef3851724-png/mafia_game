import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/radical_theme.dart';
import '../scenarios/realistic_avatar.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _avatar = prefs.getString('selected_avatar') ?? '🎭';
      _level = prefs.getInt('player_level') ?? 1;
    });
  }

  void _openLobby() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(
        avatar: _avatar,
        level: _level,
        onPlay: _openLobby,
        onStore: () => setState(() => _tab = 1),
      ),
      RadicalStoreScreen(onChanged: _loadProfile),
      _ProfileTab(avatar: _avatar, level: _level, onChanged: _loadProfile),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween<double>(begin: .98, end: 1),
                ),
                child: child,
              ),
            ),
            child: pages[_tab],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          height: 72,
          backgroundColor: RadicalTheme.panel,
          indicatorColor: RadicalTheme.gold.withOpacity(.16),
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
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

  const _HomeTab({
    required this.avatar,
    required this.level,
    required this.onPlay,
    required this.onStore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        _Header(avatar: avatar, level: level, onStore: onStore),
        const SizedBox(height: 20),
        _HeroCard(onPlay: onPlay),
        const SizedBox(height: 24),
        const _SectionHeading(
          title: 'دسترسی سریع',
          subtitle: 'همه چیز برای ورود به میز بازی',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.18,
          children: [
            _ActionCard(icon: Icons.play_circle_fill_rounded, title: 'شروع بازی', subtitle: 'سناریو و لابی', onTap: onPlay),
            _ActionCard(icon: Icons.storefront_rounded, title: 'فروشگاه', subtitle: 'آواتار و آیتم', onTap: onStore),
            _ActionCard(icon: Icons.auto_awesome_rounded, title: 'سناریوها', subtitle: 'کلاسیک و مدرن', onTap: onPlay),
            _ActionCard(icon: Icons.emoji_events_rounded, title: 'رقابتی', subtitle: 'امتیاز و رتبه', onTap: onPlay),
          ],
        ),
        const SizedBox(height: 18),
        const _FeatureBanner(),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String avatar;
  final int level;
  final VoidCallback onStore;

  const _Header({required this.avatar, required this.level, required this.onStore});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AvatarBadge(avatar: avatar, size: 58),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مافیا رادیکال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              SizedBox(height: 3),
              Text('اتاق عملیات • آماده‌ای؟', style: TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: RadicalTheme.panel2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RadicalTheme.line),
          ),
          child: Text('LV.$level', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900)),
        ),
        IconButton(onPressed: onStore, icon: const Icon(Icons.shopping_bag_outlined)),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String avatar;
  final double size;

  const _AvatarBadge({required this.avatar, required this.size});

  String get role {
    switch (avatar) {
      case '🕴️':
        return 'مافیا';
      case '🕵️':
        return 'کارآگاه';
      case '🤡':
        return 'دلقک';
      case '🎩':
        return 'پدرخوانده';
      default:
        return 'شهروند';
    }
  }

  bool get female => avatar == '🕵️';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.crimson]),
        boxShadow: [BoxShadow(color: RadicalTheme.gold.withOpacity(.20), blurRadius: 18)],
      ),
      child: RealisticAvatar(role: role, female: female, size: size - 5),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onPlay;

  const _HeroCard({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A202B), Color(0xFF171A24), Color(0xFF0E1118)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: RadicalTheme.gold.withOpacity(.24)),
        boxShadow: [BoxShadow(color: RadicalTheme.crimson.withOpacity(.10), blurRadius: 28, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(top: -26, left: -18, child: Icon(Icons.auto_awesome, size: 110, color: RadicalTheme.gold.withOpacity(.055))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.local_fire_department_rounded, color: RadicalTheme.crimsonBright, size: 18), SizedBox(width: 6), Text('فصل جدید مافیا', style: TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w800))]),
              const SizedBox(height: 12),
              const Text('وارد میز شو.\nنقشت را بازی کن.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.08)),
              const SizedBox(height: 9),
              const Text('بلوف بزن، متحد شو، رأی بده و آخرین بازمانده باش.', style: TextStyle(color: RadicalTheme.smoke, height: 1.4)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text('ورود به بازی', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadicalTheme.panel,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: RadicalTheme.gold.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: RadicalTheme.goldBright, size: 27)),
              const SizedBox(height: 11),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: RadicalTheme.goldBright, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تجربه کامل رادیکال', style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('سناریو، نقش‌ها، لابی، میز بازی، رأی‌گیری، پروفایل و فروشگاه؛ همه در یک هویت بصری.', style: TextStyle(color: RadicalTheme.smoke, height: 1.4, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadicalStoreScreen extends StatefulWidget {
  final Future<void> Function()? onChanged;

  const RadicalStoreScreen({super.key, this.onChanged});

  @override
  State<RadicalStoreScreen> createState() => _RadicalStoreScreenState();
}

class _RadicalStoreScreenState extends State<RadicalStoreScreen> {
  int coins = 120;
  final Set<String> owned = <String>{};

  static const products = <({String name, String id, String avatar, int price})>[
    (name: 'آواتار مافیا', id: 'avatar_mafia', avatar: '🕴️', price: 80),
    (name: 'آواتار کارآگاه', id: 'avatar_detective', avatar: '🕵️', price: 80),
    (name: 'آواتار دلقک', id: 'avatar_clown', avatar: '🤡', price: 120),
    (name: 'آواتار رئیس', id: 'avatar_boss', avatar: '🎩', price: 180),
    (name: 'فریم طلایی', id: 'frame_gold', avatar: '✨', price: 150),
    (name: 'فریم شب خونین', id: 'frame_night', avatar: '🌙', price: 180),
    (name: 'فریم شاهین • اختصاصی اکانت', id: 'frame_falcon_private', avatar: '🦅', price: 999999999),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      coins = prefs.getInt('store_coins') ?? 120;
      owned
        ..clear()
        ..addAll(prefs.getStringList('owned_items') ?? <String>[]);
    });
  }

  Future<void> buy(String id, int price, String avatar) async {
    if (owned.contains(id)) return;
    if (id == 'frame_falcon_private') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فریم شاهین فعلاً رزرو شده و قابل خرید عمومی نیست.')));
      return;
    }
    if (coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سکه کافی نیست.')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final nextCoins = coins - price;
    final nextOwned = <String>{...owned, id};
    await prefs.setInt('store_coins', nextCoins);
    await prefs.setStringList('owned_items', nextOwned.toList());
    if (id.startsWith('avatar_')) await prefs.setString('selected_avatar', avatar);
    if (!mounted) return;
    setState(() {
      coins = nextCoins;
      owned.add(id);
    });
    await widget.onChanged?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آیتم با موفقیت به کلکسیون اضافه شد ✅')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      children: [
        Row(
          children: [
            const Expanded(child: Text('فروشگاه رادیکال', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: RadicalTheme.panel2, borderRadius: BorderRadius.circular(16), border: Border.all(color: RadicalTheme.line)),
              child: Text('🪙 $coins', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text('آواتار و فریم مورد علاقه‌ات را برای میز بازی انتخاب کن.', style: TextStyle(color: RadicalTheme.smoke)),
        const SizedBox(height: 20),
        for (final product in products)
          _ProductCard(product: product, owned: owned.contains(product.id), onBuy: () => buy(product.id, product.price, product.avatar)),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ({String name, String id, String avatar, int price}) product;
  final bool owned;
  final VoidCallback onBuy;

  const _ProductCard({required this.product, required this.owned, required this.onBuy});

  bool get privateFrame => product.id == 'frame_falcon_private';

  @override
  Widget build(BuildContext context) {
    final priceLabel = privateFrame ? 'رزرو خصوصی' : '${product.price} 🪙';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: privateFrame ? RadicalTheme.gold.withOpacity(.38) : RadicalTheme.line)),
      child: Row(
        children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.panel2, border: Border.all(color: RadicalTheme.gold.withOpacity(.22))), child: Center(child: Text(product.avatar, style: const TextStyle(fontSize: 27)))),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(privateFrame ? 'رزرو خصوصی • 999,999,999 🪙' : priceLabel, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
            ]),
          ),
          FilledButton(onPressed: owned || privateFrame ? null : onBuy, child: Text(privateFrame ? 'رزرو' : owned ? 'فعال' : 'خرید')),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String avatar;
  final int level;
  final Future<void> Function() onChanged;

  const _ProfileTab({required this.avatar, required this.level, required this.onChanged});

  Future<Map<String, int>> _stats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'xp': prefs.getInt('player_xp') ?? 0,
      'played': prefs.getInt('games_played') ?? 0,
      'won': prefs.getInt('games_won') ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _stats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const {'xp': 0, 'played': 0, 'won': 0};
        final played = stats['played'] ?? 0;
        final won = stats['won'] ?? 0;
        final winRate = played == 0 ? 0 : ((won / played) * 100).round();
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
          children: [
            const Text('پروفایل بازیکن', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(26), border: Border.all(color: RadicalTheme.line)),
              child: Row(children: [
                _AvatarBadge(avatar: avatar, size: 82),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('بازیکن رادیکال', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text('سطح $level • XP ${stats['xp'] ?? 0}', style: const TextStyle(color: RadicalTheme.smoke)),
                  const SizedBox(height: 12),
                  ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: ((stats['xp'] ?? 0) % 1000) / 1000, minHeight: 8)),
                ])),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              _StatCard(title: 'بازی‌ها', value: '$played'),
              const SizedBox(width: 10),
              _StatCard(title: 'بردها', value: '$won'),
              const SizedBox(width: 10),
              _StatCard(title: 'نرخ برد', value: '$winRate%'),
            ]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: const Text('فریم شاهین برای این اکانت رزرو شده است. 🦅', style: TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w800))),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: RadicalTheme.line)),
        child: Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: RadicalTheme.goldBright)), const SizedBox(height: 4), Text(title, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11))]),
      ),
    );
  }
}

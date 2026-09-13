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
      _HomeTab(avatar: _avatar, level: _level, onPlay: _openLobby, onStore: () => setState(() => _tab = 1)),
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
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: animation.drive(Tween(begin: 0.96, end: 1.0)).drive(CurveTween(curve: Curves.easeOut))),
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

  const _HomeTab({required this.avatar, required this.level, required this.onPlay, required this.onStore});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        _Header(avatar: avatar, level: level, onStore: onStore),
        const SizedBox(height: 20),
        _HeroCard(onPlay: onPlay),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'دسترسی سریع', subtitle: 'همه چیز برای ورود به میز بازی'),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
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
    _AvatarBadge(avatar: avatar, size: 58),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('مافیا رادیکال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      SizedBox(height: 3),
      Text('اتاق عملیات • آماده‌ای؟', style: TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
    ])),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(color: RadicalTheme.panel2, borderRadius: BorderRadius.circular(14), border: Border.all(color: RadicalTheme.line)),
      child: Text('LV.$level', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900)),
    ),
    IconButton(onPressed: onStore, icon: const Icon(Icons.shopping_bag_outlined)),
  ]);
}

class _AvatarBadge extends StatelessWidget {
  final String avatar;
  final double size;
  const _AvatarBadge({required this.avatar, required this.size});

  String get role {
    switch (avatar) {
      case '🕴️': return 'مافیا';
      case '🕵️': return 'کارآگاه';
      case '🤡': return 'دلقک';
      case '🎩': return 'پدرخوانده';
      default: return 'شهروند';
    }
  }

  bool get female => avatar == '🕵️';

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(2.5),
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.crimson]), boxShadow: [BoxShadow(color: RadicalTheme.gold.withOpacity(.20), blurRadius: 18)]),
    child: RealisticAvatar(role: role, female: female, size: size - 5),
  );
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onPlay;
  const _HeroCard({required this.onPlay});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF3A202B), Color(0xFF171A24), Color(0xFF0E1118)], begin: Alignment.topRight, end: Alignment.bottomLeft), border: Border.all(color: RadicalTheme.gold.withOpacity(.24)), boxShadow: [BoxShadow(color: RadicalTheme.crimson.withOpacity(.10), blurRadius: 28, offset: const Offset(0, 10))]),
    child: Stack(children: [
      Positioned(top: -26, left: -18, child: Icon(Icons.auto_awesome, size: 110, color: RadicalTheme.gold.withOpacity(.055))),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.local_fire_department_rounded, color: RadicalTheme.crimsonBright, size: 18), SizedBox(width: 6), Text('فصل جدید مافیا', style: TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 12),
        const Text('وارد میز شو.\nنقشت را بازی کن.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.08)),
        const SizedBox(height: 9),
        const Text('بلوف بزن، متحد شو، رأی بده و آخرین بازمانده باش.', style: TextStyle(color: RadicalTheme.smoke, height: 1.4)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onPlay, icon: const Icon(Icons.play_arrow_rounded), label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('ورود به بازی', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
      ]),
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
  Widget build(BuildContext context) => Material(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: RadicalTheme.gold.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: RadicalTheme.goldBright, size: 27)), const SizedBox(height: 11), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12))]))));
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: const Row(children: [Icon(Icons.shield_outlined, color: RadicalTheme.goldBright, size: 34), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تجربه کامل رادیکال', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('سناریو، نقش‌ها، لابی، میز بازی، رأی‌گیری، پروفایل و فروشگاه؛ همه در یک هویت بصری.', style: TextStyle(color: RadicalTheme.smoke, height: 1.4, fontSize: 12))]))]));
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
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { coins = prefs.getInt('store_coins') ?? 120; owned.addAll(prefs.getStringList('owned_items') ?? <String>[]); });
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
    await prefs.setInt('store_coins', nextCoins);
    await prefs.setStringList('owned_items', <String>{...owned, id}.toList());
    if (id.startsWith('avatar_')) await prefs.setString('selected_avatar', avatar);
    if (!mounted) return;
    setState(() { coins = nextCoins; owned.add(id); });
    await widget.onChanged?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آیتم با موفقیت به کلکسیون اضافه شد ✅')));
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 30), children: [
    Row(children: [const Expanded(child: Text('فروشگاه رادیکال', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: RadicalTheme.panel2, borderRadius: BorderRadius.circular(16), border: Border.all(color: RadicalTheme.line)), child: Text('🪙 $coins', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900)))]),
    const SizedBox(height: 6),
    const Text('آواتار و فریم مورد علاقه‌ات را برای میز بازی انتخاب کن.', style: TextStyle(color: RadicalTheme.smoke)),
    const SizedBox(height: 20),
    for (final product in products) _ProductCard(product: product, owned: owned.contains(product.id), onBuy: () => buy(product.id, product.price, product.avatar)),
  ]);
}

class _ProductCard extends StatelessWidget {
  final ({String name, String id, String avatar, int price}) product;
  final bool owned;
  final VoidCallback onBuy;
  const _ProductCard({required this.product, required this.owned, required this.onBuy});

  String get role {
    switch (product.id) {
      case 'avatar_mafia': return 'مافیا';
      case 'avatar_detective': return 'کارآگاه';
      case 'avatar_clown': return 'دلقک';
      case 'avatar_boss': return 'پدرخوانده';
      default: return 'شهروند';
    }
  }

  bool get female => product.id == 'avatar_detective';

  @override
  Widget build(BuildContext context) {
    final isAvatar = product.id.startsWith('avatar_');
    final isPrivate = product.id == 'frame_falcon_private';
    return Card(color: RadicalTheme.panel, margin: const EdgeInsets.only(bottom: 12), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), leading: Container(width: 58, height: 58, padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.crimson]), boxShadow: [BoxShadow(color: RadicalTheme.gold.withOpacity(.14), blurRadius: 12)]), child: isAvatar ? RealisticAvatar(role: role, female: female, size: 53) : Center(child: Text(product.avatar, style: const TextStyle(fontSize: 25)))), title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(isPrivate ? 'رزرو خصوصی • $priceLabel 🪙' : '${product.price} 🪙 • آیتم ویژه', style: const TextStyle(color: RadicalTheme.smoke))), trailing: FilledButton(onPressed: isPrivate ? () => onBuy() : (owned ? null : onBuy), child: Text(isPrivate ? 'رزرو' : (owned ? 'دارم' : 'خرید'))));
  }

  String get priceLabel => '999,999,999';
}

class _ProfileTab extends StatefulWidget {
  final String avatar;
  final int level;
  final Future<void> Function() onChanged;
  const _ProfileTab({required this.avatar, required this.level, required this.onChanged});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  int xp = 0;
  int games = 0;
  int wins = 0;
  int coins = 120;
  Set<String> owned = <String>{};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      xp = prefs.getInt('player_xp') ?? 0;
      games = prefs.getInt('games_played') ?? 0;
      wins = prefs.getInt('games_won') ?? 0;
      coins = prefs.getInt('store_coins') ?? 120;
      owned = {...?prefs.getStringList('owned_items')};
    });
  }

  String get role {
    switch (widget.avatar) {
      case '🕴️': return 'مافیا';
      case '🕵️': return 'کارآگاه';
      case '🤡': return 'دلقک';
      case '🎩': return 'پدرخوانده';
      default: return 'شهروند';
    }
  }

  bool get female => widget.avatar == '🕵️';
  int get currentLevelXp => (widget.level - 1) * 100;
  double get progress => ((xp - currentLevelXp) / 100).clamp(0.0, 1.0);
  int get xpIntoLevel => (xp - currentLevelXp).clamp(0, 100);
  double get winRate => games == 0 ? 0 : (wins / games * 100);

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 20, 18, 30), children: [
    const Text('پروفایل بازیکن', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5),
    const Text('هویت، پیشرفت و کلکسیون رادیکال', style: TextStyle(color: RadicalTheme.smoke)),
    const SizedBox(height: 18),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF33232D), RadicalTheme.panel, Color(0xFF0D1017)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.circular(30), border: Border.all(color: RadicalTheme.gold.withOpacity(.22)), boxShadow: [BoxShadow(color: RadicalTheme.crimson.withOpacity(.10), blurRadius: 28, offset: const Offset(0, 12))]),
      child: Column(children: [
        Row(children: [
          Container(width: 104, height: 104, padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.crimson]), boxShadow: [BoxShadow(color: RadicalTheme.gold.withOpacity(.20), blurRadius: 25)]), child: RealisticAvatar(role: role, female: female, size: 96)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('بازیکن رادیکال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text('سطح ${widget.level} • $role', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(children: [Icon(Icons.monetization_on_rounded, size: 16, color: RadicalTheme.goldBright), const SizedBox(width: 5), Text('$coins سکه', style: const TextStyle(color: RadicalTheme.smoke))]),
          ])),
        ]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('XP ${xpIntoLevel}/100', style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('تا سطح بعد ${100 - xpIntoLevel}', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(minHeight: 10, value: progress, backgroundColor: Colors.white.withOpacity(.07), valueColor: const AlwaysStoppedAnimation(RadicalTheme.goldBright))),
      ]),
    ),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _StatTile(icon: Icons.sports_esports_rounded, value: '$games', label: 'بازی')),
      const SizedBox(width: 10),
      Expanded(child: _StatTile(icon: Icons.emoji_events_rounded, value: '$wins', label: 'برد')),
      const SizedBox(width: 10),
      Expanded(child: _StatTile(icon: Icons.percent_rounded, value: '${winRate.toStringAsFixed(0)}%', label: 'نرخ برد')),
    ]),
    const SizedBox(height: 18),
    const _SectionHeading(title: 'کلکسیون', subtitle: 'آیتم‌های بازشده و آماده استفاده'),
    const SizedBox(height: 10),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: Row(children: [
      _CollectionAvatar(role: role, female: female),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('آواتار فعال', style: TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('$role • انتخاب فعلی', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12))])),
      Text('${owned.length} آیتم', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w800)),
    ])),
    const SizedBox(height: 10),
    _ProfileCard(icon: Icons.emoji_events_rounded, title: 'رتبه فصل', value: wins == 0 ? 'تازه‌وارد • برای رتبه بازی کن' : 'بردهای ثبت‌شده: $wins', onTap: _loadStats),
    const SizedBox(height: 10),
    _ProfileCard(icon: Icons.inventory_2_outlined, title: 'کلکسیون', value: '${owned.length} آیتم روی این دستگاه ذخیره شده', onTap: _loadStats),
    const SizedBox(height: 10),
    _ProfileCard(icon: Icons.sync_rounded, title: 'همگام‌سازی', value: 'اطلاعات خرید و پیشرفت روی همین دستگاه ذخیره می‌شود', onTap: _loadStats),
  ]);
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: RadicalTheme.line)), child: Column(children: [Icon(icon, color: RadicalTheme.goldBright, size: 21), const SizedBox(height: 7), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11))]));
}

class _CollectionAvatar extends StatelessWidget {
  final String role;
  final bool female;
  const _CollectionAvatar({required this.role, required this.female});
  @override
  Widget build(BuildContext context) => Container(width: 58, height: 58, padding: const EdgeInsets.all(2.5), decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.crimson])), child: RealisticAvatar(role: role, female: female, size: 53));
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Future<void> Function()? onTap;
  const _ProfileCard({required this.icon, required this.title, required this.value, this.onTap});
  @override
  Widget build(BuildContext context) => Card(color: RadicalTheme.panel, child: ListTile(leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: RadicalTheme.gold.withOpacity(.09), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: RadicalTheme.goldBright)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(value, style: const TextStyle(color: RadicalTheme.smoke))), trailing: onTap == null ? null : IconButton(icon: const Icon(Icons.sync_rounded), onPressed: onTap)));
}

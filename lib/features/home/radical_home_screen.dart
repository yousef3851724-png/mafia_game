import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/radical_theme.dart';
import '../../core/widgets/branding/game_logo_widget.dart';
import '../scenarios/realistic_avatar.dart';
import '../scenarios/scenario_lobby_screen.dart';

class RadicalHomeScreen extends StatefulWidget {
  const RadicalHomeScreen({super.key});

  @override
  State<RadicalHomeScreen> createState() => _RadicalHomeScreenState();
}

class _RadicalHomeScreenState extends State<RadicalHomeScreen> {
  int _tab = 0;
  String _avatar = 'شهروند مرد';
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
      _avatar = prefs.getString('selected_avatar') ?? 'شهروند مرد';
      _level = prefs.getInt('player_level') ?? 1;
    });
  }

  void _openLobby() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator')),
    );
  }

  Future<void> _openAvatars() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AvatarSelectionScreen(selected: _avatar)),
    );
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(avatar: _avatar, level: _level, onPlay: _openLobby, onAvatars: _openAvatars, onStore: () => setState(() => _tab = 1)),
      RadicalStoreScreen(onChanged: _loadProfile, onAvatars: _openAvatars),
      _ProfileTab(avatar: _avatar, level: _level, onChanged: _loadProfile, onAvatars: _openAvatars),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: pages[_tab])),
        bottomNavigationBar: NavigationBar(
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
  final VoidCallback onAvatars;
  final VoidCallback onStore;

  const _HomeTab({required this.avatar, required this.level, required this.onPlay, required this.onAvatars, required this.onStore});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
      children: [
        Row(children: [
          GestureDetector(onTap: onAvatars, child: _AvatarBadge(avatar: avatar, size: 60)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مافیا رادیکال', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('اتاق عملیات • انتخاب کن و وارد شو', style: TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
          ])),
          _LevelBadge(level: level),
        ]),
        const SizedBox(height: 16),
        const Center(child: MafiaRadicalLogo(size: 104)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(colors: [Color(0xFF3D1822), Color(0xFF18151E), Color(0xFF0D1017)], begin: Alignment.topRight, end: Alignment.bottomLeft),
            border: Border.all(color: RadicalTheme.gold.withOpacity(.32)),
            boxShadow: [BoxShadow(color: RadicalTheme.crimson.withOpacity(.13), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.local_fire_department_rounded, color: RadicalTheme.crimsonBright), SizedBox(width: 7), Text('فصل جدید • رادیکال', style: TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 12),
            const Text('وارد میز شو.\nنقشت را بازی کن.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.05)),
            const SizedBox(height: 9),
            const Text('بلوف بزن، متحد شو، رأی بده و آخرین بازمانده باش.', style: TextStyle(color: RadicalTheme.smoke, height: 1.45)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onPlay, icon: const Icon(Icons.play_arrow_rounded), label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('ورود به بازی')))),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('دسترسی سریع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('هویت، آواتار و میز بازی در چند لمس', style: TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
          children: [
            _ActionCard(icon: Icons.groups_rounded, title: 'شروع بازی', subtitle: 'سناریو و لابی', onTap: onPlay),
            _ActionCard(icon: Icons.face_retouching_natural_rounded, title: 'آواتارها', subtitle: 'مرد، زن و خاص', onTap: onAvatars),
            _ActionCard(icon: Icons.storefront_rounded, title: 'فروشگاه', subtitle: 'آواتار و فریم', onTap: onStore),
            _ActionCard(icon: Icons.auto_awesome_rounded, title: 'سناریوها', subtitle: 'کلاسیک و رادیکال', onTap: onPlay),
          ],
        ),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(17), decoration: RadicalTheme.glass(accent: true), child: const Row(children: [Icon(Icons.shield_moon_rounded, color: RadicalTheme.goldBright, size: 32), SizedBox(width: 12), Expanded(child: Text('یک هویت بصری واحد برای خانه، لابی، میز بازی، رأی‌گیری، فروشگاه و پروفایل.', style: TextStyle(color: RadicalTheme.smoke, height: 1.45, fontSize: 12)))])),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: RadicalTheme.panel2, borderRadius: BorderRadius.circular(15), border: Border.all(color: RadicalTheme.line)), child: Text('LV.$level', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900)));
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: RadicalTheme.gold.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: RadicalTheme.goldBright, size: 27)), const SizedBox(height: 11), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12))]))));
}

class _AvatarBadge extends StatelessWidget {
  final String avatar; final double size;
  const _AvatarBadge({required this.avatar, required this.size});
  String get role => avatar.contains('دلقک') ? 'دلقک' : avatar.contains('جوکر') ? 'جوکر' : avatar.contains('قاتل') ? 'قاتل مستقل' : avatar.contains('زامبی') ? 'زامبی' : avatar.contains('مافیا') ? 'مافیا' : avatar.contains('پدر') ? 'پدرخوانده' : avatar.contains('دکتر') ? 'دکتر' : avatar.contains('کارآگاه') ? 'کارآگاه' : 'شهروند';
  bool get female => avatar.contains('زن') || avatar.contains('دختر');
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, padding: const EdgeInsets.all(2.5), decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.crimson]), boxShadow: [BoxShadow(color: RadicalTheme.gold.withOpacity(.20), blurRadius: 18)]), child: RealisticAvatar(role: role, female: female, size: size - 5));
}

class AvatarSelectionScreen extends StatefulWidget {
  final String selected;
  const AvatarSelectionScreen({super.key, required this.selected});
  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late String selected;
  static const avatars = <String>['شهروند مرد', 'شهروند زن', 'مافیا مرد', 'مافیا زن', 'کارآگاه زن', 'دکتر مرد', 'پدرخوانده مرد', 'دلقک', 'جوکر', 'قاتل مستقل', 'زامبی'];
  @override
  void initState() { super.initState(); selected = widget.selected; }
  Future<void> _select(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', value);
    if (!mounted) return;
    setState(() => selected = value);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آواتار انتخاب شد ✅')));
  }
  String role(String value) => value.contains('دلقک') ? 'دلقک' : value.contains('جوکر') ? 'جوکر' : value.contains('قاتل') ? 'قاتل مستقل' : value.contains('زامبی') ? 'زامبی' : value.contains('مافیا') ? 'مافیا' : value.contains('پدر') ? 'پدرخوانده' : value.contains('دکتر') ? 'دکتر' : value.contains('کارآگاه') ? 'کارآگاه' : 'شهروند';
  bool isFemale(String value) => value.contains('زن');
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: RadicalTheme.ink, appBar: AppBar(title: const Text('انتخاب آواتار', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.check_rounded))]), body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [Container(padding: const EdgeInsets.all(18), decoration: RadicalTheme.glass(accent: true), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('هویتت را انتخاب کن', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('آواتارهای مرد و زن به‌همراه شخصیت‌های ویژه برای میز بازی.', style: TextStyle(color: RadicalTheme.smoke, height: 1.4))])), const SizedBox(height: 18), GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .88), itemCount: avatars.length, itemBuilder: (_, i) { final value = avatars[i]; final active = value == selected; return InkWell(onTap: () => _select(value), borderRadius: BorderRadius.circular(24), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: active ? const Color(0xFF2A211A) : RadicalTheme.panel, borderRadius: BorderRadius.circular(24), border: Border.all(color: active ? RadicalTheme.goldBright : RadicalTheme.line, width: active ? 1.6 : 1)), child: Column(children: [Expanded(child: RealisticAvatar(role: role(value), female: isFemale(value), size: 104)), const SizedBox(height: 8), Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: active ? RadicalTheme.goldBright : Colors.white)), const SizedBox(height: 4), if (active) const Icon(Icons.check_circle_rounded, color: RadicalTheme.goldBright, size: 20) else const SizedBox(height: 20)]))); })]));
}

class RadicalStoreScreen extends StatelessWidget {
  final Future<void> Function()? onChanged; final VoidCallback onAvatars;
  const RadicalStoreScreen({super.key, this.onChanged, required this.onAvatars});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 30), children: [const Text('فروشگاه رادیکال', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('آواتار، فریم و ظاهر شخصیتت را شخصی‌سازی کن.', style: TextStyle(color: RadicalTheme.smoke)), const SizedBox(height: 18), InkWell(onTap: onAvatars, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(17), decoration: RadicalTheme.glass(accent: true), child: const Row(children: [Icon(Icons.face_retouching_natural_rounded, color: RadicalTheme.goldBright, size: 36), SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('گالری کامل آواتارها', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('مرد، زن، مافیا، دکتر، دلقک، جوکر و شخصیت‌های ویژه', style: TextStyle(color: RadicalTheme.smoke, fontSize: 12))])), Icon(Icons.chevron_left_rounded, color: RadicalTheme.goldBright)])), const SizedBox(height: 14), _StoreInfo(title: 'فریم طلایی', icon: Icons.workspace_premium_rounded, text: 'فریم ویژه با درخشش طلایی برای پروفایل و میز بازی.'), _StoreInfo(title: 'فریم شب خونین', icon: Icons.nights_stay_rounded, text: 'ظاهر تاریک و قرمز برای شخصیت‌های خاص.'), _StoreInfo(title: 'کلکسیون رادیکال', icon: Icons.auto_awesome_rounded, text: 'سیستم ظاهری از همین‌جا در نسخه‌های بعدی گسترش پیدا می‌کند.')]);
}

class _StoreInfo extends StatelessWidget { final String title; final IconData icon; final String text; const _StoreInfo({required this.title, required this.icon, required this.text}); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: RadicalTheme.gold.withOpacity(.10), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: RadicalTheme.goldBright)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(text, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12, height: 1.35))]))])); }

class _ProfileTab extends StatelessWidget {
  final String avatar; final int level; final Future<void> Function() onChanged; final VoidCallback onAvatars;
  const _ProfileTab({required this.avatar, required this.level, required this.onChanged, required this.onAvatars});
  Future<Map<String, int>> _stats() async { final prefs = await SharedPreferences.getInstance(); return {'xp': prefs.getInt('player_xp') ?? 0, 'played': prefs.getInt('games_played') ?? 0, 'won': prefs.getInt('games_won') ?? 0}; }
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, int>>(future: _stats(), builder: (_, snap) { final s = snap.data ?? const {'xp': 0, 'played': 0, 'won': 0}; final played = s['played'] ?? 0; final won = s['won'] ?? 0; final rate = played == 0 ? 0 : ((won / played) * 100).round(); return ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 30), children: [const Text('پروفایل بازیکن', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(20), decoration: RadicalTheme.glass(accent: true), child: Column(children: [_AvatarBadge(avatar: avatar, size: 112), const SizedBox(height: 12), const Text('بازیکن رادیکال', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('سطح $level • XP ${s['xp'] ?? 0}', style: const TextStyle(color: RadicalTheme.smoke)), const SizedBox(height: 16), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onAvatars, icon: const Icon(Icons.face_retouching_natural_rounded), label: const Text('تغییر آواتار')))])), const SizedBox(height: 14), Row(children: [_StatCard(title: 'بازی‌ها', value: '$played'), const SizedBox(width: 10), _StatCard(title: 'بردها', value: '$won'), const SizedBox(width: 10), _StatCard(title: 'نرخ برد', value: '$rate%')]), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('هویت بصری رادیکال', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 7), Text('لوگو، رنگ طلایی/قرمز، کارت‌های شیشه‌ای، آواتارهای برداری و شخصیت‌های ویژه در کل رابط استفاده می‌شوند.', style: TextStyle(color: RadicalTheme.smoke, height: 1.45, fontSize: 12)), SizedBox(height: 12), Text('فریم شاهین برای این اکانت رزرو شده است. 🦅', style: TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w800))]))]); });
}

class _StatCard extends StatelessWidget { final String title; final String value; const _StatCard({required this.title, required this.value}); @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: RadicalTheme.line)), child: Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: RadicalTheme.goldBright)), const SizedBox(height: 4), Text(title, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11))]))); }

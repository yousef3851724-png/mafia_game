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
      MaterialPageRoute(
        builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator'),
      ),
    );
  }

  void _openAvatars() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvatarSelectionScreen(
          selected: _avatar,
          onChanged: _loadProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(
        avatar: _avatar,
        level: _level,
        onStart: _openLobby,
      ),
      _LobbyTab(onStart: _openLobby),
      const _StoreTab(),
      _ProfileTab(
        avatar: _avatar,
        level: _level,
        onAvatars: _openAvatars,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[_tab],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (value) => setState(() => _tab = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'خانه',
            ),
            NavigationDestination(
              icon: Icon(Icons.table_restaurant_outlined),
              selectedIcon: Icon(Icons.table_restaurant_rounded),
              label: 'بازی',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'فروشگاه',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'پروفایل',
            ),
          ],
        ),
      ),
    );
  }
}

String avatarRole(String value) {
  if (value.contains('دلقک')) return 'دلقک';
  if (value.contains('جوکر')) return 'جوکر';
  if (value.contains('قاتل')) return 'قاتل مستقل';
  if (value.contains('زامبی')) return 'زامبی';
  if (value.contains('مافیا')) return 'مافیا';
  if (value.contains('پدر')) return 'پدرخوانده';
  if (value.contains('دکتر')) return 'دکتر';
  if (value.contains('کارآگاه')) return 'کارآگاه';
  return 'شهروند';
}

class _HomeTab extends StatelessWidget {
  final String avatar;
  final int level;
  final VoidCallback onStart;

  const _HomeTab({
    required this.avatar,
    required this.level,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'مافیا رادیکال',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'شب شروع می‌شود؛ اعتماد تمام می‌شود.',
                    style: TextStyle(color: RadicalTheme.smoke),
                  ),
                ],
              ),
            ),
            RealisticAvatar(
              role: avatarRole(avatar),
              female: avatar.contains('زن'),
              size: 58,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: RadicalTheme.glass(accent: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'میز رادیکال آماده است',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              const Text(
                'سناریو را انتخاب کن، بازیکن‌ها را بچین و وارد یک تجربه‌ی سینمایی شو.',
                style: TextStyle(color: RadicalTheme.smoke, height: 1.45),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('شروع بازی'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                icon: Icons.workspace_premium_rounded,
                title: 'سطح',
                value: '$level',
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: _MiniCard(
                icon: Icons.groups_rounded,
                title: 'میز',
                value: 'آماده',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: RadicalTheme.panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: RadicalTheme.line),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ویژگی‌های رادیکال',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              SizedBox(height: 10),
              Text('🎭 آواتارهای نقش‌محور', style: TextStyle(color: RadicalTheme.smoke)),
              SizedBox(height: 6),
              Text('🌙 فازهای شب و روز', style: TextStyle(color: RadicalTheme.smoke)),
              SizedBox(height: 6),
              Text('🏆 برد و پایان سینمایی', style: TextStyle(color: RadicalTheme.smoke)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LobbyTab extends StatelessWidget {
  final VoidCallback onStart;

  const _LobbyTab({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.table_restaurant_rounded,
              size: 70,
              color: RadicalTheme.goldBright,
            ),
            const SizedBox(height: 14),
            const Text(
              'لابی بازی',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'سناریو و تعداد بازیکن‌ها را انتخاب کن.',
              textAlign: TextAlign.center,
              style: TextStyle(color: RadicalTheme.smoke),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('ساخت لابی'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreTab extends StatelessWidget {
  const _StoreTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        Text(
          'فروشگاه رادیکال',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 8),
        Text(
          'ظاهر شخصیتت را شخصی‌سازی کن.',
          style: TextStyle(color: RadicalTheme.smoke),
        ),
        SizedBox(height: 20),
        _StoreInfo(
          title: 'فریم طلایی',
          icon: Icons.workspace_premium_rounded,
          text: 'فریم ویژه با درخشش طلایی برای پروفایل و میز بازی.',
        ),
        _StoreInfo(
          title: 'شب خونین',
          icon: Icons.nights_stay_rounded,
          text: 'ظاهر تاریک و قرمز برای شخصیت‌های خاص.',
        ),
        _StoreInfo(
          title: 'کلکسیون رادیکال',
          icon: Icons.auto_awesome_rounded,
          text: 'سیستم ظاهری در نسخه‌های بعدی گسترش پیدا می‌کند.',
        ),
      ],
    );
  }
}

class AvatarSelectionScreen extends StatefulWidget {
  final String selected;
  final Future<void> Function()? onChanged;

  const AvatarSelectionScreen({
    super.key,
    required this.selected,
    this.onChanged,
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late String selected;

  static const avatars = <String>[
    'شهروند مرد',
    'شهروند زن',
    'مافیا مرد',
    'مافیا زن',
    'کارآگاه زن',
    'دکتر مرد',
    'پدرخوانده مرد',
    'دلقک',
    'جوکر',
    'قاتل مستقل',
    'زامبی',
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  Future<void> _select(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', value);
    if (!mounted) return;
    setState(() => selected = value);
    await widget.onChanged?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('آواتار انتخاب شد ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        appBar: AppBar(
          title: const Text(
            'انتخاب آواتار',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(18),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .84,
          ),
          itemCount: avatars.length,
          itemBuilder: (_, index) {
            final value = avatars[index];
            final active = value == selected;
            return InkWell(
              onTap: () => _select(value),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF2A211A) : RadicalTheme.panel,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: active ? RadicalTheme.goldBright : RadicalTheme.line,
                    width: active ? 1.7 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: RealisticAvatar(
                        role: avatarRole(value),
                        female: value.contains('زن'),
                        size: 104,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: active ? RadicalTheme.goldBright : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Icon(
                      active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: active ? RadicalTheme.goldBright : RadicalTheme.smoke,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String avatar;
  final int level;
  final VoidCallback onAvatars;

  const _ProfileTab({
    required this.avatar,
    required this.level,
    required this.onAvatars,
  });

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
      builder: (_, snapshot) {
        final stats = snapshot.data ?? const <String, int>{};
        final played = stats['played'] ?? 0;
        final won = stats['won'] ?? 0;
        final rate = played == 0 ? 0 : ((won / played) * 100).round();

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
          children: [
            const Text(
              'پروفایل بازیکن',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: RadicalTheme.glass(accent: true),
              child: Column(
                children: [
                  RealisticAvatar(
                    role: avatarRole(avatar),
                    female: avatar.contains('زن'),
                    size: 112,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'بازیکن رادیکال',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سطح $level • XP ${stats['xp'] ?? 0}',
                    style: const TextStyle(color: RadicalTheme.smoke),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAvatars,
                      icon: const Icon(Icons.face_retouching_natural_rounded),
                      label: const Text('تغییر آواتار'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatCard(title: 'بازی‌ها', value: '$played'),
                const SizedBox(width: 10),
                _StatCard(title: 'بردها', value: '$won'),
                const SizedBox(width: 10),
                _StatCard(title: 'نرخ برد', value: '$rate%'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: RadicalTheme.panel,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: RadicalTheme.line),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'هویت بصری رادیکال',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'لوگو، طلایی/قرمز، کارت‌های شیشه‌ای و آواتارهای نقش‌محور.',
                    style: TextStyle(color: RadicalTheme.smoke, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RadicalTheme.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: RadicalTheme.goldBright),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: RadicalTheme.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: RadicalTheme.line),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: RadicalTheme.goldBright,
              ),
            ),
            const SizedBox(height: 3),
            Text(title, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _StoreInfo extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;

  const _StoreInfo({
    required this.title,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RadicalTheme.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: RadicalTheme.gold.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: RadicalTheme.goldBright),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

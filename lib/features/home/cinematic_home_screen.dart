import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../../core/widgets/branding/game_logo_widget.dart';
import '../lobbies/lobby_hub_screen.dart';
import '../profile/profile_screen.dart';
import '../store/store_screen.dart';
import 'classes_screen.dart';

class CinematicHomeScreen extends StatefulWidget {
  const CinematicHomeScreen({super.key});

  @override
  State<CinematicHomeScreen> createState() => _CinematicHomeScreenState();
}

class _CinematicHomeScreenState extends State<CinematicHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selected = 0;
  int _scenario = 0;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openScenarios() => _open(const ClassesScreen());
  void _openRanked() => _open(const LobbyHubScreen(ownerId: 'local_creator'));
  void _openStore() => _open(const const StoreScreen());
  void _openProfile() => _open(const ProfileScreen());

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomePage(
        scenario: _scenario,
        onScenarioChanged: (value) => setState(() => _scenario = value),
        onStart: _openScenarios,
        onStore: _openStore,
        onRanked: _openRanked,
        onScenarios: _openScenarios,
        onProfile: _openProfile,
      ),
      _ModePage(
        title: 'رقابتی',
        subtitle: 'رنک، امتیاز و رقابت جدی روی میز رادیکال.',
        icon: Icons.emoji_events_rounded,
        accent: RadicalTheme.violet,
        actionLabel: 'ورود به بازی رقابتی',
        onAction: _openRanked,
      ),
      const const StoreScreen(),
      const ProfileScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: Stack(
          children: [
            Positioned.fill(child: _ParticleField(animation: _ambient)),
            SafeArea(
              child: IndexedStack(index: _selected, children: pages),
            ),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          selected: _selected,
          onChanged: (value) => setState(() => _selected = value),
        ),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  final int scenario;
  final ValueChanged<int> onScenarioChanged;
  final VoidCallback onStart;
  final VoidCallback onStore;
  final VoidCallback onRanked;
  final VoidCallback onScenarios;
  final VoidCallback onProfile;

  const _HomePage({
    required this.scenario,
    required this.onScenarioChanged,
    required this.onStart,
    required this.onStore,
    required this.onRanked,
    required this.onScenarios,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 24),
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: _DiamondBadge(),
        ),
        const SizedBox(height: 34),
        const Center(
          child: MafiaRadicalLogo(
            size: 150,
            scenario: MafiaLogoScenario.classic,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'مافیا رادیکال',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RadicalTheme.goldBright,
            fontSize: 31,
            height: 1.05,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: Color(0x66E3B873), blurRadius: 18),
            ],
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'شب، راز، رأی و یک میز که هیچ‌کس در آن امن نیست.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RadicalTheme.smoke,
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 25),
        _PrimaryButton(onPressed: onStart),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'دسترسی سریع',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.52,
          children: [
            _QuickTile(
              icon: Icons.storefront_rounded,
              title: 'فروشگاه',
              subtitle: 'آواتار و آیتم',
              accent: RadicalTheme.goldBright,
              onTap: onStore,
            ),
            _QuickTile(
              icon: Icons.emoji_events_rounded,
              title: 'رقابتی',
              subtitle: 'امتیاز و رتبه',
              accent: RadicalTheme.violet,
              onTap: onRanked,
            ),
            _QuickTile(
              icon: Icons.auto_awesome_rounded,
              title: 'سناریوها',
              subtitle: 'بازی‌های بیشتر',
              accent: RadicalTheme.violet,
              onTap: onScenarios,
            ),
            _QuickTile(
              icon: Icons.person_rounded,
              title: 'پروفایل',
              subtitle: 'هویت بازیکن',
              accent: RadicalTheme.goldBright,
              onTap: onProfile,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ScenarioPreview(selected: scenario, onChanged: onScenarioChanged),
      ],
    );
  }
}

class _DiamondBadge extends StatelessWidget {
  const _DiamondBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: RadicalTheme.panel2,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '100',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(width: 7),
          Icon(Icons.diamond_rounded, color: RadicalTheme.goldBright, size: 19),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _PrimaryButton({required this.onPressed});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? .975 : 1,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _down = value),
          borderRadius: BorderRadius.circular(23),
          splashColor: RadicalTheme.goldBright.withValues(alpha: .28),
          child: Ink(
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [RadicalTheme.goldBright, RadicalTheme.gold],
              ),
              borderRadius: BorderRadius.circular(23),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55E3B873),
                  blurRadius: 28,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'شروع بازی / ورود به میز',
                  style: TextStyle(
                    color: RadicalTheme.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 11),
                Icon(Icons.play_arrow_rounded, color: RadicalTheme.ink, size: 29),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_QuickTile> createState() => _QuickTileState();
}

class _QuickTileState extends State<_QuickTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? .97 : 1,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _down = value),
          borderRadius: BorderRadius.circular(21),
          splashColor: widget.accent.withValues(alpha: .18),
          child: Ink(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: RadicalTheme.panel,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: widget.accent.withValues(alpha: .18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.accent, size: 24),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: RadicalTheme.smoke,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScenarioPreview extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _ScenarioPreview({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('تکاور', '۱۰ نفر • امتیازی', Icons.style_rounded),
      ('مذاکره', '۱۰ نفر • مدرن', Icons.auto_awesome_rounded),
      ('سناریوی دست‌ساز', '۵۰ 💎 • دوستانه', Icons.edit_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'سناریوی سریع',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 11),
        ...items.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(bottom: entry.key == 2 ? 0 : 9),
            child: _ScenarioRow(
              title: entry.value.$1,
              subtitle: entry.value.$2,
              icon: entry.value.$3,
              selected: selected == entry.key,
              onTap: () => onChanged(entry.key),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ScenarioRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        splashColor: RadicalTheme.goldBright.withValues(alpha: .12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF211B13) : RadicalTheme.panel,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? RadicalTheme.gold.withValues(alpha: .55)
                  : RadicalTheme.line,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke,
                size: 21,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.chevron_left_rounded,
                color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String actionLabel;
  final VoidCallback onAction;

  const _ModePage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      children: [
        const SizedBox(height: 20),
        const Center(child: MafiaRadicalLogo(size: 110)),
        const SizedBox(height: 20),
        Icon(icon, size: 52, color: accent),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: accent, fontSize: 29, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: RadicalTheme.smoke, height: 1.5),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: RadicalTheme.glass(accent: true),
          child: Column(
            children: [
              const Text('میز رادیکال آماده است', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'سناریو، بازیکن‌ها و جریان بازی را از همین بخش کنترل کن.',
                textAlign: TextAlign.center,
                style: TextStyle(color: RadicalTheme.smoke),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'خانه'),
      (Icons.emoji_events_rounded, 'رقابتی'),
      (Icons.storefront_rounded, 'فروشگاه'),
      (Icons.person_rounded, 'پروفایل'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
      decoration: const BoxDecoration(
        color: Color(0xF0090C12),
        border: Border(top: BorderSide(color: RadicalTheme.line)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavItem(
                icon: items[i].$1,
                label: items[i].$2,
                selected: selected == i,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      splashColor: RadicalTheme.goldBright.withValues(alpha: .14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? RadicalTheme.gold.withValues(alpha: .10) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticleField extends StatelessWidget {
  final Animation<double> animation;
  const _ParticleField({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(animation.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = RadicalTheme.gold.withValues(alpha: .055);
    for (var i = 0; i < 26; i++) {
      final seed = i * 37.0;
      final x = (seed * 13.0) % size.width;
      final baseY = (seed * 7.0) % size.height;
      final y = (baseY - progress * (size.height + 40)) % (size.height + 40);
      canvas.drawCircle(Offset(x, y), .8 + (i % 3) * .55, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}

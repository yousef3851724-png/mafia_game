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

  void _openFriendly() => _open(const ClassesScreen());
  void _openRanked() => _open(const LobbyHubScreen(ownerId: 'local_creator'));
  void _openStore() => _open(const StoreScreen());
  void _openProfile() => _open(const ProfileScreen());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: Stack(
          children: [
            Positioned.fill(child: _ParticleField(animation: _ambient)),
            SafeArea(
              child: IndexedStack(
                index: _selected,
                children: [
                  _HomePage(
                    ambient: _ambient,
                    scenario: _scenario,
                    onScenarioChanged: (value) => setState(() => _scenario = value),
                    onStart: _openFriendly,
                    onStore: _openStore,
                    onRanked: _openRanked,
                    onFriendly: _openFriendly,
                    onProfile: _openProfile,
                  ),
                  const StoreScreen(),
                  _ModePage(
                    title: 'بازی امتیازی',
                    subtitle: 'رنک، امتیاز و رقابت جدی روی میز رادیکال.',
                    icon: Icons.emoji_events_rounded,
                    accent: RadicalTheme.crimsonBright,
                    actionLabel: 'ورود به بازی امتیازی',
                    onAction: _openRanked,
                  ),
                  _ModePage(
                    title: 'بازی دوستانه',
                    subtitle: 'لابی بساز، دوستانت را جمع کن و بدون فشار رتبه بازی کن.',
                    icon: Icons.groups_rounded,
                    accent: RadicalTheme.goldBright,
                    actionLabel: 'ورود به بازی دوستانه',
                    onAction: _openFriendly,
                  ),
                  const ProfileScreen(),
                ],
              ),
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
  final Animation<double> ambient;
  final int scenario;
  final ValueChanged<int> onScenarioChanged;
  final VoidCallback onStart;
  final VoidCallback onStore;
  final VoidCallback onRanked;
  final VoidCallback onFriendly;
  final VoidCallback onProfile;

  const _HomePage({
    required this.ambient,
    required this.scenario,
    required this.onScenarioChanged,
    required this.onStart,
    required this.onStore,
    required this.onRanked,
    required this.onFriendly,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Align(alignment: Alignment.topLeft, child: _DiamondBadge()),
        const SizedBox(height: 8),
        const Center(
          child: MafiaRadicalLogo(
            size: 126,
            scenario: MafiaLogoScenario.classic,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'مافیا رادیکال',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RadicalTheme.goldBright,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Color(0x66E3B873), blurRadius: 18)],
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'شب، راز، رأی و یک میز که هیچ‌کس در آن امن نیست.',
          textAlign: TextAlign.center,
          style: TextStyle(color: RadicalTheme.smoke, fontSize: 12.5),
        ),
        const SizedBox(height: 22),
        _AnimatedCard(
          delay: 0,
          child: _PrimaryButton(onPressed: onStart),
        ),
        const SizedBox(height: 18),
        const Text(
          'دسترسی سریع',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.62,
          children: [
            _QuickTile(
              icon: Icons.storefront_rounded,
              title: 'فروشگاه',
              subtitle: 'آواتار و آیتم',
              accent: RadicalTheme.gold,
              onTap: onStore,
            ),
            _QuickTile(
              icon: Icons.emoji_events_rounded,
              title: 'امتیازی',
              subtitle: 'امتیاز و رتبه',
              accent: RadicalTheme.crimsonBright,
              onTap: onRanked,
            ),
            _QuickTile(
              icon: Icons.groups_rounded,
              title: 'دوستانه',
              subtitle: 'لابی و بازی آزاد',
              accent: RadicalTheme.violet,
              onTap: onFriendly,
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
        const SizedBox(height: 18),
        _AnimatedCard(
          delay: 180,
          child: _ScenarioPreview(
            selected: scenario,
            onChanged: onScenarioChanged,
          ),
        ),
      ],
    );
  }
}

class _DiamondBadge extends StatelessWidget {
  const _DiamondBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RadicalTheme.panel2,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, color: RadicalTheme.goldBright, size: 18),
          SizedBox(width: 6),
          Text('100', style: TextStyle(fontWeight: FontWeight.w900)),
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
      scale: _down ? .965 : 1,
      duration: const Duration(milliseconds: 110),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _down = value),
          borderRadius: BorderRadius.circular(20),
          splashColor: RadicalTheme.goldBright.withValues(alpha: .30),
          highlightColor: RadicalTheme.gold.withValues(alpha: .12),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [RadicalTheme.goldBright, RadicalTheme.gold],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55E3B873),
                  blurRadius: 30,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: RadicalTheme.ink, size: 27),
                SizedBox(width: 9),
                Text(
                  'شروع بازی / ورود به میز',
                  style: TextStyle(
                    color: RadicalTheme.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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
      scale: _down ? .965 : 1,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(19),
          splashColor: widget.accent.withValues(alpha: .18),
          highlightColor: widget.accent.withValues(alpha: .06),
          onHighlightChanged: (value) => setState(() => _down = value),
          child: Ink(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: RadicalTheme.panel,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: widget.accent.withValues(alpha: .18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(widget.icon, color: widget.accent, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(widget.subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 10.5)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: RadicalTheme.smoke, size: 18),
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
        const Text('سناریوی سریع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        ...items.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(bottom: entry.key == 2 ? 0 : 8),
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
  const _ScenarioRow({required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: RadicalTheme.goldBright.withValues(alpha: .12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF211B13) : RadicalTheme.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? RadicalTheme.gold.withValues(alpha: .55) : RadicalTheme.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 10.5)),
                  ],
                ),
              ),
              Icon(selected ? Icons.check_circle_rounded : Icons.chevron_left_rounded, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke, size: 19),
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
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 28),
      children: [
        const Center(child: MafiaRadicalLogo(size: 92, scenario: MafiaLogoScenario.classic)),
        const SizedBox(height: 18),
        Icon(icon, size: 54, color: accent),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: RadicalTheme.smoke, height: 1.5)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: RadicalTheme.glass(accent: true),
          child: Column(
            children: [
              const Text('میز رادیکال آماده است', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('سناریو، بازیکن‌ها و جریان بازی را از همین بخش کنترل کن.', textAlign: TextAlign.center, style: TextStyle(color: RadicalTheme.smoke)),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.play_arrow_rounded), label: Text(actionLabel))),
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
      (Icons.home_rounded, 'صفحه اصلی'),
      (Icons.storefront_rounded, 'فروشگاه'),
      (Icons.emoji_events_rounded, 'امتیازی'),
      (Icons.groups_rounded, 'دوستانه'),
      (Icons.person_rounded, 'پروفایل'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
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
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: RadicalTheme.goldBright.withValues(alpha: .14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? RadicalTheme.gold.withValues(alpha: .10) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke)),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedCard({required this.child, required this.delay});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .12), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        child: widget.child,
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
      builder: (_, __) => CustomPaint(painter: _ParticlePainter(animation.value), size: Size.infinite),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = RadicalTheme.gold.withValues(alpha: .065);
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

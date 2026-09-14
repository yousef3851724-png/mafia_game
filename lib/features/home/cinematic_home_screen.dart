import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../../core/widgets/branding/game_logo_widget.dart';
import '../scenarios/scenario_lobby_screen.dart';

class CinematicHomeScreen extends StatefulWidget {
  const CinematicHomeScreen({super.key});

  @override
  State<CinematicHomeScreen> createState() => _CinematicHomeScreenState();
}

class _CinematicHomeScreenState extends State<CinematicHomeScreen> with SingleTickerProviderStateMixin {
  int _selected = 0;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  void _openLobby() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator')));
  }

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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        const Spacer(),
                        _DiamondBadge(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        const SizedBox(height: 4),
                        const Center(child: MafiaRadicalLogo(size: 126, scenario: MafiaLogoScenario.classic)),
                        const SizedBox(height: 12),
                        const Text('مافیا رادیکال', textAlign: TextAlign.center, style: TextStyle(color: RadicalTheme.goldBright, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                        const SizedBox(height: 5),
                        const Text('شب، راز، رأی و یک میز که هیچ‌کس در آن امن نیست.', textAlign: TextAlign.center, style: TextStyle(color: RadicalTheme.smoke, fontSize: 12.5, height: 1.45)),
                        const SizedBox(height: 22),
                        _AnimatedCard(
                          delay: 0,
                          child: _PrimaryButton(onPressed: _openLobby),
                        ),
                        const SizedBox(height: 18),
                        const Text('دسترسی سریع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.62,
                          children: const [
                            _QuickTile(icon: Icons.storefront_rounded, title: 'فروشگاه', subtitle: 'آواتار و آیتم', accent: RadicalTheme.gold),
                            _QuickTile(icon: Icons.emoji_events_rounded, title: 'رقابتی', subtitle: 'امتیاز و رتبه', accent: RadicalTheme.crimsonBright),
                            _QuickTile(icon: Icons.auto_awesome_rounded, title: 'سناریوها', subtitle: 'بازی‌های بیشتر', accent: RadicalTheme.violet),
                            _QuickTile(icon: Icons.person_rounded, title: 'پروفایل', subtitle: 'هویت بازیکن', accent: RadicalTheme.goldBright),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _AnimatedCard(delay: 180, child: _ScenarioPreview(selected: _selected, onChanged: (v) => setState(() => _selected = v))),
                      ],
                    ),
                  ),
                  _BottomNav(selected: _selected, onChanged: (v) => setState(() => _selected = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: RadicalTheme.panel2.withValues(alpha: .94), borderRadius: BorderRadius.circular(15), border: Border.all(color: RadicalTheme.line)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.diamond_rounded, color: RadicalTheme.goldBright, size: 18), SizedBox(width: 6), Text('100', style: TextStyle(fontWeight: FontWeight.w900))]),
      );
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
  Widget build(BuildContext context) => AnimatedScale(
        scale: _down ? .975 : 1,
        duration: const Duration(milliseconds: 110),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _down = v),
            borderRadius: BorderRadius.circular(20),
            splashColor: RadicalTheme.goldBright.withValues(alpha: .28),
            child: Ink(
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [RadicalTheme.goldBright, RadicalTheme.gold]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x44E3B873), blurRadius: 28, offset: Offset(0, 9))],
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.play_arrow_rounded, color: RadicalTheme.ink, size: 27), SizedBox(width: 9), Text('شروع بازی / ورود به میز', style: TextStyle(color: RadicalTheme.ink, fontSize: 17, fontWeight: FontWeight.w900))]),
            ),
          ),
        ),
      );
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  const _QuickTile({required this.icon, required this.title, required this.subtitle, required this.accent});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          splashColor: accent.withValues(alpha: .16),
          onTap: () {},
          child: Ink(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: RadicalTheme.panel.withValues(alpha: .94), borderRadius: BorderRadius.circular(19), border: Border.all(color: accent.withValues(alpha: .18))),
            child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent, size: 22)), const SizedBox(width: 10), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 10.5))]))]),
          ),
        ),
      );
}

class _ScenarioPreview extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _ScenarioPreview({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('سناریوی سریع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        ...[
          ('تکاور', '۱۰ نفر • امتیازی', Icons.style_rounded),
          ('مذاکره', '۱۰ نفر • مدرن', Icons.auto_awesome_rounded),
          ('سناریوی دست‌ساز', '۵۰ 💎 • دوستانه', Icons.edit_rounded),
        ].asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Padding(padding: EdgeInsets.only(bottom: i == 2 ? 0 : 8), child: _ScenarioRow(title: item.$1, subtitle: item.$2, icon: item.$3, selected: selected == i, onTap: () => onChanged(i)));
        }),
      ]);
}

class _ScenarioRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ScenarioRow({required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: AnimatedContainer(duration: const Duration(milliseconds: 220), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: selected ? const Color(0xFF211B13) : RadicalTheme.panel.withValues(alpha: .90), borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? RadicalTheme.gold.withValues(alpha: .55) : RadicalTheme.line)), child: Row(children: [Icon(icon, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 10.5))])), Icon(selected ? Icons.check_circle_rounded : Icons.chevron_left_rounded, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke, size: 19)])));
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), decoration: const BoxDecoration(color: Color(0xF0090C12), border: Border(top: BorderSide(color: RadicalTheme.line))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NavItem(icon: Icons.home_rounded, label: 'خانه', selected: selected == 0, onTap: () => onChanged(0)),
        _NavItem(icon: Icons.storefront_rounded, label: 'فروشگاه', selected: selected == 1, onTap: () => onChanged(1)),
        _NavItem(icon: Icons.emoji_events_rounded, label: 'رقابتی', selected: selected == 2, onTap: () => onChanged(2)),
        _NavItem(icon: Icons.person_rounded, label: 'پروفایل', selected: selected == 3, onTap: () => onChanged(3)),
      ]));
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 7), decoration: BoxDecoration(color: selected ? RadicalTheme.gold.withValues(alpha: .10) : Colors.transparent, borderRadius: BorderRadius.circular(14)), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke), const SizedBox(height: 3), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: selected ? RadicalTheme.goldBright : RadicalTheme.smoke))])));
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
    Future<void>.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _controller.forward(); });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut), child: SlideTransition(position: Tween(begin: const Offset(0, .12), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)), child: widget.child));
}

class _ParticleField extends StatelessWidget {
  final Animation<double> animation;
  const _ParticleField({required this.animation});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: animation, builder: (_, __) => CustomPaint(painter: _ParticlePainter(animation.value), size: Size.infinite));
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
      final radius = 0.8 + (i % 3) * .55;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}

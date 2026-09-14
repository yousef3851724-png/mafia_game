import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../scenarios/scenario_lobby_screen.dart';

class CinematicHomeScreen extends StatefulWidget {
  const CinematicHomeScreen({super.key});

  @override
  State<CinematicHomeScreen> createState() => _CinematicHomeScreenState();
}

class _CinematicHomeScreenState extends State<CinematicHomeScreen> {
  int _selected = 0;

  void _openLobby() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScenarioLobbyScreen(ownerId: 'local_creator'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  children: [
                    const SizedBox(height: 4),
                    _ScenarioCard(
                      title: 'تکاور',
                      description: 'سناریوی ۱ نفره با نقش تکاور؛ مناسب دوستانه و امتیازی.',
                      icon: Icons.style_rounded,
                      iconColor: const Color(0xFF68707E),
                      selected: _selected == 0,
                      onTap: () => setState(() => _selected = 0),
                      badges: const [
                        _Badge(icon: Icons.star_rounded, label: 'کلاسیک'),
                        _Badge(icon: Icons.people_alt_rounded, label: '۱۰-۱۰ نفر'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ScenarioCard(
                      title: 'مذاکره',
                      description: 'سناریوی ۱۰ نفره با نقش مذاکره؛ مناسب دوستانه و امتیازی.',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: const Color(0xFFF1F2F5),
                      selected: _selected == 1,
                      onTap: () => setState(() => _selected = 1),
                      badges: const [
                        _Badge(icon: Icons.bolt_rounded, label: 'مدرن'),
                        _Badge(icon: Icons.people_alt_rounded, label: '۱۰-۱۰ نفر'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ScenarioCard(
                      title: 'ساخت سناریوی دست‌ساز',
                      description: '۵۰ 💎 • دوستانه • ظرفیت ۸ تا ۲۰ نفر',
                      icon: Icons.edit_rounded,
                      iconColor: RadicalTheme.violet,
                      selected: _selected == 2,
                      onTap: () => setState(() => _selected = 2),
                      trailing: const Icon(Icons.arrow_back_ios_new_rounded, color: RadicalTheme.smoke, size: 17),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'انتخاب فعلی',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: RadicalTheme.smoke),
                    ),
                    const SizedBox(height: 9),
                    _CurrentSelection(),
                    const SizedBox(height: 12),
                    const Text(
                      'تعداد ثابت: ۱۰ نفر',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    const _InfoBox(),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _openLobby,
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'ساخت لابی و شروع بازی',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: RadicalTheme.goldBright,
                          foregroundColor: RadicalTheme.ink,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 19),
            tooltip: 'بازگشت',
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Text(
              'انتخاب سناریو و شروع بازی',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: RadicalTheme.panel2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: RadicalTheme.line),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_rounded, color: Color(0xFF55A9FF), size: 19),
                SizedBox(width: 7),
                Text('100', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;
  final List<_Badge>? badges;
  final Widget? trailing;

  const _ScenarioCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
    this.badges,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF171A20) : RadicalTheme.panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? RadicalTheme.gold.withValues(alpha: .60) : RadicalTheme.line,
              width: selected ? 1.3 : 1,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x52000000), blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12.5, height: 1.55),
                    ),
                    if (badges != null) ...[
                      const SizedBox(height: 13),
                      Wrap(spacing: 7, runSpacing: 7, children: badges!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: RadicalTheme.ink,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: iconColor.withValues(alpha: .25)),
                ),
                child: Icon(icon, color: iconColor, size: 29),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: RadicalTheme.panel3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RadicalTheme.goldBright),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _CurrentSelection extends StatelessWidget {
  const _CurrentSelection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RadicalTheme.panel,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF392418),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFFFF9A42), size: 23),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بازپرس', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('۱۰ تا ۱۰ نفر • امتیازی', style: TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: RadicalTheme.goldBright, size: 21),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10271D),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF245A40)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_events_rounded, color: Color(0xFF62D89A), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'امتیازی: این حالت دقیقاً ۱۰ نفره است و برای رقابت رتبه‌ای طراحی شده.',
              style: TextStyle(color: Color(0xFFBFE7D1), fontSize: 12, height: 1.55, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

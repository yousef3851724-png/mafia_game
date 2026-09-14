import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../../core/widgets/branding/game_logo_widget.dart';
import '../../core/widgets/branding/mafia_radical_wordmark.dart';
import '../scenarios/realistic_avatar.dart';
import '../scenarios/scenario_lobby_screen.dart';

class CinematicHomeScreen extends StatelessWidget {
  const CinematicHomeScreen({super.key});

  void _openLobby(BuildContext context) {
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
        body: Stack(
          children: [
            const _AmbientBackground(),
            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مافیا رادیکال',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.4,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'شب شروع می‌شود؛ اعتماد تمام می‌شود.',
                              style: TextStyle(color: RadicalTheme.smoke, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RadicalTheme.panel,
                          border: Border.all(color: RadicalTheme.gold.withOpacity(.35)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x44000000), blurRadius: 18, offset: Offset(0, 7)),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded, color: RadicalTheme.goldBright),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          RadicalTheme.panel2.withOpacity(.96),
                          RadicalTheme.panel.withOpacity(.94),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: RadicalTheme.gold.withOpacity(.22)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x70000000), blurRadius: 30, offset: Offset(0, 16)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const MafiaRadicalWordmark(width: 290),
                        const SizedBox(height: 8),
                        const MafiaRadicalLogo(size: 88),
                        const SizedBox(height: 8),
                        const Text(
                          'میزگرد رادیکال',
                          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'یک میز. چند مظنون. هیچ‌کس قابل اعتماد نیست.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: RadicalTheme.smoke, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _TablePreview(),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: RadicalTheme.panel.withOpacity(.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: RadicalTheme.gold.withOpacity(.26)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 26, offset: Offset(0, 12)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: RadicalTheme.crimsonBright),
                            SizedBox(width: 8),
                            Text('آماده‌ی بازی هستی؟', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'سناریو را انتخاب کن و بازیکن‌ها را دور میز بچین.',
                          style: TextStyle(color: RadicalTheme.smoke, height: 1.45, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () => _openLobby(context),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('ورود به میز بازی', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(child: _Feature(icon: Icons.groups_rounded, title: 'میزگرد', text: 'چیدمان دایره‌ای')),
                      SizedBox(width: 10),
                      Expanded(child: _Feature(icon: Icons.nights_stay_rounded, title: 'شب و روز', text: 'فضای سینمایی')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: Size.infinite, painter: _AmbientPainter()),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = RadicalTheme.crimson.withOpacity(.06);
    canvas.drawCircle(Offset(size.width * .08, size.height * .16), size.width * .48, paint);
    paint.color = RadicalTheme.gold.withOpacity(.035);
    canvas.drawCircle(Offset(size.width * .94, size.height * .52), size.width * .54, paint);
    paint.color = RadicalTheme.violet.withOpacity(.025);
    canvas.drawCircle(Offset(size.width * .45, size.height * .9), size.width * .42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TablePreview extends StatelessWidget {
  const _TablePreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.14,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          final radius = math.min(constraints.maxWidth, constraints.maxHeight) * .34;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: radius * 2.08,
                height: radius * 2.08,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RadicalTheme.gold.withOpacity(.025),
                  border: Border.all(color: RadicalTheme.gold.withOpacity(.12), width: 1.5),
                ),
              ),
              Container(
                width: radius * 1.5,
                height: radius * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [RadicalTheme.panel2, RadicalTheme.ink],
                  ),
                  border: Border.all(color: RadicalTheme.gold.withOpacity(.48), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66000000), blurRadius: 28, spreadRadius: 2),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_off_rounded, color: RadicalTheme.crimsonBright, size: 29),
                      SizedBox(height: 6),
                      Text('شب اول', style: TextStyle(fontWeight: FontWeight.w900)),
                      SizedBox(height: 2),
                      Text('میز در انتظار', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              ...List.generate(8, (index) {
                final angle = -math.pi / 2 + index * (math.pi * 2 / 8);
                final x = center.dx + math.cos(angle) * radius;
                final y = center.dy + math.sin(angle) * radius;
                final female = index.isOdd;
                return Positioned(
                  left: x - 27,
                  top: y - 27,
                  child: Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: RadicalTheme.ink,
                      border: Border.all(
                        color: index == 0 ? RadicalTheme.goldBright : RadicalTheme.line,
                        width: index == 0 ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x44000000), blurRadius: 12, offset: Offset(0, 5)),
                      ],
                    ),
                    child: RealisticAvatar(
                      role: index == 5 ? 'مافیا' : 'شهروند',
                      female: female,
                      size: 50,
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _Feature({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RadicalTheme.panel.withOpacity(.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: RadicalTheme.goldBright, size: 24),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

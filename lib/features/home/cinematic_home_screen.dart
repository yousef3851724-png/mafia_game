import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import '../../core/widgets/branding/game_logo_widget.dart';
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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مافیا رادیکال',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.5,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'شب شروع می‌شود؛ اعتماد تمام می‌شود.',
                              style: TextStyle(color: RadicalTheme.smoke),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RadicalTheme.panel,
                          border: Border.all(color: RadicalTheme.gold.withOpacity(.45)),
                        ),
                        child: const Icon(Icons.person_rounded, color: RadicalTheme.goldBright),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Center(child: MafiaRadicalLogo(size: 128)),
                  const SizedBox(height: 6),
                  const Text(
                    'میزگرد رادیکال',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'یک میز. چند مظنون. هیچ‌کس قابل اعتماد نیست.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: RadicalTheme.smoke),
                  ),
                  const SizedBox(height: 20),
                  const _TablePreview(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: RadicalTheme.panel.withOpacity(.92),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: RadicalTheme.gold.withOpacity(.28)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 14)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: RadicalTheme.crimsonBright),
                            SizedBox(width: 8),
                            Text('آماده‌ی بازی هستی؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'سناریو را انتخاب کن و بازیکن‌ها را دور میز بچین.',
                          style: TextStyle(color: RadicalTheme.smoke, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: () => _openLobby(context),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('ورود به میز بازی', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
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
      child: CustomPaint(
        size: Size.infinite,
        painter: _AmbientPainter(),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = RadicalTheme.crimson.withOpacity(.07);
    canvas.drawCircle(Offset(size.width * .15, size.height * .18), size.width * .42, paint);
    paint.color = RadicalTheme.gold.withOpacity(.045);
    canvas.drawCircle(Offset(size.width * .9, size.height * .52), size.width * .48, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TablePreview extends StatelessWidget {
  const _TablePreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.12,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          final radius = math.min(constraints.maxWidth, constraints.maxHeight) * .34;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: radius * 1.95,
                height: radius * 1.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RadicalTheme.gold.withOpacity(.04),
                  border: Border.all(color: RadicalTheme.gold.withOpacity(.14), width: 1.5),
                ),
              ),
              Container(
                width: radius * 1.48,
                height: radius * 1.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [RadicalTheme.panel2, RadicalTheme.ink],
                  ),
                  border: Border.all(color: RadicalTheme.gold.withOpacity(.45), width: 2),
                  boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 25, spreadRadius: 4)],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_off_rounded, color: RadicalTheme.crimsonBright, size: 30),
                      SizedBox(height: 6),
                      Text('شب اول', style: TextStyle(fontWeight: FontWeight.w900)),
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
                      border: Border.all(color: index == 0 ? RadicalTheme.goldBright : RadicalTheme.line, width: index == 0 ? 2 : 1),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RadicalTheme.panel.withOpacity(.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: RadicalTheme.goldBright, size: 25),
          const SizedBox(width: 10),
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

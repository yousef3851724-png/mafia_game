import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import 'scenario_game_screen.dart';
import 'scenario_catalog.dart';
import 'custom_scenario_system.dart';
import 'realistic_avatar.dart';

/// Professional cinematic entry shell for every game session.
/// The actual game engine remains in ScenarioGameScreen.
class RadicalGameScreen extends StatelessWidget {
  final ScenarioDefinition? scenario;
  final CustomScenario? customScenario;
  final ScenarioMode mode;
  final int playerCount;

  const RadicalGameScreen({super.key, this.scenario, this.customScenario, required this.mode, required this.playerCount});

  String get title => customScenario?.name ?? scenario?.title ?? 'میز رادیکال';
  bool get ranked => mode == ScenarioMode.ranked;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: Stack(children: [
          const Positioned.fill(child: _Atmosphere()),
          SafeArea(child: Column(children: [
            _header(context),
            Expanded(child: _tablePreview()),
            _bottomLaunch(context),
          ])),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          style: IconButton.styleFrom(backgroundColor: RadicalTheme.panel.withValues(alpha: .92), foregroundColor: Colors.white),
          icon: const Icon(Icons.close_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(ranked ? 'اتاق رقابتی • قوانین رسمی' : 'اتاق دوستانه • میز خصوصی', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11, fontWeight: FontWeight.w700)),
        ])),
        _statusChip(Icons.groups_rounded, '$playerCount نفر'),
      ]),
    );
  }

  Widget _tablePreview() {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxHeight < 520;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(children: [
          _phaseBanner(),
          SizedBox(height: compact ? 12 : 18),
          SizedBox(height: compact ? 300 : 390, child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(child: CustomPaint(painter: _TablePainter())),
            Container(
              width: compact ? 104 : 128, height: compact ? 104 : 128,
              decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.ink, border: Border.all(color: RadicalTheme.gold.withValues(alpha: .48), width: 1.5), boxShadow: [BoxShadow(color: RadicalTheme.gold.withValues(alpha: .08), blurRadius: 28, spreadRadius: 5), BoxShadow(color: Colors.black.withValues(alpha: .6), blurRadius: 24)]),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('RADICAL', style: TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 15)),
                SizedBox(height: 4),
                Text('MAFIA', style: TextStyle(color: RadicalTheme.smoke, fontSize: 10, letterSpacing: 2)),
                SizedBox(height: 8),
                Text('شب ۱', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
              ]),
            ),
            ..._seatPreviews(compact),
          ])),
          const SizedBox(height: 8),
          _infoRow(),
        ]),
      );
    });
  }

  Widget _phaseBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF211A14), Color(0xFF11151E)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: RadicalTheme.gold.withValues(alpha: .20))),
    child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.gold.withValues(alpha: .10)), child: const Icon(Icons.nights_stay_rounded, color: RadicalTheme.gold)),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('آماده شروع بازی', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        SizedBox(height: 3),
        Text('میز آماده است؛ نقش‌ها مخفی و جریان بازی مرحله‌به‌مرحله اجرا می‌شود.', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11, height: 1.35)),
      ])),
      const Icon(Icons.verified_rounded, color: RadicalTheme.gold, size: 20),
    ]),
  );

  List<Widget> _seatPreviews(bool compact) {
    final names = const ['شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا', 'الناز', 'پارسا', 'ترانه', 'مانی'];
    final females = const {'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه'};
    final count = playerCount.clamp(1, 12);
    final radiusX = compact ? 118.0 : 146.0;
    final radiusY = compact ? 112.0 : 146.0;
    return List.generate(count, (i) {
      final angle = -math.pi / 2 + (2 * math.pi * i / count);
      final name = names[i % names.length];
      return Align(
        alignment: Alignment.center,
        child: Transform.translate(
          offset: Offset(radiusX * math.cos(angle), radiusY * math.sin(angle)),
          child: _seat(name, i == 0, i + 1, females.contains(name)),
        ),
      );
    });
  }

  Widget _seat(String name, bool user, int number, bool female) {
    final accent = user ? RadicalTheme.gold : RadicalTheme.violet;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 58,
        height: 58,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withValues(alpha: .95), const Color(0xFF171B25)]),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: .20), blurRadius: 16, spreadRadius: 1)],
        ),
        child: ClipOval(child: RealisticAvatar(role: 'شهروند', female: female, size: 54)),
      ),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.panel2, border: Border.all(color: accent.withValues(alpha: .45))), child: Center(child: Text('$number', style: TextStyle(fontSize: 8, color: accent, fontWeight: FontWeight.w900)))),
        const SizedBox(width: 4),
        Text(name, style: TextStyle(fontSize: 9, fontWeight: user ? FontWeight.w900 : FontWeight.w600, color: user ? RadicalTheme.goldBright : Colors.white)),
      ]),
    ]);
  }

  Widget _infoRow() => Row(children: [
    Expanded(child: _miniStat(Icons.shield_outlined, 'نقش‌ها', 'مخفی')),
    const SizedBox(width: 8),
    Expanded(child: _miniStat(Icons.timer_outlined, 'فازها', 'شب / روز')),
    const SizedBox(width: 8),
    Expanded(child: _miniStat(Icons.emoji_events_outlined, 'حالت', ranked ? 'رقابتی' : 'دوستانه')),
  ]);

  Widget _miniStat(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: RadicalTheme.glass(radius: 16),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: RadicalTheme.gold),
      const SizedBox(width: 6),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 8)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10))])),
    ]),
  );

  Widget _statusChip(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: RadicalTheme.panel2, borderRadius: BorderRadius.circular(18), border: Border.all(color: RadicalTheme.line)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: RadicalTheme.gold), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]),
  );

  Widget _bottomLaunch(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
    decoration: BoxDecoration(color: RadicalTheme.panel.withValues(alpha: .98), border: Border(top: BorderSide(color: RadicalTheme.line)), boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, -8))]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        const Icon(Icons.lock_outline_rounded, size: 16, color: RadicalTheme.smoke),
        const SizedBox(width: 7),
        const Expanded(child: Text('با شروع بازی، نقش‌ها قفل می‌شوند و موتور بازی کنترل فازها را به‌عهده می‌گیرد.', style: TextStyle(color: RadicalTheme.smoke, fontSize: 10))),
        Text('$playerCount/20', style: const TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900, fontSize: 11)),
      ]),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ScenarioGameScreen(scenario: scenario, customScenario: customScenario, mode: mode, playerCount: playerCount))),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text('ورود به میز و شروع بازی')),
      )),
    ]),
  );
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.35), radius: 1.05, colors: [Color(0xFF171A25), RadicalTheme.ink])),
    child: CustomPaint(painter: _GlowPainter()),
  );
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..shader = RadialGradient(colors: [RadicalTheme.violet.withValues(alpha: .10), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(size.width * .50, size.height * .43), radius: size.width * .65));
    canvas.drawCircle(Offset(size.width * .50, size.height * .43), size.width * .65, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * .34;
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = RadicalTheme.gold.withValues(alpha: .12);
    final ring2 = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = RadicalTheme.violet.withValues(alpha: .13);
    canvas.drawCircle(c, r, ring);
    canvas.drawCircle(c, r + 30, ring2);
    canvas.drawCircle(c, r + 55, ring2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

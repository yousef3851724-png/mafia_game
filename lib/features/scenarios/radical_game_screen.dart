import 'package:flutter/material.dart';

import '../../core/theme/radical_theme.dart';
import 'scenario_game_screen.dart';
import 'scenario_catalog.dart';
import 'custom_scenario_system.dart';

/// پوسته‌ی گرافیکی سینمایی بازی؛ موتور اصلی بازی بدون تغییر باقی می‌ماند.
class RadicalGameScreen extends StatelessWidget {
  final ScenarioDefinition? scenario;
  final CustomScenario? customScenario;
  final ScenarioMode mode;
  final int playerCount;

  const RadicalGameScreen({
    super.key,
    this.scenario,
    this.customScenario,
    required this.mode,
    required this.playerCount,
  });

  String get title => customScenario?.name ?? scenario?.title ?? 'میز رادیکال';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RadicalTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _radialTable()),
                  Positioned.fill(child: _seatGrid()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _commandPanel(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(backgroundColor: RadicalTheme.panel),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(mode == ScenarioMode.ranked ? '🏆 اتاق امتیازی' : '🎭 اتاق دوستانه',
                    style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12)),
              ],
            ),
          ),
          _pill(Icons.nightlight_round, 'شب ۱'),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RadicalTheme.panel2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RadicalTheme.line),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: RadicalTheme.gold),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }

  Widget _radialTable() {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(26, 55, 26, 105),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [RadicalTheme.panel2, RadicalTheme.ink]),
          border: Border.all(color: RadicalTheme.gold.withOpacity(.18), width: 2),
          boxShadow: [
            BoxShadow(color: RadicalTheme.crimson.withOpacity(.12), blurRadius: 60, spreadRadius: 10),
            BoxShadow(color: Colors.black.withOpacity(.5), blurRadius: 35, spreadRadius: 8),
          ],
        ),
        child: Center(
          child: Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RadicalTheme.ink,
              border: Border.all(color: RadicalTheme.gold.withOpacity(.38)),
            ),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('RADICAL', style: TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900, letterSpacing: 3)),
              SizedBox(height: 5),
              Text('MAFIA', style: TextStyle(fontSize: 11, color: RadicalTheme.smoke, letterSpacing: 2)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _seatGrid() {
    const names = ['شما','آرش','سارا','بابک','نگار','کیان','مهسا','رضا','الناز','پارسا','ترانه','مانی'];
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 52, 18, 125),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 22,
            crossAxisSpacing: 18,
            childAspectRatio: .9,
          ),
          itemCount: playerCount.clamp(1, 12),
          itemBuilder: (_, index) {
            final alive = index != 7;
            final user = index == 0;
            return _seat(
              number: index + 1,
              name: names[index % names.length],
              alive: alive,
              user: user,
            );
          },
        );
      },
    );
  }

  Widget _seat({required int number, required String name, required bool alive, required bool user}) {
    final accent = user ? RadicalTheme.gold : RadicalTheme.crimson;
    return Opacity(
      opacity: alive ? 1 : .35,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [RadicalTheme.panel2, RadicalTheme.panel]),
                  border: Border.all(color: accent.withOpacity(.8), width: user ? 2.5 : 1.5),
                  boxShadow: [BoxShadow(color: accent.withOpacity(.18), blurRadius: 16)],
                ),
                child: Center(child: Text(user ? '👤' : (number % 4 == 0 ? '🎭' : '🙂'), style: const TextStyle(fontSize: 27))),
              ),
              Positioned(
                right: -3,
                bottom: -2,
                child: Container(
                  width: 23,
                  height: 23,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle, border: Border.all(color: RadicalTheme.ink, width: 2)),
                  child: Text('$number', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: user ? FontWeight.w900 : FontWeight.w600)),
          Text(alive ? (user ? 'نوبت شما' : 'زنده') : 'حذف شد',
              style: TextStyle(fontSize: 9, color: alive ? RadicalTheme.smoke : RadicalTheme.crimsonBright)),
        ],
      ),
    );
  }

  Widget _commandPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: RadicalTheme.panel.withOpacity(.97),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: RadicalTheme.gold.withOpacity(.16)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.55), blurRadius: 24, offset: const Offset(0, -8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('فاز شب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              SizedBox(height: 2),
              Text('توانایی نقش خود را انتخاب کن', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11)),
            ])),
            _pill(Icons.shield_outlined, '۱۰ بازیکن'),
          ]),
          const SizedBox(height: 11),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _openOriginal(context),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('ورود به موتور بازی'),
            )),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(
              onPressed: () => _openOriginal(context),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('ادامه بازی'),
            )),
          ]),
        ],
      ),
    );
  }

  void _openOriginal(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScenarioGameScreen(
          scenario: scenario,
          customScenario: customScenario,
          mode: mode,
          playerCount: playerCount,
        ),
      ),
    );
  }
}

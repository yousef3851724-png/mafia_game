import 'dart:math';
import 'package:flutter/material.dart';
import 'custom_scenario_system.dart';
import 'hunter_scenario.dart';
import 'realistic_avatar.dart';
import 'scenario_catalog.dart';

class ScenarioGameScreen extends StatefulWidget {
  final ScenarioDefinition? scenario;
  final CustomScenario? customScenario;
  final ScenarioMode mode;
  final int playerCount;
  const ScenarioGameScreen({super.key, this.scenario, this.customScenario, required this.mode, required this.playerCount});
  @override
  State<ScenarioGameScreen> createState() => _ScenarioGameScreenState();
}

enum _Phase { night, nightResult, day, dayResult, ended }

class _ScenarioPlayer {
  final String name;
  final String role;
  final bool isUser;
  final bool female;
  int seat;
  bool alive = true;
  bool infected = false;
  int votes = 0;
  _ScenarioPlayer({required this.name, required this.role, required this.isUser, required this.female, required this.seat});
}

class _ScenarioGameScreenState extends State<ScenarioGameScreen> {
  final Random _random = Random();
  late final List<_ScenarioPlayer> _players;
  _Phase _phase = _Phase.night;
  int _round = 1;
  String? _target;
  String _result = '';
  String? _winner;
  String? _investigationResult;
  bool _sniperUsed = false;
  bool _hunterMasterUsed = false;
  final Set<String> _protected = {};
  final Set<String> _blocked = {};
  final Set<String> _silenced = {};

  bool get ranked => widget.mode == ScenarioMode.ranked;
  bool get hunterScenario => widget.scenario?.id == HunterScenario.id;
  String get title => widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریو';
  _ScenarioPlayer get user => _players.firstWhere((p) => p.isUser);
  List<_ScenarioPlayer> get alive => _players.where((p) => p.alive).toList();

  List<String> get roles {
    if (widget.customScenario != null) return List<String>.from(widget.customScenario!.roles).take(widget.playerCount).toList();
    if (hunterScenario && HunterScenario.supports(widget.playerCount)) return HunterScenario.rolesFor(widget.playerCount);
    final base = List<String>.from(widget.scenario?.roles ?? const <String>[]);
    if (base.isEmpty) return List<String>.filled(widget.playerCount, 'شهروند');
    while (base.length < widget.playerCount) { base.add('شهروند'); }
    return base.take(widget.playerCount).toList();
  }

  @override
  void initState() {
    super.initState();
    const names = ['شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا', 'الناز', 'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین', 'رها', 'بردیا', 'آوا', 'نوید'];
    const females = {'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه', 'هلیا', 'نیکا', 'رها', 'آوا'};
    final r = roles;
    _players = List.generate(widget.playerCount, (i) {
      final name = names[i % names.length];
      return _ScenarioPlayer(name: name, role: r[i], isUser: i == 0, female: females.contains(name), seat: i + 1);
    });
  }

  bool mafia(String role) => role == 'مافیا' || role == 'پدرخوانده';
  bool independent(String role) => {'جوکر', 'قاتل مستقل', 'زامبی', 'دوئلیست'}.contains(role) || HunterScenario.hunterRoles.contains(role);
  bool blocked(_ScenarioPlayer p) => _blocked.contains(p.name);
  List<_ScenarioPlayer> selectable() => alive.where((p) => !p.isUser && !_silenced.contains(p.name)).toList();

  void select(String name) {
    if (_phase == _Phase.ended) return;
    setState(() => _target = name);
  }

  void confirm() {
    if (_phase == _Phase.night) _resolveNight();
    if (_phase == _Phase.day) _resolveVote();
  }

  void _resolveNight() {
    final selected = _target;
    _investigationResult = null;
    if (selected == null) {
      _botNight(skipUser: true);
      _finishNight('شب بدون انتخاب کاربر اجرا شد.');
      return;
    }
    final target = _players.firstWhere((p) => p.name == selected);
    if (!target.alive) { _finishNight('این بازیکن دیگر در بازی نیست.'); return; }
    if (blocked(user)) { _finishNight('توانایی شما برای این شب خنثی شد.'); return; }
    String message;
    switch (user.role) {
      case 'مافیا':
      case 'پدرخوانده':
        _kill(target); message = '${target.name} هدف مافیا قرار گرفت.'; break;
      case 'دکتر':
      case 'محافظ':
        _protected.add(target.name); message = '${target.name} برای این شب محافظت شد.'; break;
      case 'کارآگاه':
      case 'بازپرس':
        _investigationResult = _investigate(target); message = 'نتیجه بررسی ${target.name}: $_investigationResult'; break;
      case 'جک':
        if (_random.nextBool()) { _kill(target); message = 'جک به ${target.name} حمله کرد.'; } else { message = 'توانایی جک ناموفق بود.'; } break;
      case 'دادستان':
      case 'مذاکره':
        _blocked.add(target.name); message = 'توانایی ${target.name} برای شب بعد محدود شد.'; break;
      case 'تک‌تیرانداز':
        if (_sniperUsed) { message = 'گلوله تک‌تیرانداز قبلاً استفاده شده است.'; } else { _sniperUsed = true; _kill(target); message = 'تک‌تیرانداز ${target.name} را هدف گرفت.'; } break;
      case 'روانشناس':
        _silenced.add(target.name); message = '${target.name} برای روز بعد ساکت شد.'; break;
      case 'تکاور':
        _protected.add(user.name); message = 'تکاور برای این شب از خود دفاع کرد.'; break;
      case 'شکارچی ارشد':
        if (_hunterMasterUsed) { message = 'قابلیت شکارچی ارشد قبلاً استفاده شده است.'; } else { _hunterMasterUsed = true; if (mafia(target.role)) _kill(target); message = '${target.name} بررسی و شکار شد.'; } break;
      case 'ردیاب':
        message = '${target.name}: ${_activeNight(target.role) ? 'توانایی شبانه فعال دارد.' : 'توانایی شبانه ندارد.'}'; break;
      case 'قاتل مستقل':
        _kill(target); message = 'قاتل مستقل ${target.name} را هدف گرفت.'; break;
      case 'زامبی':
        if (!mafia(target.role)) { target.infected = true; message = '${target.name} آلوده شد.'; } else { message = 'زامبی نمی‌تواند عضو مافیا را آلوده کند.'; } break;
      case 'دوئلیست':
        if (_random.nextBool()) { _kill(target); message = 'دوئلیست در دوئل پیروز شد.'; } else { user.alive = false; message = 'دوئلیست در دوئل شکست خورد.'; } break;
      default: message = 'این نقش توانایی شبانه ویژه‌ای ندارد.';
    }
    _botNight(skipUser: true);
    _finishNight(message);
  }

  bool _activeNight(String role) => {'مافیا','پدرخوانده','دکتر','محافظ','کارآگاه','بازپرس','جک','دادستان','تک‌تیرانداز','ردیاب','شکارچی ارشد','روانشناس','تکاور','مذاکره','جوکر','قاتل مستقل','زامبی','دوئلیست'}.contains(role);

  void _botNight({bool skipUser = false}) {
    final living = List<_ScenarioPlayer>.from(alive);
    final mafiaPlayers = living.where((p) => mafia(p.role) && !(skipUser && p.isUser)).toList();
    for (final bot in living.where((p) => !p.isUser && !blocked(p))) {
      if (bot.role == 'دکتر' || bot.role == 'محافظ') {
        _protected.add(living[_random.nextInt(living.length)].name);
      } else if (bot.role == 'تکاور') {
        _protected.add(bot.name);
      } else if (bot.role == 'روانشناس') {
        final choices = living.where((p) => p != bot).toList();
        if (choices.isNotEmpty) _silenced.add(choices[_random.nextInt(choices.length)].name);
      }
    }
    if (mafiaPlayers.isNotEmpty) {
      final choices = living.where((p) => !mafia(p.role) && !p.isUser).toList();
      if (choices.isNotEmpty) _kill(choices[_random.nextInt(choices.length)]);
    }
  }

  String _investigate(_ScenarioPlayer p) {
    if (p.role == 'پدرخوانده') return 'شهروند';
    if (mafia(p.role)) return 'مافیا';
    if (independent(p.role)) return 'مستقل';
    return 'شهروند';
  }

  void _kill(_ScenarioPlayer target) {
    if (!target.alive || _protected.contains(target.name)) return;
    if (target.role == 'تکاور' && _random.nextBool()) return;
    target.alive = false;
  }

  void _finishNight(String message) {
    _target = null;
    _result = message;
    _phase = _Phase.nightResult;
    setState(() {});
    _checkWinner();
  }

  void _resolveVote() {
    final selected = _target;
    if (selected == null) {
      _result = 'رأی‌گیری بدون انتخاب هدف انجام شد.';
    } else {
      final target = _players.firstWhere((p) => p.name == selected);
      if (!target.alive) {
        _result = 'هدف انتخاب‌شده دیگر زنده نیست.';
      } else {
        final candidates = alive.where((p) => !p.isUser).toList();
        final counts = <String, int>{for (final p in candidates) p.name: 0};
        counts[selected] = (counts[selected] ?? 0) + (user.role == 'شهردار' ? 2 : 1);
        for (final bot in alive.where((p) => !p.isUser && !_silenced.contains(p.name))) {
          final choices = candidates.where((p) => p.name != bot.name).toList();
          if (choices.isNotEmpty) {
            final choice = choices[_random.nextInt(choices.length)];
            counts[choice.name] = (counts[choice.name] ?? 0) + 1;
          }
        }
        final maxVotes = counts.values.isEmpty ? 0 : counts.values.reduce(max);
        final leaders = counts.entries.where((e) => e.value == maxVotes).map((e) => e.key).toList();
        if (leaders.isNotEmpty) {
          final eliminated = _players.firstWhere((p) => p.name == leaders[_random.nextInt(leaders.length)]);
          eliminated.alive = false;
          eliminated.votes = counts[eliminated.name] ?? 0;
          _result = '${eliminated.name} با ${eliminated.votes} رأی از بازی خارج شد.';
        }
      }
    }
    _target = null;
    _silenced.clear();
    _phase = _Phase.dayResult;
    setState(() {});
    _checkWinner();
  }

  void _checkWinner() {
    final m = alive.where((p) => mafia(p.role)).length;
    final nonM = alive.length - m;
    String? winner;
    if (hunterScenario && m == 0 && alive.any((p) => HunterScenario.hunterRoles.contains(p.role))) winner = 'ساید شکارچی 🎯';
    else if (user.role == 'جوکر' && !user.alive) winner = 'جوکر';
    else if (user.role == 'زامبی' && user.alive && alive.where((p) => p.infected).length >= 3) winner = 'زامبی';
    else if (m == 0) winner = 'شهروندان';
    else if (m >= nonM) winner = 'مافیا';
    if (winner != null) { _winner = winner; _phase = _Phase.ended; setState(() {}); }
  }

  void nextPhase() {
    if (_phase == _Phase.nightResult) {
      _phase = _Phase.day;
    } else if (_phase == _Phase.dayResult) {
      _round++;
      _protected.clear();
      _blocked.clear();
      _phase = _Phase.night;
    }
    setState(() {});
  }

  String get phaseLabel {
    switch (_phase) {
      case _Phase.night: return 'شب $_round';
      case _Phase.nightResult: return 'نتیجه شب';
      case _Phase.day: return 'روز $_round • رأی‌گیری';
      case _Phase.dayResult: return 'نتیجه رأی‌گیری';
      case _Phase.ended: return 'پایان بازی';
    }
  }

  @override
  Widget build(BuildContext context) {
    final night = _phase == _Phase.night || _phase == _Phase.nightResult;
    final active = _phase == _Phase.night || _phase == _Phase.day;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: night ? const Color(0xFF060912) : const Color(0xFF0B0908),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(phaseLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA1B2))),
          ]),
          actions: [Padding(padding: const EdgeInsets.only(left: 14), child: Center(child: Text(ranked ? 'رقابتی' : 'دوستانه', style: const TextStyle(color: Color(0xFFFFD991), fontWeight: FontWeight.w900))))],
        ),
        body: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 8), child: _PhaseBanner(night: night, title: _winner ?? (active ? (night ? 'توانایی نقش خود را اجرا کن' : 'یک بازیکن را برای رأی انتخاب کن') : _result), subtitle: _investigationResult)),
          Expanded(child: _RoundTable(players: _players, selected: _target, night: night, onSelect: active ? select : null)),
          _ActionPanel(phase: _phase, result: _result, selectedName: _target, onConfirm: active ? confirm : null, onNext: !active && _phase != _Phase.ended ? nextPhase : null, winner: _winner),
        ])),
      ),
    );
  }
}

class _PhaseBanner extends StatelessWidget {
  final bool night; final String title; final String? subtitle;
  const _PhaseBanner({required this.night, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF10131B), borderRadius: BorderRadius.circular(20), border: Border.all(color: night ? const Color(0x35E4B96B) : const Color(0x35B92F45))), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: night ? const Color(0x20E4B96B) : const Color(0x20B92F45)), child: Icon(night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded, color: night ? const Color(0xFFFFD991) : const Color(0xFFE34B61))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Color(0xFFFFD991), fontSize: 11))]))]));
}

class _RoundTable extends StatelessWidget {
  final List<_ScenarioPlayer> players; final String? selected; final bool night; final ValueChanged<String>? onSelect;
  const _RoundTable({required this.players, required this.selected, required this.night, required this.onSelect});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final h = min(constraints.maxHeight, 500.0);
    final w = constraints.maxWidth;
    final tableSize = min(w * .66, h * .72).clamp(210.0, 330.0);
    final seatW = 70.0;
    final seatH = 90.0;
    return Stack(alignment: Alignment.center, children: [
      Positioned(width: tableSize + 42, height: tableSize + 42, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: night ? const Color(0x335C76B8) : const Color(0x33E4B96B), blurRadius: 42, spreadRadius: 6)]))),
      Container(width: tableSize, height: tableSize, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: night ? const [Color(0xFF263246), Color(0xFF111722), Color(0xFF090D15)] : const [Color(0xFF38281E), Color(0xFF19120F), Color(0xFF0C0A09)], stops: const [.08, .58, 1]), border: Border.all(color: night ? const Color(0x55E4B96B) : const Color(0x55B92F45), width: 2), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 25, spreadRadius: 3)]), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.local_police_rounded, color: Color(0xFFFFD991), size: 34), const SizedBox(height: 7), const Text('MAFIA', style: TextStyle(letterSpacing: 5, fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFFD991))), Text(night ? 'NIGHT TABLE' : 'DAY TABLE', style: const TextStyle(letterSpacing: 2, fontSize: 9, color: Color(0xFF9AA1B2))), const SizedBox(height: 10), Container(width: 62, height: 1, color: const Color(0x55E4B96B))]))),
      for (int i = 0; i < players.length; i++) _seat(context, players[i], i, tableSize, seatW, seatH),
    ]);
  });

  Widget _seat(BuildContext context, _ScenarioPlayer player, int index, double tableSize, double seatW, double seatH) {
    final angle = -pi / 2 + (2 * pi * index / players.length);
    final radius = tableSize / 2 + 38;
    final cx = MediaQuery.sizeOf(context).width / 2;
    final cy = 0.0;
    return Positioned(left: cx + cos(angle) * radius - seatW / 2, top: tableSize / 2 + sin(angle) * radius - seatH / 2, width: seatW, height: seatH, child: _Seat(player: player, selected: player.name == selected, onTap: onSelect == null || !player.alive || player.isUser ? null : () => onSelect!(player.name)));
  }
}

class _Seat extends StatelessWidget {
  final _ScenarioPlayer player; final bool selected; final VoidCallback? onTap;
  const _Seat({required this.player, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: selected ? const Color(0x35E4B96B) : const Color(0xE910131B), borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? const Color(0xFFFFD991) : player.isUser ? const Color(0xFFE4B96B) : const Color(0x22FFFFFF), width: selected || player.isUser ? 1.8 : 1)), child: Column(children: [Expanded(child: Opacity(opacity: player.alive ? 1 : .30, child: RealisticAvatar(role: player.role, female: player.female, size: 55, alive: player.alive))), const SizedBox(height: 2), Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: player.isUser ? const Color(0xFFFFD991) : Colors.white)), Text(player.alive ? '#${player.seat}' : 'حذف', style: const TextStyle(fontSize: 8, color: Color(0xFF9AA1B2))) ])));
}

class _ActionPanel extends StatelessWidget {
  final _Phase phase; final String result; final String? selectedName; final VoidCallback? onConfirm; final VoidCallback? onNext; final String? winner;
  const _ActionPanel({required this.phase, required this.result, required this.selectedName, required this.onConfirm, required this.onNext, required this.winner});
  @override
  Widget build(BuildContext context) {
    if (phase == _Phase.ended) return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF171B25), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0x55E4B96B))), child: Column(children: [const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD991), size: 34), const SizedBox(height: 5), Text('برنده: ${winner ?? 'نامشخص'}', style: const TextStyle(color: Color(0xFFFFD991), fontSize: 20, fontWeight: FontWeight.w900))]));
    final active = phase == _Phase.night || phase == _Phase.day;
    return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 14), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xEE10131B), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0x20FFFFFF))), child: Row(children: [Expanded(child: Text(selectedName == null ? (active ? 'یک صندلی را لمس کن' : result) : 'هدف انتخاب‌شده: $selectedName', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFFB8BFCD), fontWeight: FontWeight.w700))), const SizedBox(width: 10), if (onConfirm != null) FilledButton.icon(onPressed: onConfirm, icon: const Icon(Icons.bolt_rounded, size: 18), label: Text(phase == _Phase.night ? 'اجرا' : 'رأی')) else if (onNext != null) FilledButton.icon(onPressed: onNext, icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: const Text('ادامه'))]));
  }
}

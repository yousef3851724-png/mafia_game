import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
import 'hunter_scenario.dart';
import 'realistic_avatar.dart';
import 'role_seat_layout.dart';
import 'scenario_catalog.dart';

/// موتور بازی سناریوها با پشتیبانی از ساید مستقل «شکارچی».
class ScenarioGameScreen extends StatefulWidget {
  final ScenarioDefinition? scenario;
  final CustomScenario? customScenario;
  final ScenarioMode mode;
  final int playerCount;

  const ScenarioGameScreen({
    super.key,
    this.scenario,
    this.customScenario,
    required this.mode,
    required this.playerCount,
  });

  @override
  State<ScenarioGameScreen> createState() => _ScenarioGameScreenState();
}

class _ScenarioGameScreenState extends State<ScenarioGameScreen> {
  final Random _random = Random();
  late List<_ScenarioPlayer> _players;
  _Phase _phase = _Phase.night;
  int _round = 1;
  String? _target;
  String _result = '';
  String? _winner;
  bool _abilityUsedThisRound = false;
  bool _sniperShotUsed = false;
  bool _hunterMasterUsed = false;
  String? _investigationResult;
  final Set<String> _blockedNextNight = <String>{};
  final Set<String> _protectedNextNight = <String>{};
  final Set<String> _silencedNextDay = <String>{};

  bool get isRanked => widget.mode == ScenarioMode.ranked;
  bool get isHunterScenario => widget.scenario?.id == HunterScenario.id;
  String get _title => widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریو';

  List<String> get _roles {
    if (widget.customScenario != null) return List<String>.from(widget.customScenario!.roles);
    if (isHunterScenario && HunterScenario.supports(widget.playerCount)) {
      return HunterScenario.rolesFor(widget.playerCount);
    }
    final base = List<String>.from(widget.scenario?.roles ?? const <String>[]);
    if (base.isEmpty) return List<String>.filled(widget.playerCount, 'شهروند');
    final roles = <String>[...base];
    while (roles.length < widget.playerCount) roles.add('شهروند');
    return roles.take(widget.playerCount).toList();
  }

  @override
  void initState() {
    super.initState();
    _createPlayers();
  }

  void _createPlayers() {
    // Roles are intentionally not shuffled. The seat order is deterministic
    // and groups related roles together for a coherent visual table.
    final roles = RoleSeatLayout.arrange(_roles);
    const names = <String>['شما','آرش','سارا','بابک','نگار','کیان','مهسا','رضا','الناز','پارسا','ترانه','مانی','هلیا','سام','نیکا','یاسین','رها','بردیا','آوا','نوید'];
    _players = [
      for (int i = 0; i < widget.playerCount; i++)
        _ScenarioPlayer(
          name: names[i],
          role: roles[i],
          isUser: i == 0,
          female: const {'سارا','نگار','مهسا','الناز','ترانه','هلیا','نیکا','رها','آوا'}.contains(names[i]),
        ),
    ];
  }

  List<_ScenarioPlayer> get _alive => _players.where((p) => p.alive).toList();
  _ScenarioPlayer get _user => _players.firstWhere((p) => p.isUser);
  bool _has(String role, _ScenarioPlayer p) => p.role == role;
  bool _mafia(String role) => const {'مافیا', 'پدرخوانده'}.contains(role);
  bool _hunter(String role) => HunterScenario.hunterRoles.contains(role);
  bool _independent(String role) => const {'جوکر', 'قاتل مستقل', 'زامبی'}.contains(role) || _hunter(role);
  bool _blocked(_ScenarioPlayer p) => _blockedNextNight.contains(p.name);
  List<_ScenarioPlayer> _choices({bool night = true}) => _alive.where((p) => !p.isUser && (!_silencedNextDay.contains(p.name) || night)).toList();

  void _resolveNight() {
    final actor = _user;
    final selected = _target;
    _investigationResult = null;
    if (selected == null) {
      _runBotNightActions();
      _finishNightResult('شب بدون انتخاب کاربر اجرا شد.');
      return;
    }
    final target = _players.firstWhere((p) => p.name == selected);
    if (!target.alive) return _finishNightResult('این بازیکن دیگر در بازی نیست.');
    if (_blocked(actor)) return _finishNightResult('توانایی شما برای این شب خنثی شد.');

    String message;
    switch (actor.role) {
      case 'مافیا':
      case 'پدرخوانده':
        _nightKill(target); message = '${target.name} هدف مافیا قرار گرفت.'; break;
      case 'دکتر':
      case 'محافظ':
        _protectedNextNight.add(target.name); message = '${target.name} برای این شب محافظت شد.'; break;
      case 'کارآگاه':
      case 'بازپرس':
        _investigationResult = _investigate(target); message = 'نتیجه بررسی: $_investigationResult'; break;
      case 'جک':
        _abilityUsedThisRound = true;
        if (_random.nextBool()) { _nightKill(target); message = 'جک به ${target.name} حمله کرد.'; } else { message = 'توانایی جک ناموفق بود.'; }
        break;
      case 'دادستان':
        _blockedNextNight.add(target.name); message = 'توانایی ${target.name} برای شب بعد محدود شد.'; break;
      case 'تک‌تیرانداز':
        if (_sniperShotUsed) { message = 'گلوله تک‌تیرانداز قبلاً استفاده شده است.'; } else { _sniperShotUsed = true; _nightKill(target); message = 'تک‌تیرانداز به ${target.name} شلیک کرد.'; }
        break;
      case 'ردیاب':
        message = _nightActiveRole(target.role) ? 'ردیابی ${target.name}: توانایی فعال شبانه دارد.' : 'ردیابی ${target.name}: توانایی فعال شبانه ندارد.';
        break;
      case 'شکارچی ارشد':
        if (_hunterMasterUsed) { message = 'قابلیت شکارچی ارشد قبلاً استفاده شده است.'; }
        else { _hunterMasterUsed = true; if (_mafia(target.role)) { _nightKill(target); message = '${target.name} به‌عنوان هدف مافیا شکار شد.'; } else { message = '${target.name} علامت‌گذاری شد؛ مافیا نبود.'; } }
        break;
      case 'روانشناس':
        _silencedNextDay.add(target.name); message = '${target.name} برای روز بعد ساکت شد.'; break;
      case 'تکاور':
        _abilityUsedThisRound = true; _protectedNextNight.add(actor.name); message = 'تکاور برای این شب از خود دفاع کرد.'; break;
      case 'مذاکره':
        _abilityUsedThisRound = true; _blockedNextNight.add(target.name); message = 'مذاکره روی ${target.name} اثر گذاشت.'; break;
      case 'شهردار': message = 'شهردار توانایی فعال شبانه ندارد؛ رأی او دوبرابر است.'; break;
      case 'جوکر': message = 'جوکر هدف خود را انتخاب کرد.'; break;
      case 'قاتل مستقل': _nightKill(target); message = 'قاتل مستقل ${target.name} را هدف گرفت.'; break;
      case 'زامبی':
        if (!_mafia(target.role)) { target.infected = true; message = '${target.name} آلوده شد.'; } else { message = 'زامبی نمی‌تواند عضو مافیا را آلوده کند.'; }
        break;
      case 'دوئلیست':
        _abilityUsedThisRound = true;
        if (_random.nextBool()) { _nightKill(target); message = 'دوئلیست در دوئل پیروز شد.'; } else { actor.alive = false; message = 'دوئلیست در دوئل شکست خورد.'; }
        break;
      default: message = 'این نقش توانایی شبانه ویژه‌ای ندارد.';
    }
    _runBotNightActions(skipUser: true);
    _finishNightResult(message);
  }

  bool _nightActiveRole(String role) => const {'مافیا','پدرخوانده','دکتر','محافظ','کارآگاه','بازپرس','جک','دادستان','تک‌تیرانداز','ردیاب','شکارچی ارشد','روانشناس','تکاور','مذاکره','جوکر','قاتل مستقل','زامبی','دوئلیست'}.contains(role);

  void _runBotNightActions({bool skipUser = false}) {
    final living = _alive;
    final mafia = living.where((p) => _mafia(p.role)).toList();
    if (mafia.isNotEmpty && !(skipUser && _mafia(_user.role))) {
      final candidates = living.where((p) => !_mafia(p.role) && !p.isUser).toList();
      if (candidates.isNotEmpty) _nightKill(candidates[_random.nextInt(candidates.length)]);
    }
    for (final bot in living.where((p) => !p.isUser && !_blocked(p))) {
      if (bot.role == 'دکتر' || bot.role == 'محافظ') {
        final c = _alive; if (c.isNotEmpty) _protectedNextNight.add(c[_random.nextInt(c.length)].name);
      } else if (bot.role == 'کارآگاه' || bot.role == 'بازپرس') {
        if (_alive.length > 1) _investigate(_alive[_random.nextInt(_alive.length)]);
      } else if (bot.role == 'روانشناس') {
        final c = _alive.where((p) => p != bot).toList(); if (c.isNotEmpty) _silencedNextDay.add(c[_random.nextInt(c.length)].name);
      } else if (bot.role == 'تکاور' && !_abilityUsedThisRound) {
        _protectedNextNight.add(bot.name);
      } else if (bot.role == 'تک‌تیرانداز' && !_sniperShotUsed) {
        final c = _alive.where((p) => p != bot && !_hunter(p.role)).toList(); if (c.isNotEmpty) { _sniperShotUsed = true; _nightKill(c[_random.nextInt(c.length)]); }
      } else if (bot.role == 'شکارچی ارشد' && !_hunterMasterUsed) {
        final c = _alive.where((p) => p != bot).toList(); if (c.isNotEmpty) { final t = c[_random.nextInt(c.length)]; _hunterMasterUsed = true; if (_mafia(t.role)) _nightKill(t); }
      }
    }
  }

  String _investigate(_ScenarioPlayer target) {
    if (_has('پدرخوانده', target)) return 'شهروند';
    if (_mafia(target.role)) return 'مافیا';
    if (_independent(target.role)) return 'مستقل';
    return 'شهروند';
  }

  void _nightKill(_ScenarioPlayer target) {
    if (!target.alive || _protectedNextNight.contains(target.name)) return;
    if (_has('تکاور', target) && _random.nextBool()) return;
    target.alive = false;
  }

  void _finishNightResult(String message) {
    _target = null; _result = message; _phase = _Phase.nightResult; setState(() {}); _checkWinner();
  }

  void _resolveVote() {
    final selected = _target;
    if (selected == null) { _result = 'رأی‌گیری بدون انتخاب هدف انجام شد.'; }
    else {
      final target = _players.firstWhere((p) => p.name == selected);
      if (!target.alive) _result = 'هدف انتخاب‌شده دیگر زنده نیست.';
      else { target.voteWeight = _has('شهردار', _user) ? 2 : 1; target.alive = false; _result = '${target.name} با رأی‌گیری از بازی خارج شد.'; }
    }
    _target = null; _silencedNextDay.clear(); _phase = _Phase.dayResult; setState(() {}); _checkWinner();
  }

  void _checkWinner() {
    final livingMafia = _alive.where((p) => _mafia(p.role)).length;
    final livingNonMafia = _alive.length - livingMafia;
    final hunters = _alive.where((p) => _hunter(p.role)).toList();
    final independents = _alive.where((p) => _independent(p.role)).toList();
    if (isHunterScenario && livingMafia == 0 && hunters.isNotEmpty) { _winner = 'ساید شکارچی 🎯'; _phase = _Phase.ended; }
    else if (isHunterScenario && hunters.isEmpty && livingMafia == 0) { _winner = 'شهروندان'; _phase = _Phase.ended; }
    else if (_user.role == 'جوکر' && !_user.alive) { _winner = 'جوکر'; _phase = _Phase.ended; }
    else if (independents.any((p) => p.role == 'قاتل مستقل') && independents.length == 1 && _alive.length == 1) { _winner = 'قاتل مستقل'; _phase = _Phase.ended; }
    else if (_user.role == 'زامبی' && _user.alive && _alive.where((p) => p.infected).length >= 3) { _winner = 'زامبی'; _phase = _Phase.ended; }
    else if (livingMafia == 0) { _winner = 'شهروندان'; _phase = _Phase.ended; }
    else if (livingMafia >= livingNonMafia) { _winner = 'مافیا'; _phase = _Phase.ended; }
    if (_phase == _Phase.ended) setState(() {});
  }

  void _nextPhase() {
    if (_phase == _Phase.nightResult) _phase = _Phase.day;
    else if (_phase == _Phase.dayResult) { _round++; _abilityUsedThisRound = false; _protectedNextNight.clear(); _blockedNextNight.clear(); _phase = _Phase.night; }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_title), actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Center(child: Text(isRanked ? '🏆 امتیازی' : '🎮 دوستانه')))]),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('دور $_round • ${_alive.length}/${_players.length} بازیکن', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (isHunterScenario) const Padding(padding: EdgeInsets.only(top: 6), child: Text('🎯 ساید مستقل شکارچی • ۱۵ تا ۲۰ نفر', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: RealisticAvatar(role: _user.role, female: _user.female, size: 58),
            title: Text('نقش شما: ${_user.role}'),
            subtitle: Text(_abilityDescription(_user.role)),
          ),
        ),
        if (_investigationResult != null) Card(child: ListTile(leading: const Icon(Icons.search), title: Text(_investigationResult!))),
        if (_phase == _Phase.ended) _endCard() else ...[
          Text(_phase.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_phase == _Phase.night) _targetList(night: true),
          if (_phase == _Phase.day) _targetList(night: false),
          if (_phase == _Phase.nightResult || _phase == _Phase.dayResult) _resultCard(),
        ],
      ]),
    ),
  );

  String _abilityDescription(String role) {
    switch (role) {
      case 'تک‌تیرانداز': return 'یک شلیک ویژه در کل بازی.';
      case 'ردیاب': return 'تشخیص فعالیت شبانه هدف.';
      case 'شکارچی ارشد': return 'یک شکار ویژه علیه هدف مافیا.';
      case 'جک': return 'حمله شبانه با شانس موفقیت.';
      case 'دادستان': return 'محدودکردن توانایی بازیکن برای شب بعد.';
      case 'پدرخوانده': return 'رهبر مافیا و مخفی از کارآگاه.';
      case 'محافظ': return 'محافظت شبانه از یک بازیکن.';
      case 'شهردار': return 'رأی روزانه دوبرابر.';
      case 'روانشناس': return 'ساکت‌کردن یک بازیکن برای روز بعد.';
      case 'بازپرس': return 'بررسی ماهیت یک بازیکن.';
      case 'تکاور': return 'دفاع ویژه شبانه.';
      case 'مذاکره': return 'خنثی‌کردن توانایی یک هدف.';
      case 'جوکر': return 'نقش مستقل با شرط برد متفاوت.';
      case 'قاتل مستقل': return 'قتل مستقل در شب.';
      case 'زامبی': return 'آلوده‌کردن بازیکنان.';
      case 'دکتر': return 'نجات یک بازیکن از حذف شبانه.';
      case 'کارآگاه': return 'تشخیص تیم هدف.';
      default: return 'نقش پایه بدون توانایی ویژه.';
    }
  }

  Widget _targetList({required bool night}) {
    final choices = _choices(night: night);
    return Expanded(child: Column(children: [
      Expanded(child: ListView.builder(itemCount: choices.length, itemBuilder: (_, index) {
        final player = choices[index];
        final disabled = !night && _silencedNextDay.contains(player.name);
        return Card(
          child: ListTile(
            selected: _target == player.name,
            enabled: !disabled,
            leading: RealisticAvatar(role: player.role, female: player.female, size: 48, alive: player.alive),
            title: Text(player.name),
            subtitle: Text(disabled ? 'ساکت شده' : (player.infected ? 'آلوده' : 'زنده')),
            onTap: disabled ? null : () => setState(() => _target = player.name),
          ),
        );
      })),
      FilledButton.icon(onPressed: _target == null ? null : (night ? _resolveNight : _resolveVote), icon: const Icon(Icons.check), label: Text(night ? 'اجرای توانایی شب' : 'ثبت رأی')),
    ]));
  }

  Widget _resultCard() => Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)))), const SizedBox(height: 16), FilledButton.icon(onPressed: _nextPhase, icon: const Icon(Icons.arrow_forward), label: Text(_phase == _Phase.nightResult ? 'شروع روز' : 'شروع شب بعد'))]));

  Widget _endCard() => Expanded(child: Center(child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events, size: 64), const SizedBox(height: 12), Text('برنده: $_winner', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(isRanked ? 'نتیجه این بازی در حالت امتیازی ثبت می‌شود.' : 'این بازی دوستانه بود.'), const SizedBox(height: 16), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('بازگشت به لابی'))])))));
}

enum _Phase { night, nightResult, day, dayResult, ended }

extension on _Phase {
  String get title {
    switch (this) {
      case _Phase.night: return '🌙 شب و اجرای توانایی';
      case _Phase.nightResult: return 'نتیجه شب';
      case _Phase.day: return '☀️ روز و رأی‌گیری';
      case _Phase.dayResult: return 'نتیجه رأی‌گیری';
      case _Phase.ended: return 'پایان بازی';
    }
  }
}

class _ScenarioPlayer {
  final String name;
  final String role;
  final bool isUser;
  final bool female;
  bool alive;
  bool infected = false;
  int voteWeight = 1;

  _ScenarioPlayer({required this.name, required this.role, required this.isUser, required this.female, this.alive = true});
}

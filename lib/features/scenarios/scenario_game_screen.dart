import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
import 'scenario_catalog.dart';

/// موتور بازی سناریوها.
/// قوانین نقش‌های ویژه به صورت مستقل از UI اجرا می‌شوند تا هر سناریو
/// واقعاً رفتار متفاوت داشته باشد.
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
  String? _investigationResult;
  final Set<String> _blockedNextNight = <String>{};
  final Set<String> _protectedNextNight = <String>{};
  final Set<String> _silencedNextDay = <String>{};

  bool get isRanked => widget.mode == ScenarioMode.ranked;

  String get _title => widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریو';

  List<String> get _roles {
    if (widget.customScenario != null) {
      return List<String>.from(widget.customScenario!.roles);
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
    final roles = _roles..shuffle(_random);
    const names = <String>[
      'شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا', 'الناز',
      'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین', 'رها',
      'بردیا', 'آوا', 'نوید',
    ];
    _players = [
      for (int i = 0; i < widget.playerCount; i++)
        _ScenarioPlayer(name: names[i], role: roles[i], isUser: i == 0),
    ];
  }

  List<_ScenarioPlayer> get _alive => _players.where((p) => p.alive).toList();
  _ScenarioPlayer get _user => _players.firstWhere((p) => p.isUser);

  bool _has(String role, _ScenarioPlayer p) => p.role == role;
  bool _mafia(String role) => const {'مافیا', 'پدرخوانده'}.contains(role);
  bool _independent(String role) => const {'جوکر', 'قاتل مستقل', 'زامبی'}.contains(role);
  bool _blocked(_ScenarioPlayer p) => _blockedNextNight.contains(p.name);

  List<_ScenarioPlayer> _choices({bool night = true}) => _alive
      .where((p) => !p.isUser && (!_silencedNextDay.contains(p.name) || night))
      .toList();

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
    if (!target.alive) {
      _finishNightResult('این بازیکن دیگر در بازی نیست.');
      return;
    }

    if (_blocked(actor)) {
      _finishNightResult('توانایی شما برای این شب خنثی شد.');
      return;
    }

    String message;
    switch (actor.role) {
      case 'مافیا':
      case 'پدرخوانده':
        _nightKill(target);
        message = '${target.name} هدف مافیا قرار گرفت.';
        break;
      case 'دکتر':
      case 'محافظ':
        _protectedNextNight.add(target.name);
        message = '${target.name} برای این شب محافظت شد.';
        break;
      case 'کارآگاه':
      case 'بازپرس':
        _investigationResult = _investigate(target);
        message = 'نتیجه بررسی: $_investigationResult';
        break;
      case 'جک':
        _abilityUsedThisRound = true;
        if (_random.nextBool()) {
          _nightKill(target);
          message = 'جک با موفقیت به ${target.name} حمله کرد.';
        } else {
          message = 'توانایی جک این شب ناموفق بود.';
        }
        break;
      case 'دادستان':
        _blockedNextNight.add(target.name);
        message = 'توانایی دادستان ${target.name} را برای شب بعد محدود کرد.';
        break;
      case 'تک‌تیرانداز':
        if (_abilityUsedThisRound) {
          message = 'گلوله تک‌تیرانداز قبلاً استفاده شده است.';
        } else {
          _abilityUsedThisRound = true;
          _nightKill(target);
          message = 'تک‌تیرانداز به ${target.name} شلیک کرد.';
        }
        break;
      case 'روانشناس':
        _silencedNextDay.add(target.name);
        message = '${target.name} برای روز بعد ساکت شد.';
        break;
      case 'تکاور':
        _abilityUsedThisRound = true;
        _protectedNextNight.add(actor.name);
        message = 'تکاور برای این شب خود را آماده دفاع کرد.';
        break;
      case 'مذاکره':
        _abilityUsedThisRound = true;
        _blockedNextNight.add(target.name);
        message = 'مذاکره روی ${target.name} اثر گذاشت.';
        break;
      case 'شهردار':
        message = 'شهردار توانایی فعال شبانه ندارد؛ رأی او در روز دوبرابر است.';
        break;
      case 'جوکر':
        message = 'جوکر هدف خود را انتخاب کرد؛ هدف نهایی او زنده ماندن تا پایان است.';
        break;
      case 'قاتل مستقل':
        _nightKill(target);
        message = 'قاتل مستقل ${target.name} را هدف گرفت.';
        break;
      case 'زامبی':
        if (!_mafia(target.role)) {
          target.infected = true;
          message = '${target.name} آلوده شد.';
        } else {
          message = 'زامبی نمی‌تواند عضو مافیا را آلوده کند.';
        }
        break;
      case 'دوئلیست':
        _abilityUsedThisRound = true;
        if (_random.nextBool()) {
          _nightKill(target);
          message = 'دوئلیست در دوئل با ${target.name} پیروز شد.';
        } else {
          actor.alive = false;
          message = 'دوئلیست در دوئل شکست خورد و حذف شد.';
        }
        break;
      default:
        message = 'این نقش توانایی شبانه ویژه‌ای ندارد.';
    }

    _runBotNightActions(skipUser: true);
    _finishNightResult(message);
  }

  void _runBotNightActions({bool skipUser = false}) {
    final living = _alive;
    final mafia = living.where((p) => _mafia(p.role)).toList();
    if (mafia.isNotEmpty && !(skipUser && _mafia(_user.role))) {
      final candidates = living.where((p) => !_mafia(p.role) && p.isUser == false).toList();
      if (candidates.isNotEmpty) _nightKill(candidates[_random.nextInt(candidates.length)]);
    }

    for (final bot in living.where((p) => !p.isUser && !_blocked(p))) {
      if (bot.role == 'دکتر' || bot.role == 'محافظ') {
        final candidates = _alive;
        if (candidates.isNotEmpty) {
          _protectedNextNight.add(candidates[_random.nextInt(candidates.length)].name);
        }
      } else if (bot.role == 'کارآگاه' || bot.role == 'بازپرس') {
        if (_alive.length > 1) {
          final candidate = _alive[_random.nextInt(_alive.length)];
          if (candidate != bot) _investigate(candidate);
        }
      } else if (bot.role == 'روانشناس') {
        final candidates = _alive.where((p) => p != bot).toList();
        if (candidates.isNotEmpty) _silencedNextDay.add(candidates[_random.nextInt(candidates.length)].name);
      } else if (bot.role == 'تکاور' && !_abilityUsedThisRound) {
        _protectedNextNight.add(bot.name);
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
    if (!target.alive) return;
    if (_protectedNextNight.contains(target.name)) return;
    if (_has('تکاور', target) && _random.nextBool()) return;
    target.alive = false;
  }

  void _finishNightResult(String message) {
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
        target.voteWeight = 1;
        if (_has('شهردار', _user)) target.voteWeight = 2;
        target.alive = false;
        _result = '${target.name} با رأی‌گیری از بازی خارج شد.';
      }
    }
    _target = null;
    _silencedNextDay.clear();
    _phase = _Phase.dayResult;
    setState(() {});
    _checkWinner();
  }

  void _checkWinner() {
    final livingMafia = _alive.where((p) => _mafia(p.role)).length;
    final livingNonMafia = _alive.length - livingMafia;
    final livingIndependents = _alive.where((p) => _independent(p.role)).toList();

    if (_user.role == 'جوکر' && !_user.alive) {
      _winner = 'جوکر';
      _phase = _Phase.ended;
    } else if (livingIndependents.any((p) => p.role == 'قاتل مستقل') && livingIndependents.length == 1 && _alive.length == 1) {
      _winner = 'قاتل مستقل';
      _phase = _Phase.ended;
    } else if (_user.role == 'زامبی' && _user.alive && _alive.where((p) => p.infected).length >= 3) {
      _winner = 'زامبی';
      _phase = _Phase.ended;
    } else if (livingMafia == 0) {
      _winner = 'شهروندان';
      _phase = _Phase.ended;
    } else if (livingMafia >= livingNonMafia) {
      _winner = 'مافیا';
      _phase = _Phase.ended;
    }
    if (_phase == _Phase.ended) setState(() {});
  }

  void _nextPhase() {
    if (_phase == _Phase.nightResult) {
      _phase = _Phase.day;
    } else if (_phase == _Phase.dayResult) {
      _round++;
      _abilityUsedThisRound = false;
      _protectedNextNight.clear();
      _blockedNextNight.clear();
      _phase = _Phase.night;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text(isRanked ? '🏆 امتیازی' : '🎮 دوستانه')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('دور $_round • ${_alive.length}/${_players.length} بازیکن', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.badge)),
                title: Text('نقش شما: ${_user.role}'),
                subtitle: Text(_abilityDescription(_user.role)),
              ),
            ),
            const SizedBox(height: 8),
            if (_investigationResult != null)
              Card(child: ListTile(leading: const Icon(Icons.search), title: Text(_investigationResult!))),
            if (_phase == _Phase.ended)
              _endCard()
            else ...[
              Text(_phase.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_phase == _Phase.night) _targetList(night: true),
              if (_phase == _Phase.day) _targetList(night: false),
              if (_phase == _Phase.nightResult || _phase == _Phase.dayResult) _resultCard(),
            ],
          ],
        ),
      ),
    );
  }

  String _abilityDescription(String role) {
    switch (role) {
      case 'جک': return 'حمله شبانه با شانس موفقیت.';
      case 'دادستان': return 'محدودکردن توانایی بازیکن برای شب بعد.';
      case 'پدرخوانده': return 'رهبر مافیا و مخفی از کارآگاه.';
      case 'محافظ': return 'محافظت شبانه از یک بازیکن.';
      case 'شهردار': return 'رأی روزانه دوبرابر.';
      case 'تک‌تیرانداز': return 'یک شلیک ویژه در کل بازی.';
      case 'روانشناس': return 'ساکت‌کردن یک بازیکن برای روز بعد.';
      case 'بازپرس': return 'بررسی ماهیت یک بازیکن.';
      case 'تکاور': return 'دفاع ویژه شبانه.';
      case 'مذاکره': return 'خنثی‌کردن توانایی یک هدف.';
      case 'جوکر': return 'نقش مستقل با شرط برد متفاوت.';
      case 'قاتل مستقل': return 'قتل مستقل در شب.';
      case 'زامبی': return 'آلوده‌کردن بازیکنان و هدف مستقل.';
      case 'دوئلیست': return 'دوئل شبانه با یک هدف.';
      case 'دکتر': return 'نجات یک بازیکن از حذف شبانه.';
      case 'کارآگاه': return 'تشخیص تیم هدف.';
      default: return 'نقش پایه بدون توانایی ویژه.';
    }
  }

  Widget _targetList({required bool night}) {
    final choices = _choices(night: night);
    final selected = _target;
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: choices.length,
              itemBuilder: (_, index) {
                final player = choices[index];
                final disabled = !night && _silencedNextDay.contains(player.name);
                return Card(
                  child: ListTile(
                    selected: selected == player.name,
                    enabled: !disabled,
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(player.name),
                    subtitle: Text(disabled ? 'ساکت شده' : (player.infected ? 'آلوده' : 'زنده')),
                    onTap: disabled ? null : () => setState(() => _target = player.name),
                  ),
                );
              },
            ),
          ),
          FilledButton.icon(
            onPressed: selected == null ? null : (night ? _resolveNight : _resolveVote),
            icon: const Icon(Icons.check),
            label: Text(night ? 'اجرای توانایی شب' : 'ثبت رأی'),
          ),
        ],
      ),
    );
  }

  Widget _resultCard() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _nextPhase,
            icon: const Icon(Icons.arrow_forward),
            label: Text(_phase == _Phase.nightResult ? 'شروع روز' : 'شروع شب بعد'),
          ),
        ],
      ),
    );
  }

  Widget _endCard() {
    return Expanded(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64),
                const SizedBox(height: 12),
                Text('برنده: $_winner', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(isRanked ? 'نتیجه این بازی در حالت امتیازی ثبت می‌شود.' : 'این بازی دوستانه بود.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => Navigator.pop(context), child: const Text('بازگشت به لابی')),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
  bool alive;
  bool infected = false;
  int voteWeight = 1;

  _ScenarioPlayer({required this.name, required this.role, required this.isUser, this.alive = true});
}

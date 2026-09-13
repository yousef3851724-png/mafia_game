import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
import 'hunter_scenario.dart';
import 'realistic_avatar.dart';
import 'role_seat_layout.dart';
import 'scenario_catalog.dart';

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
  String? _investigationResult;
  bool _sniperShotUsed = false;
  bool _hunterMasterUsed = false;
  final Set<String> _blockedNextNight = <String>{};
  final Set<String> _protectedNextNight = <String>{};
  final Set<String> _silencedNextDay = <String>{};

  bool get isRanked => widget.mode == ScenarioMode.ranked;
  bool get isHunterScenario => widget.scenario?.id == HunterScenario.id;
  String get _title => widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریو';

  List<String> get _roles {
    if (widget.customScenario != null) {
      return List<String>.from(widget.customScenario!.roles).take(widget.playerCount).toList();
    }
    if (isHunterScenario && HunterScenario.supports(widget.playerCount)) {
      return HunterScenario.rolesFor(widget.playerCount);
    }
    final base = List<String>.from(widget.scenario?.roles ?? const <String>[]);
    if (base.isEmpty) return List<String>.filled(widget.playerCount, 'شهروند');
    while (base.length < widget.playerCount) base.add('شهروند');
    return base.take(widget.playerCount).toList();
  }

  @override
  void initState() {
    super.initState();
    _createPlayers();
  }

  void _createPlayers() {
    final roles = RoleSeatLayout.arrange(_roles);
    const names = <String>[
      'شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا',
      'الناز', 'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین',
      'رها', 'بردیا', 'آوا', 'نوید',
    ];
    const femaleNames = <String>{'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه', 'هلیا', 'نیکا', 'رها', 'آوا'};
    _players = [
      for (int i = 0; i < widget.playerCount; i++)
        _ScenarioPlayer(
          name: names[i % names.length],
          role: roles[i],
          isUser: i == 0,
          female: femaleNames.contains(names[i % names.length]),
        ),
    ];
  }

  List<_ScenarioPlayer> get _alive => _players.where((p) => p.alive).toList();
  _ScenarioPlayer get _user => _players.firstWhere((p) => p.isUser);
  bool _mafia(String role) => role == 'مافیا' || role == 'پدرخوانده';
  bool _hunter(String role) => HunterScenario.hunterRoles.contains(role);
  bool _independent(String role) => role == 'جوکر' || role == 'قاتل مستقل' || role == 'زامبی' || _hunter(role);
  bool _blocked(_ScenarioPlayer p) => _blockedNextNight.contains(p.name);

  List<_ScenarioPlayer> _targets() {
    return _alive.where((p) => !p.isUser && !_silencedNextDay.contains(p.name)).toList();
  }

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
        if (_random.nextBool()) {
          _nightKill(target);
          message = 'جک به ${target.name} حمله کرد.';
        } else {
          message = 'توانایی جک ناموفق بود.';
        }
        break;
      case 'دادستان':
        _blockedNextNight.add(target.name);
        message = 'توانایی ${target.name} برای شب بعد محدود شد.';
        break;
      case 'تک‌تیرانداز':
        if (_sniperShotUsed) {
          message = 'گلوله تک‌تیرانداز قبلاً استفاده شده است.';
        } else {
          _sniperShotUsed = true;
          _nightKill(target);
          message = 'تک‌تیرانداز به ${target.name} شلیک کرد.';
        }
        break;
      case 'ردیاب':
        message = _nightActiveRole(target.role)
            ? 'ردیابی ${target.name}: توانایی فعال شبانه دارد.'
            : 'ردیابی ${target.name}: توانایی فعال شبانه ندارد.';
        break;
      case 'شکارچی ارشد':
        if (_hunterMasterUsed) {
          message = 'قابلیت شکارچی ارشد قبلاً استفاده شده است.';
        } else {
          _hunterMasterUsed = true;
          if (_mafia(target.role)) {
            _nightKill(target);
            message = '${target.name} به‌عنوان هدف مافیا شکار شد.';
          } else {
            message = '${target.name} علامت‌گذاری شد؛ مافیا نبود.';
          }
        }
        break;
      case 'روانشناس':
        _silencedNextDay.add(target.name);
        message = '${target.name} برای روز بعد ساکت شد.';
        break;
      case 'تکاور':
        _protectedNextNight.add(actor.name);
        message = 'تکاور برای این شب از خود دفاع کرد.';
        break;
      case 'مذاکره':
        _blockedNextNight.add(target.name);
        message = 'مذاکره روی ${target.name} اثر گذاشت.';
        break;
      case 'شهردار':
        message = 'شهردار توانایی فعال شبانه ندارد؛ رأی او دوبرابر است.';
        break;
      case 'جوکر':
        message = 'جوکر هدف خود را انتخاب کرد.';
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
        if (_random.nextBool()) {
          _nightKill(target);
          message = 'دوئلیست در دوئل پیروز شد.';
        } else {
          actor.alive = false;
          message = 'دوئلیست در دوئل شکست خورد.';
        }
        break;
      default:
        message = 'این نقش توانایی شبانه ویژه‌ای ندارد.';
    }

    _runBotNightActions(skipUser: true);
    _finishNightResult(message);
  }

  bool _nightActiveRole(String role) {
    const roles = <String>{
      'مافیا', 'پدرخوانده', 'دکتر', 'محافظ', 'کارآگاه', 'بازپرس', 'جک',
      'دادستان', 'تک‌تیرانداز', 'ردیاب', 'شکارچی ارشد', 'روانشناس', 'تکاور',
      'مذاکره', 'جوکر', 'قاتل مستقل', 'زامبی', 'دوئلیست',
    };
    return roles.contains(role);
  }

  void _runBotNightActions({bool skipUser = false}) {
    final living = _alive;
    final mafia = living.where((p) => _mafia(p.role)).toList();

    for (final bot in living.where((p) => !p.isUser && !_blocked(p))) {
      if (bot.role == 'دکتر' || bot.role == 'محافظ') {
        final choices = _alive;
        if (choices.isNotEmpty) _protectedNextNight.add(choices[_random.nextInt(choices.length)].name);
      } else if (bot.role == 'تکاور') {
        _protectedNextNight.add(bot.name);
      }
    }

    if (mafia.isNotEmpty && !(skipUser && _mafia(_user.role))) {
      final candidates = living.where((p) => !_mafia(p.role) && !p.isUser).toList();
      if (candidates.isNotEmpty) _nightKill(candidates[_random.nextInt(candidates.length)]);
    }

    for (final bot in living.where((p) => !p.isUser && !_blocked(p))) {
      if (bot.role == 'کارآگاه' || bot.role == 'بازپرس') {
        if (_alive.length > 1) _investigate(_alive[_random.nextInt(_alive.length)]);
      } else if (bot.role == 'روانشناس') {
        final choices = _alive.where((p) => p != bot).toList();
        if (choices.isNotEmpty) _silencedNextDay.add(choices[_random.nextInt(choices.length)].name);
      } else if (bot.role == 'تک‌تیرانداز' && !_sniperShotUsed) {
        final choices = _alive.where((p) => p != bot && !_hunter(p.role)).toList();
        if (choices.isNotEmpty) {
          _sniperShotUsed = true;
          _nightKill(choices[_random.nextInt(choices.length)]);
        }
      } else if (bot.role == 'شکارچی ارشد' && !_hunterMasterUsed) {
        final choices = _alive.where((p) => p != bot).toList();
        if (choices.isNotEmpty) {
          final target = choices[_random.nextInt(choices.length)];
          _hunterMasterUsed = true;
          if (_mafia(target.role)) _nightKill(target);
        }
      }
    }
  }

  String _investigate(_ScenarioPlayer target) {
    if (target.role == 'پدرخوانده') return 'شهروند';
    if (_mafia(target.role)) return 'مافیا';
    if (_independent(target.role)) return 'مستقل';
    return 'شهروند';
  }

  void _nightKill(_ScenarioPlayer target) {
    if (!target.alive || _protectedNextNight.contains(target.name)) return;
    if (target.role == 'تکاور' && _random.nextBool()) return;
    target.alive = false;
  }

  void _finishNightResult(String message) {
    _target = null;
    _result = message;
    _phase = _Phase.nightResult;
    _safeSetState();
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
        final candidates = _alive.where((p) => !p.isUser).toList();
        if (candidates.isEmpty) {
          _result = 'بازیکن دیگری برای رأی‌گیری باقی نمانده است.';
        } else {
          final voteCounts = <String, int>{for (final p in candidates) p.name: 0};
          voteCounts[selected] = (voteCounts[selected] ?? 0) + (_user.role == 'شهردار' ? 2 : 1);
          for (final bot in _alive.where((p) => !p.isUser && !_silencedNextDay.contains(p.name))) {
            final options = candidates.where((p) => p.name != bot.name).toList();
            if (options.isEmpty) continue;
            final choice = options[_random.nextInt(options.length)];
            voteCounts[choice.name] = (voteCounts[choice.name] ?? 0) + 1;
          }
          final maxVotes = voteCounts.values.reduce(max);
          final leaders = voteCounts.entries.where((e) => e.value == maxVotes).map((e) => e.key).toList();
          final eliminatedName = leaders[_random.nextInt(leaders.length)];
          final eliminated = _players.firstWhere((p) => p.name == eliminatedName);
          eliminated.alive = false;
          eliminated.voteWeight = voteCounts[eliminatedName] ?? 0;
          _result = '${eliminated.name} با ${eliminated.voteWeight} رأی از بازی خارج شد.';
        }
      }
    }
    _target = null;
    _silencedNextDay.clear();
    _phase = _Phase.dayResult;
    _safeSetState();
    _checkWinner();
  }

  void _checkWinner() {
    final livingMafia = _alive.where((p) => _mafia(p.role)).length;
    final livingNonMafia = _alive.length - livingMafia;
    final hunters = _alive.where((p) => _hunter(p.role)).toList();
    final independents = _alive.where((p) => _independent(p.role)).toList();

    String? winner;
    if (isHunterScenario && livingMafia == 0 && hunters.isNotEmpty) {
      winner = 'ساید شکارچی 🎯';
    } else if (isHunterScenario && hunters.isEmpty && livingMafia == 0) {
      winner = 'شهروندان';
    } else if (_user.role == 'جوکر' && !_user.alive) {
      winner = 'جوکر';
    } else if (independents.any((p) => p.role == 'قاتل مستقل') && independents.length == 1 && _alive.length == 1) {
      winner = 'قاتل مستقل';
    } else if (_user.role == 'زامبی' && _user.alive && _alive.where((p) => p.infected).length >= 3) {
      winner = 'زامبی';
    } else if (livingMafia == 0) {
      winner = 'شهروندان';
    } else if (livingMafia >= livingNonMafia) {
      winner = 'مافیا';
    }

    if (winner != null) {
      _winner = winner;
      _phase = _Phase.ended;
      _safeSetState();
    }
  }

  void _nextPhase() {
    if (_phase == _Phase.nightResult) {
      _phase = _Phase.day;
    } else if (_phase == _Phase.dayResult) {
      _round++;
      _protectedNextNight.clear();
      _blockedNextNight.clear();
      _phase = _Phase.night;
    }
    _safeSetState();
  }

  void _safeSetState() {
    if (mounted) setState(() {});
  }

  void _select(String name) {
    if (_phase == _Phase.ended) return;
    setState(() => _target = name);
  }

  void _confirm() {
    if (_phase == _Phase.night) {
      _resolveNight();
    } else if (_phase == _Phase.day) {
      _resolveVote();
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = _phase == _Phase.day ? _targets() : _targets();
    final phaseTitle = switch (_phase) {
      _Phase.night => 'شب $_round',
      _Phase.nightResult => 'نتیجه شب',
      _Phase.day => 'روز $_round • رأی‌گیری',
      _Phase.dayResult => 'نتیجه رأی‌گیری',
      _Phase.ended => 'پایان بازی',
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF07080D),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(phaseTitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA1B2))),
          ]),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Center(child: Text(isRanked ? 'رقابتی' : 'دوستانه', style: const TextStyle(color: Color(0xFFFFD991), fontWeight: FontWeight.w800))),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10131B),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0x20FFFFFF)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.nights_stay_rounded, color: Color(0xFFFFD991)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_winner ?? (_phase == _Phase.night ? 'توانایی نقش خود را انتخاب کن' : _phase == _Phase.day ? 'بازیکن مورد نظر برای رأی را انتخاب کن' : _result), style: const TextStyle(fontWeight: FontWeight.w800))),
                  ]),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .82),
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    final selected = player.name == _target;
                    return _PlayerTile(player: player, selected: selected, onTap: player.alive && !player.isUser && (_phase == _Phase.night || _phase == _Phase.day) ? () => _select(player.name) : null);
                  },
                ),
              ),
              if (_phase == _Phase.night || _phase == _Phase.day)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _confirm, icon: const Icon(Icons.check_circle_outline), label: Text(_phase == _Phase.night ? 'اجرای توانایی' : 'ثبت رأی'))),
                )
              else if (_phase == _Phase.nightResult || _phase == _Phase.dayResult)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _nextPhase, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('ادامه بازی'))),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF171B25), borderRadius: BorderRadius.circular(20)), child: Center(child: Text('برنده: ${_winner ?? 'نامشخص'}', style: const TextStyle(color: Color(0xFFFFD991), fontSize: 18, fontWeight: FontWeight.w900)))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final _ScenarioPlayer player;
  final bool selected;
  final VoidCallback? onTap;

  const _PlayerTile({required this.player, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? const Color(0x263A2D16) : const Color(0xFF10131B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFFE4B96B) : const Color(0x20FFFFFF), width: selected ? 1.7 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Opacity(opacity: player.alive ? 1 : .30, child: RealisticAvatar(role: player.role, female: player.female, size: 72, alive: player.alive))),
            const SizedBox(height: 5),
            Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: player.isUser ? const Color(0xFFFFD991) : Colors.white)),
            Text(player.alive ? 'صندلی ${player.seat}' : 'حذف شده', style: const TextStyle(fontSize: 9, color: Color(0xFF9AA1B2))),
          ],
        ),
      ),
    );
  }
}

class _ScenarioPlayer {
  final String name;
  final String role;
  final bool isUser;
  final bool female;
  bool alive;
  bool infected;
  int voteWeight;
  int seat;

  _ScenarioPlayer({required this.name, required this.role, required this.isUser, required this.female, this.alive = true, this.infected = false, this.voteWeight = 0, this.seat = 0}) {
    seat = 0;
  }
}

enum _Phase { night, nightResult, day, dayResult, ended }

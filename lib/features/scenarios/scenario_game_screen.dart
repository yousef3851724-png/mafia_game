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

  const ScenarioGameScreen({super.key, this.scenario, this.customScenario, required this.mode, required this.playerCount});
  @override State<ScenarioGameScreen> createState() => _ScenarioGameScreenState();
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
    if (isHunterScenario && HunterScenario.supports(widget.playerCount)) return HunterScenario.rolesFor(widget.playerCount);
    final base = List<String>.from(widget.scenario?.roles ?? const <String>[]);
    if (base.isEmpty) return List<String>.filled(widget.playerCount, 'شهروند');
    final roles = <String>[...base];
    while (roles.length < widget.playerCount) roles.add('شهروند');
    return roles.take(widget.playerCount).toList();
  }
  @override void initState() { super.initState(); _createPlayers(); }
  void _createPlayers() {
    final roles = RoleSeatLayout.arrange(_roles);
    const names = <String>['شما','آرش','سارا','بابک','نگار','کیان','مهسا','رضا','الناز','پارسا','ترانه','مانی','هلیا','سام','نیکا','یاسین','رها','بردیا','آوا','نوید'];
    _players = [for (int i = 0; i < widget.playerCount; i++) _ScenarioPlayer(name: names[i], role: roles[i], isUser: i == 0, female: const {'سارا','نگار','مهسا','الناز','ترانه','هلیا','نیکا','رها','آوا'}.contains(names[i]))];
  }
  List<_ScenarioPlayer> get _alive => _players.where((p) => p.alive).toList();
  _ScenarioPlayer get _user => _players.firstWhere((p) => p.isUser);
  bool _has(String role, _ScenarioPlayer p) => p.role == role;
  bool _mafia(String role) => const {'مافیا','پدرخوانده'}.contains(role);
  bool _hunter(String role) => HunterScenario.hunterRoles.contains(role);
  bool _independent(String role) => const {'جوکر','قاتل مستقل','زامبی'}.contains(role) || _hunter(role);
  bool _blocked(_ScenarioPlayer p) => _blockedNextNight.contains(p.name);
  List<_ScenarioPlayer> _choices({bool night = true}) => _alive.where((p) => !p.isUser && (!_silencedNextDay.contains(p.name) || night)).toList();

  void _resolveNight() {
    final actor = _user; final selected = _target; _investigationResult = null;
    if (selected == null) { _runBotNightActions(); _finishNightResult('شب بدون انتخاب کاربر اجرا شد.'); return; }
    final target = _players.firstWhere((p) => p.name == selected);
    if (!target.alive) return _finishNightResult('این بازیکن دیگر در بازی نیست.');
    if (_blocked(actor)) return _finishNightResult('توانایی شما برای این شب خنثی شد.');
    String message;
    switch (actor.role) {
      case 'مافیا': case 'پدرخوانده': _nightKill(target); message = '${target.name} هدف مافیا قرار گرفت.'; break;
      case 'دکتر': case 'محافظ': _protectedNextNight.add(target.name); message = '${target.name} برای این شب محافظت شد.'; break;
      case 'کارآگاه': case 'بازپرس': _investigationResult = _investigate(target); message = 'نتیجه بررسی: $_investigationResult'; break;
      case 'جک': _abilityUsedThisRound = true; if (_random.nextBool()) { _nightKill(target); message = 'جک به ${target.name} حمله کرد.'; } else { message = 'توانایی جک ناموفق بود.'; } break;
      case 'دادستان': _blockedNextNight.add(target.name); message = 'توانایی ${target.name} برای شب بعد محدود شد.'; break;
      case 'تک‌تیرانداز': if (_sniperShotUsed) { message = 'گلوله تک‌تیرانداز قبلاً استفاده شده است.'; } else { _sniperShotUsed = true; _nightKill(target); message = 'تک‌تیرانداز به ${target.name} شلیک کرد.'; } break;
      case 'ردیاب': message = _nightActiveRole(target.role) ? 'ردیابی ${target.name}: توانایی فعال شبانه دارد.' : 'ردیابی ${target.name}: توانایی فعال شبانه ندارد.'; break;
      case 'شکارچی ارشد': if (_hunterMasterUsed) { message = 'قابلیت شکارچی ارشد قبلاً استفاده شده است.'; } else { _hunterMasterUsed = true; if (_mafia(target.role)) { _nightKill(target); message = '${target.name} به‌عنوان هدف مافیا شکار شد.'; } else { message = '${target.name} علامت‌گذاری شد؛ مافیا نبود.'; } } break;
      case 'روانشناس': _silencedNextDay.add(target.name); message = '${target.name} برای روز بعد ساکت شد.'; break;
      case 'تکاور': _abilityUsedThisRound = true; _protectedNextNight.add(actor.name); message = 'تکاور برای این شب از خود دفاع کرد.'; break;
      case 'مذاکره': _abilityUsedThisRound = true; _blockedNextNight.add(target.name); message = 'مذاکره روی ${target.name} اثر گذاشت.'; break;
      case 'شهردار': message = 'شهردار توانایی فعال شبانه ندارد؛ رأی او دوبرابر است.'; break;
      case 'جوکر': message = 'جوکر هدف خود را انتخاب کرد.'; break;
      case 'قاتل مستقل': _nightKill(target); message = 'قاتل مستقل ${target.name} را هدف گرفت.'; break;
      case 'زامبی': if (!_mafia(target.role)) { target.infected = true; message = '${target.name} آلوده شد.'; } else { message = 'زامبی نمی‌تواند عضو مافیا را آلوده کند.'; } break;
      case 'دوئلیست': _abilityUsedThisRound = true; if (_random.nextBool()) { _nightKill(target); message = 'دوئلیست در دوئل پیروز شد.'; } else { actor.alive = false; message = 'دوئلیست در دوئل شکست خورد.'; } break;
      default: message = 'این نقش توانایی شبانه ویژه‌ای ندارد.';
    }
    _runBotNightActions(skipUser: true); _finishNightResult(message);
  }
  bool _nightActiveRole(String role) => const {'مافیا','پدرخوانده','دکتر','محافظ','کارآگاه','بازپرس','جک','دادستان','تک‌تیرانداز','ردیاب','شکارچی ارشد','روانشناس','تکاور','مذاکره','جوکر','قاتل مستقل','زامبی','دوئلیست'}.contains(role);
  void _runBotNightActions({bool skipUser = false}) {
    final living = _alive; final mafia = living.where((p) => _mafia(p.role)).toList();
    for (final bot in living.where((p) => !p.isUser && !_blocked(p))) { if (bot.role == 'دکتر' || bot.role == 'محافظ') { final c = _alive; if (c.isNotEmpty) _protectedNextNight.add(c[_random.nextInt(c.length)].name); } else if (bot.role == 'تکاور' && !_abilityUsedThisRound) _protectedNextNight.add(bot.name); }
    if (mafia.isNotEmpty && !(skipUser && _mafia(_user.role))) { final candidates = living.where((p) => !_mafia(p.role) && !p.isUser).toList(); if (candidates.isNotEmpty) _nightKill(candidates[_random.nextInt(candidates.length)]); }
    for (final bot in living.where((p) => !p.isUser && !_blocked(p))) {
      if (bot.role == 'کارآگاه' || bot.role == 'بازپرس') { if (_alive.length > 1) _investigate(_alive[_random.nextInt(_alive.length)]); }
      else if (bot.role == 'روانشناس') { final c = _alive.where((p) => p != bot).toList(); if (c.isNotEmpty) _silencedNextDay.add(c[_random.nextInt(c.length)].name); }
      else if (bot.role == 'تک‌تیرانداز' && !_sniperShotUsed) { final c = _alive.where((p) => p != bot && !_hunter(p.role)).toList(); if (c.isNotEmpty) { _sniperShotUsed = true; _nightKill(c[_random.nextInt(c.length)]); } }
      else if (bot.role == 'شکارچی ارشد' && !_hunterMasterUsed) { final c = _alive.where((p) => p != bot).toList(); if (c.isNotEmpty) { final t = c[_random.nextInt(c.length)]; _hunterMasterUsed = true; if (_mafia(t.role)) _nightKill(t); } }
    }
  }
  String _investigate(_ScenarioPlayer target) { if (_has('پدرخوانده', target)) return 'شهروند'; if (_mafia(target.role)) return 'مافیا'; if (_independent(target.role)) return 'مستقل'; return 'شهروند'; }
  void _nightKill(_ScenarioPlayer target) { if (!target.alive || _protectedNextNight.contains(target.name)) return; if (_has('تکاور', target) && _random.nextBool()) return; target.alive = false; }
  void _finishNightResult(String message) { _target = null; _result = message; _phase = _Phase.nightResult; setState(() {}); _checkWinner(); }
  void _resolveVote() {
    final selected = _target;
    if (selected == null) _result = 'رأی‌گیری بدون انتخاب هدف انجام شد.';
    else { final target = _players.firstWhere((p) => p.name == selected); if (!target.alive) _result = 'هدف انتخاب‌شده دیگر زنده نیست.'; else { final candidates = _alive.where((p) => !p.isUser).toList(); final voteCounts = <String,int>{for (final p in candidates) p.name: 0}; voteCounts[selected] = (voteCounts[selected] ?? 0) + (_has('شهردار', _user) ? 2 : 1); for (final bot in _alive.where((p) => !p.isUser && !_silencedNextDay.contains(p.name))) { final options = candidates.where((p) => p.name != bot.name).toList(); if (options.isEmpty) continue; final choice = options[_random.nextInt(options.length)]; voteCounts[choice.name] = (voteCounts[choice.name] ?? 0) + 1; } final maxVotes = voteCounts.values.reduce(max); final leaders = voteCounts.entries.where((e) => e.value == maxVotes).map((e) => e.key).toList(); final eliminatedName = leaders[_random.nextInt(leaders.length)]; final eliminated = _players.firstWhere((p) => p.name == eliminatedName); eliminated.alive = false; eliminated.voteWeight = voteCounts[eliminatedName] ?? 0; _result = '${eliminated.name} با ${eliminated.voteWeight} رأی از بازی خارج شد.'; } }
    _target = null; _silencedNextDay.clear(); _phase = _Phase.dayResult; setState(() {}); _checkWinner();
  }
  void _checkWinner() {
    final livingMafia = _alive.where((p) => _mafia(p.role)).length; final livingNonMafia = _alive.length - livingMafia; final hunters = _alive.where((p) => _hunter(p.role)).toList(); final independents = _alive.where((p) => _independent(p.role)).toList();
    if (isHunterScenario && livingMafia == 0 && hunters.isNotEmpty) { _winner = 'ساید شکارچی 🎯'; _phase = _Phase.ended; } else if (isHunterScenario && hunters.isEmpty && livingMafia == 0) { _winner = 'شهروندان'; _phase = _Phase.ended; } else if (_user.role == 'جوکر' && !_user.alive) { _winner = 'جوکر'; _phase = _Phase.ended; } else if (independents.any((p) => p.role == 'قاتل مستقل') && independents.length == 1 && _alive.length == 1) { _winner = 'قاتل مستقل'; _phase = _Phase.ended; } else if (_user.role == 'زامبی' && _user.alive && _alive.where((p) => p.infected).length >= 3) { _winner = 'زامبی'; _phase = _Phase.ended; } else if (livingMafia == 0) { _winner = 'شهروندان'; _phase = _Phase.ended; } else if (livingMafia >= livingNonMafia) { _winner = 'مافیا'; _phase = _Phase.ended; }
    if (_phase == _Phase.ended) setState(() {});
  }
  void _nextPhase() { if (_phase == _Phase.nightResult) _phase = _Phase.day; else if (_phase == _Phase.dayResult) { _round++; _abilityUsedThisRound = false; _protectedNextNight.clear(); _blockedNextNight.clear(); _phase = _Phase.night; } setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: const Color(0xFF07080D), appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, titleSpacing: 18, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), Text(isRanked ? '🏆 حالت امتیازی' : '🎭 بازی دوستانه', style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF)))]), actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Center(child: _TopBadge(icon: _phase == _Phase.night ? Icons.nightlight_round : Icons.wb_sunny_rounded, text: 'دور $_round')))]), body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 12), child: Column(children: [
      _statusHeader(),
      const SizedBox(height: 10),
      Expanded(child: _phase == _Phase.ended ? _endCard() : _phase == _Phase.nightResult || _phase == _Phase.dayResult ? _resultCard() : _gameTable()),
    ]))));
  }

  Widget _statusHeader() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF11151E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1FFFFFFF))), child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: _phase == _Phase.night ? const Color(0x332D3C69) : const Color(0x333C2F18), borderRadius: BorderRadius.circular(15)), child: Icon(_phase == _Phase.night ? Icons.nightlight_round : Icons.wb_sunny_rounded, color: _phase == _Phase.night ? const Color(0xFFA9BFFF) : const Color(0xFFFFD991))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_phase.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 3), Text('${_alive.length} بازیکن زنده • نقش شما: ${_user.role}', style: const TextStyle(color: Colors.white54, fontSize: 12))])), if (isHunterScenario) const _TopBadge(icon: Icons.gps_fixed_rounded, text: 'شکارچی') ]));

  Widget _gameTable() => Column(children: [
    Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const RadialGradient(colors: [Color(0xFF202735), Color(0xFF10141C), Color(0xFF0B0E14)], stops: [0, .58, 1]), border: Border.all(color: const Color(0x22E4B96B)), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 12)])), child: Stack(children: [
      Center(child: Container(width: 154, height: 154, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0B0E14), border: Border.all(color: const Color(0x44E4B96B), width: 2), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 28)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('RADICAL', style: TextStyle(letterSpacing: 3, color: Color(0xFFE4B96B), fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(_phase == _Phase.night ? 'NIGHT' : 'DAY', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('$_round', style: const TextStyle(color: Colors.white38))])),
      for (int i = 0; i < _players.length; i++) _seat(_players[i], i),
    ])),
    const SizedBox(height: 10),
    _userPanel(),
  ]);

  Widget _seat(_ScenarioPlayer player, int index) {
    final total = _players.length; final angle = (-pi / 2) + (2 * pi * index / total); final selected = _target == player.name; final radiusX = MediaQuery.sizeOf(context).width * .39; final radiusY = 142.0;
    return Align(alignment: Alignment.center, child: Transform.translate(offset: Offset(cos(angle) * radiusX, sin(angle) * radiusY), child: GestureDetector(onTap: player.alive && !player.isUser && (_phase == _Phase.night || _phase == _Phase.day) ? () => setState(() => _target = player.name) : null, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? const Color(0xFFE4B96B) : player.isUser ? const Color(0xFFE34B61) : player.alive ? const Color(0x55FFFFFF) : const Color(0x221FFFFFFF), width: selected || player.isUser ? 2.5 : 1.2), boxShadow: selected ? const [BoxShadow(color: Color(0x66E4B96B), blurRadius: 12)] : null), child: RealisticAvatar(role: player.role, female: player.female, size: player.isUser ? 54 : 43, alive: player.alive)), const SizedBox(height: 3), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: const Color(0xCC0B0E14), borderRadius: BorderRadius.circular(8)), child: Text(player.name, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: player.alive ? Colors.white : Colors.white30), overflow: TextOverflow.ellipsis)), if (player.infected && player.alive) const Icon(Icons.coronavirus_rounded, size: 11, color: Color(0xFFB56BFF))]))));
  }

  Widget _userPanel() => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFF121720), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x44E4B96B))), child: Row(children: [RealisticAvatar(role: _user.role, female: _user.female, size: 50, alive: _user.alive), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('هویت شما', style: TextStyle(color: Colors.white45, fontSize: 11)), Text(_user.role, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), Text(_abilityDescription(_user.role), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11))])), Icon(_abilityUsedThisRound ? Icons.lock_outline_rounded : Icons.bolt_rounded, color: _abilityUsedThisRound ? Colors.white30 : const Color(0xFFE4B96B))]);

  String _abilityDescription(String role) { switch (role) { case 'تک‌تیرانداز': return 'یک شلیک ویژه در کل بازی.'; case 'ردیاب': return 'تشخیص فعالیت شبانه هدف.'; case 'شکارچی ارشد': return 'یک شکار ویژه علیه هدف مافیا.'; case 'جک': return 'حمله شبانه با شانس موفقیت.'; case 'دادستان': return 'محدودکردن توانایی بازیکن برای شب بعد.'; case 'پدرخوانده': return 'رهبر مافیا و مخفی از کارآگاه.'; case 'محافظ': return 'محافظت شبانه از یک بازیکن.'; case 'شهردار': return 'رأی روزانه دوبرابر.'; case 'روانشناس': return 'ساکت‌کردن یک بازیکن برای روز بعد.'; case 'بازپرس': return 'بررسی ماهیت یک بازیکن.'; case 'تکاور': return 'دفاع ویژه شبانه.'; case 'مذاکره': return 'خنثی‌کردن توانایی یک هدف.'; case 'جوکر': return 'نقش مستقل با شرط برد متفاوت.'; case 'قاتل مستقل': return 'قتل مستقل در شب.'; case 'زامبی': return 'آلوده‌کردن بازیکنان.'; case 'دکتر': return 'نجات یک بازیکن از حذف شبانه.'; case 'کارآگاه': return 'تشخیص تیم هدف.'; default: return 'نقش پایه بدون توانایی ویژه.'; } }

  Widget _targetList({required bool night}) { final choices = _choices(night: night); return Expanded(child: Column(children: [Expanded(child: ListView.builder(itemCount: choices.length, itemBuilder: (_, index) { final player = choices[index]; final disabled = !night && _silencedNextDay.contains(player.name); return _PlayerActionTile(player: player, selected: _target == player.name, disabled: disabled, onTap: disabled ? null : () => setState(() => _target = player.name)); })), _actionButton(night)])); }
  Widget _actionButton(bool night) => FilledButton.icon(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))), onPressed: _target == null ? null : (night ? _resolveNight : _resolveVote), icon: Icon(night ? Icons.bolt_rounded : Icons.how_to_vote_rounded), label: Text(night ? 'اجرای توانایی روی هدف' : 'ثبت رأی نهایی'));
  Widget _resultCard() => Center(child: Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF121720), borderRadius: BorderRadius.circular(26), border: Border.all(color: const Color(0x44E4B96B))), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_phase == _Phase.nightResult ? Icons.nightlight_round : Icons.how_to_vote_rounded, size: 54, color: const Color(0xFFE4B96B)), const SizedBox(height: 14), Text(_phase.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)), if (_investigationResult != null) ...[const SizedBox(height: 10), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0x223E5B88), borderRadius: BorderRadius.circular(13)), child: Text('🔎 $_investigationResult', style: const TextStyle(fontWeight: FontWeight.w800)))], const SizedBox(height: 20), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _nextPhase, icon: const Icon(Icons.arrow_forward_rounded), label: Text(_phase == _Phase.nightResult ? 'ورود به روز' : 'شروع شب بعد'))])));
  Widget _endCard() => Center(child: Container(width: double.infinity, padding: const EdgeInsets.all(26), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF2B2116), Color(0xFF121720)], begin: Alignment.topRight, end: Alignment.bottomLeft), border: Border.all(color: const Color(0x66E4B96B))), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events_rounded, size: 72, color: Color(0xFFFFD991)), const SizedBox(height: 12), const Text('بازی تمام شد', style: TextStyle(color: Colors.white54)), const SizedBox(height: 4), Text('برنده: $_winner', textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(isRanked ? 'نتیجه این بازی در حالت امتیازی ثبت می‌شود.' : 'این بازی دوستانه بود.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)), const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.home_rounded), label: const Text('بازگشت به لابی'))])));
}

class _PlayerActionTile extends StatelessWidget {
  final _ScenarioPlayer player; final bool selected; final bool disabled; final VoidCallback? onTap;
  const _PlayerActionTile({required this.player, required this.selected, required this.disabled, required this.onTap});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(color: selected ? const Color(0x332E271A) : const Color(0xFF11151E), borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? const Color(0xFFE4B96B) : const Color(0x16FFFFFF))), child: Row(children: [RealisticAvatar(role: player.role, female: player.female, size: 47, alive: player.alive), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(player.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(disabled ? 'ساکت شده' : player.infected ? 'آلوده' : 'هدف در دسترس', style: const TextStyle(color: Colors.white45, fontSize: 11))])), if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFFE4B96B))]))));
}

class _TopBadge extends StatelessWidget { final IconData icon; final String text; const _TopBadge({required this.icon, required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0x221F1F26), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x22FFFFFF))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: const Color(0xFFE4B96B)), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]));
}

enum _Phase { night, nightResult, day, dayResult, ended }
extension on _Phase { String get title { switch (this) { case _Phase.night: return '🌙 شب و اجرای توانایی'; case _Phase.nightResult: return 'نتیجه شب'; case _Phase.day: return '☀️ روز و رأی‌گیری'; case _Phase.dayResult: return 'نتیجه رأی‌گیری'; case _Phase.ended: return 'پایان بازی'; } } }
class _ScenarioPlayer { final String name; final String role; final bool isUser; final bool female; bool alive; bool infected = false; int voteWeight = 1; _ScenarioPlayer({required this.name, required this.role, required this.isUser, required this.female, this.alive = true}); }

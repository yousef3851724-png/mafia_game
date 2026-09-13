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

enum _Phase { night, nightResult, day, dayResult, ended }

class _Player {
  final String name;
  final String role;
  final bool female;
  final int seat;
  final bool isUser;
  bool alive;

  _Player({
    required this.name,
    required this.role,
    required this.female,
    required this.seat,
    required this.isUser,
    this.alive = true,
  });
}

class _ScenarioGameScreenState extends State<ScenarioGameScreen> {
  final Random _random = Random();
  late final List<_Player> _players;
  _Phase _phase = _Phase.night;
  int _round = 1;
  String? _selected;
  String _result = '';
  String? _winner;

  static const _names = [
    'شما', 'آرش', 'سارا', 'بابک', 'نگار', 'کیان', 'مهسا', 'رضا',
    'الناز', 'پارسا', 'ترانه', 'مانی', 'هلیا', 'سام', 'نیکا', 'یاسین',
  ];

  static const _femaleNames = {
    'سارا', 'نگار', 'مهسا', 'الناز', 'ترانه', 'هلیا', 'نیکا',
  };

  @override
  void initState() {
    super.initState();
    final roles = _buildRoles();
    _players = List.generate(widget.playerCount, (index) {
      final name = _names[index % _names.length];
      return _Player(
        name: name,
        role: roles[index % roles.length],
        female: _femaleNames.contains(name),
        seat: index + 1,
        isUser: index == 0,
      );
    });
  }

  List<String> _buildRoles() {
    if (widget.customScenario != null && widget.customScenario!.roles.isNotEmpty) {
      return List<String>.from(widget.customScenario!.roles);
    }
    if (widget.scenario != null && widget.scenario!.roles.isNotEmpty) {
      return List<String>.from(widget.scenario!.roles);
    }
    if (widget.scenario?.id == HunterScenario.id &&
        HunterScenario.supports(widget.playerCount)) {
      return HunterScenario.rolesFor(widget.playerCount);
    }
    return const ['مافیا', 'دکتر', 'کارآگاه', 'شهروند'];
  }

  _Player get user => _players.firstWhere((player) => player.isUser);

  List<_Player> get alive => _players.where((player) => player.alive).toList();

  String get title =>
      widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریوی رادیکال';

  bool get isNight => _phase == _Phase.night || _phase == _Phase.nightResult;

  bool get isActive => _phase == _Phase.night || _phase == _Phase.day;

  String get phaseText {
    switch (_phase) {
      case _Phase.night:
        return 'شب $_round';
      case _Phase.nightResult:
        return 'نتیجه شب';
      case _Phase.day:
        return 'روز $_round • رأی‌گیری';
      case _Phase.dayResult:
        return 'نتیجه رأی‌گیری';
      case _Phase.ended:
        return 'پایان بازی';
    }
  }

  void _select(String name) {
    if (!isActive) return;
    setState(() => _selected = name);
  }

  void _confirm() {
    if (_selected == null) {
      setState(() => _result = 'یک بازیکن را انتخاب کن.');
      return;
    }
    if (_phase == _Phase.night) {
      _playNight();
    } else if (_phase == _Phase.day) {
      _vote();
    }
  }

  void _playNight() {
    final target = _players.firstWhere((player) => player.name == _selected);
    if (!target.alive) {
      setState(() => _result = 'این بازیکن دیگر زنده نیست.');
      return;
    }

    final role = user.role;
    if (role == 'دکتر' || role == 'محافظ') {
      _result = '${target.name} برای این شب محافظت شد.';
    } else if (role == 'کارآگاه' || role == 'بازپرس') {
      _result = '${target.name}: ${_isMafia(target.role) ? 'مافیا' : 'شهروند'}';
    } else if (_isMafia(role) || role == 'قاتل مستقل' || role == 'تک‌تیرانداز') {
      target.alive = false;
      _result = '${target.name} در شب حذف شد.';
    } else {
      _result = 'توانایی نقش شما روی ${target.name} اجرا شد.';
    }

    _selected = null;
    _phase = _Phase.nightResult;
    _checkWinner();
    setState(() {});
  }

  void _vote() {
    final target = _players.firstWhere((player) => player.name == _selected);
    if (!target.alive) {
      setState(() => _result = 'این بازیکن دیگر زنده نیست.');
      return;
    }
    target.alive = false;
    _result = '${target.name} با رأی میز از بازی خارج شد.';
    _selected = null;
    _phase = _Phase.dayResult;
    _checkWinner();
    setState(() {});
  }

  bool _isMafia(String role) => role == 'مافیا' || role == 'پدرخوانده';

  void _checkWinner() {
    final mafiaCount = alive.where((player) => _isMafia(player.role)).length;
    final others = alive.length - mafiaCount;
    if (mafiaCount == 0) {
      _winner = 'شهروندان';
      _phase = _Phase.ended;
    } else if (mafiaCount >= others && others > 0) {
      _winner = 'مافیا';
      _phase = _Phase.ended;
    }
  }

  void _next() {
    if (_phase == _Phase.nightResult) {
      _phase = _Phase.day;
    } else if (_phase == _Phase.dayResult) {
      _round++;
      _phase = _Phase.night;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final background = isNight ? const Color(0xFF060912) : const Color(0xFF0C0908);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              _header(context),
              _banner(),
              Expanded(
                child: _Table(
                  players: _players,
                  selected: _selected,
                  night: isNight,
                  onSelect: isActive ? _select : null,
                ),
              ),
              _bottomPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xCC11141C),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Text(phaseText, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA1B2))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xCC11141C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x55E4B96B)),
            ),
            child: Text(
              '${alive.length}/${_players.length}',
              style: const TextStyle(color: Color(0xFFFFD991), fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    final text = _winner ??
        (isActive
            ? (isNight ? 'توانایی نقش خود را اجرا کن' : 'یک بازیکن را برای رأی انتخاب کن')
            : _result);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNight
              ? const [Color(0xCC172238), Color(0xAA10131B)]
              : const [Color(0xCC2B1915), Color(0xAA10131B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isNight ? const Color(0x55E4B96B) : const Color(0x55B92F45)),
      ),
      child: Row(
        children: [
          Icon(isNight ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
              color: const Color(0xFFFFD991), size: 30),
          const SizedBox(width: 10),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget _bottomPanel() {
    if (_phase == _Phase.ended) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xEE15120F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x66E4B96B)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD991), size: 30),
            const SizedBox(width: 10),
            Text('برنده: ${_winner ?? 'نامشخص'}',
                style: const TextStyle(color: Color(0xFFFFD991), fontSize: 19, fontWeight: FontWeight.w900)),
          ],
        ),
      );
    }

    final canNext = _phase == _Phase.nightResult || _phase == _Phase.dayResult;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xEE10131B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x25FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selected == null ? (canNext ? _result : 'یک صندلی را لمس کن') : 'هدف: $_selected',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFB8BFCD), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: canNext ? _next : (isActive ? _confirm : null),
            icon: Icon(canNext ? Icons.arrow_forward_rounded : Icons.bolt_rounded, size: 18),
            label: Text(canNext ? 'ادامه' : (isNight ? 'اجرا' : 'رأی')),
          ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  final List<_Player> players;
  final String? selected;
  final bool night;
  final ValueChanged<String>? onSelect;

  const _Table({
    required this.players,
    required this.selected,
    required this.night,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth * 0.56, constraints.maxHeight * 0.56);
        final tableSize = max(190.0, min(size, 300.0));
        final radius = tableSize / 2 + 28;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: tableSize + 44,
              height: tableSize + 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: night ? const Color(0x445C76B8) : const Color(0x44E4B96B),
                    blurRadius: 44,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            Container(
              width: tableSize,
              height: tableSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: night
                      ? const [Color(0xFF30415A), Color(0xFF111722), Color(0xFF080C13)]
                      : const [Color(0xFF4A3020), Color(0xFF19120F), Color(0xFF0C0A09)],
                ),
                border: Border.all(
                  color: night ? const Color(0x77E4B96B) : const Color(0x77B92F45),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                        color: const Color(0xFFFFD991), size: 30),
                    const SizedBox(height: 6),
                    const Text('MAFIA', style: TextStyle(letterSpacing: 5, fontSize: 18,
                        fontWeight: FontWeight.w900, color: Color(0xFFFFD991))),
                    Text(night ? 'NIGHT TABLE' : 'DAY TABLE',
                        style: const TextStyle(letterSpacing: 2, fontSize: 9, color: Color(0xFF9AA1B2))),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < players.length; i++)
              _seat(context, players[i], i, radius),
          ],
        );
      },
    );
  }

  Widget _seat(BuildContext context, _Player player, int index, double radius) {
    final angle = -pi / 2 + (2 * pi * index / players.length);
    return Transform.translate(
      offset: Offset(cos(angle) * radius, sin(angle) * radius),
      child: GestureDetector(
        onTap: onSelect == null || !player.alive || player.isUser
            ? null
            : () => onSelect!(player.name),
        child: Container(
          width: 76,
          height: 86,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: player.name == selected ? const Color(0x45E4B96B) : const Color(0xDD10131B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: player.name == selected
                  ? const Color(0xFFFFD991)
                  : (player.isUser ? const Color(0xFFE4B96B) : const Color(0x334E6E9E)),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Opacity(
                  opacity: player.alive ? 1 : .28,
                  child: RealisticAvatar(
                    role: player.role,
                    female: player.female,
                    size: 55,
                    alive: player.alive,
                  ),
                ),
              ),
              Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
              Text(player.alive ? '#${player.seat}' : 'حذف',
                  style: const TextStyle(fontSize: 8, color: Color(0xFF9AA1B2))),
            ],
          ),
        ),
      ),
    );
  }
}

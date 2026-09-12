import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_scenario_system.dart';
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
  String? _nightTarget;
  String? _dayTarget;
  String _result = '';
  String? _winner;

  bool get isRanked => widget.mode == ScenarioMode.ranked;

  List<String> get _roles {
    if (widget.customScenario != null) {
      return List<String>.from(widget.customScenario!.roles);
    }
    final base = List<String>.from(widget.scenario?.roles ?? const <String>[]);
    if (base.isEmpty) return List<String>.filled(widget.playerCount, 'شهروند');
    final roles = <String>[];
    roles.addAll(base);
    while (roles.length < widget.playerCount) {
      roles.add('شهروند');
    }
    return roles.take(widget.playerCount).toList();
  }

  @override
  void initState() {
    super.initState();
    _createPlayers();
  }

  void _createPlayers() {
    final roles = _roles..shuffle(_random);
    final names = <String>['شما'];
    const botNames = [
      'آرش',
      'سارا',
      'بابک',
      'نگار',
      'کیان',
      'مهسا',
      'رضا',
      'الناز',
      'پارسا',
      'ترانه',
      'مانی',
      'هلیا',
      'سام',
      'نیکا',
      'یاسین',
      'رها',
      'بردیا',
      'آوا',
      'نوید',
    ];
    names.addAll(botNames.take(max(0, widget.playerCount - 1)));
    _players = [
      for (int i = 0; i < widget.playerCount; i++)
        _ScenarioPlayer(
          name: names[i],
          role: roles[i],
          isUser: i == 0,
        ),
    ];
  }

  List<_ScenarioPlayer> get _alive => _players.where((p) => p.alive).toList();
  _ScenarioPlayer get _user => _players.firstWhere((p) => p.isUser);

  bool _isMafia(String role) => role == 'مافیا' || role == 'mafia';

  void _finishNight() {
    final mafia = _alive.where((p) => _isMafia(p.role)).toList();
    final doctors = _alive.where((p) => p.role == 'دکتر' || p.role == 'doctor').toList();
    String? target;

    if (_isMafia(_user.role) && _user.alive) {
      target = _nightTarget;
    } else if (mafia.isNotEmpty) {
      final candidates = _alive.where((p) => !_isMafia(p.role)).toList();
      if (candidates.isNotEmpty) target = candidates[_random.nextInt(candidates.length)].name;
    }

    String? heal;
    if (_user.role == 'دکتر' && _user.alive) {
      heal = _nightTarget;
    } else if (doctors.isNotEmpty) {
      heal = _alive[_random.nextInt(_alive.length)].name;
    }

    if (target == null) {
      _result = 'شب بدون حذف بازیکن به پایان رسید.';
    } else if (target == heal) {
      _result = 'دکتر موفق شد بازیکن هدف را نجات دهد.';
    } else {
      final victim = _players.firstWhere((p) => p.name == target);
      victim.alive = false;
      _result = '$target از بازی خارج شد.';
    }

    _nightTarget = null;
    _phase = _Phase.nightResult;
    setState(() {});
    _checkWinner();
  }

  void _finishVote() {
    if (_dayTarget == null) {
      _result = 'رأی‌گیری بدون انتخاب کاربر انجام شد.';
    } else {
      final target = _players.firstWhere((p) => p.name == _dayTarget);
      target.alive = false;
      _result = '${target.name} با رأی‌گیری از بازی خارج شد.';
    }
    _dayTarget = null;
    _phase = _Phase.dayResult;
    setState(() {});
    _checkWinner();
  }

  void _checkWinner() {
    final aliveMafia = _alive.where((p) => _isMafia(p.role)).length;
    final aliveOthers = _alive.length - aliveMafia;
    if (aliveMafia == 0) {
      _winner = 'شهروندان';
      _phase = _Phase.ended;
    } else if (aliveMafia >= aliveOthers) {
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
      _phase = _Phase.night;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.customScenario?.name ?? widget.scenario?.title ?? 'سناریو';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            const SizedBox(height: 12),
            if (_phase == _Phase.ended)
              _endCard()
            else ...[
              Text(_phase.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_phase == _Phase.night) _targetList(night: true),
              if (_phase == _Phase.day) _targetList(night: false),
              if (_phase == _Phase.nightResult || _phase == _Phase.dayResult)
                _resultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _targetList({required bool night}) {
    final choices = _alive.where((p) => !p.isUser).toList();
    final selected = night ? _nightTarget : _dayTarget;
    return Expanded(
      child: ListView.builder(
        itemCount: choices.length,
        itemBuilder: (_, index) {
          final player = choices[index];
          return Card(
            child: ListTile(
              selected: selected == player.name,
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(player.name),
              subtitle: Text(player.alive ? 'در بازی' : 'خارج شده'),
              onTap: () => setState(() {
                if (night) {
                  _nightTarget = player.name;
                } else {
                  _dayTarget = player.name;
                }
              }),
            ),
          );
        },
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
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('بازگشت به لابی'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Phase {
  night,
  nightResult,
  day,
  dayResult,
  ended,
}

extension on _Phase {
  String get title {
    switch (this) {
      case _Phase.night:
        return '🌙 شب';
      case _Phase.nightResult:
        return 'نتیجه شب';
      case _Phase.day:
        return '☀️ روز و رأی‌گیری';
      case _Phase.dayResult:
        return 'نتیجه رأی‌گیری';
      case _Phase.ended:
        return 'پایان بازی';
    }
  }
}

class _ScenarioPlayer {
  final String name;
  final String role;
  final bool isUser;
  bool alive;

  _ScenarioPlayer({
    required this.name,
    required this.role,
    required this.isUser,
    this.alive = true,
  });
}

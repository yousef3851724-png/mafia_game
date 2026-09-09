import 'package:flutter/material.dart';
import '../../core/models/game_models.dart';

class GameplayScreen extends StatefulWidget {
  final List<Player> players;
  final void Function(Team) onGameOver;

  const GameplayScreen({super.key, required this.players, required this.onGameOver});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late List<Player> _alive;
  bool _isNight = true;
  bool _busy = false;
  bool _votingDone = false;
  String _eliminated = '';
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _alive = List.of(widget.players);
  }

  Player? _firstAliveWith(RoleType type) {
    for (final p in _alive) {
      if (p.role.type == type) return p;
    }
    return null;
  }

  Team? _winner() {
    final mafiaCount = _alive.where((p) => p.role.team == Team.mafia).length;
    final citizenCount = _alive.length - mafiaCount;
    if (mafiaCount == 0) return Team.citizen;
    if (mafiaCount >= citizenCount) return Team.mafia;
    return null;
  }

  Future<Player?> _pickFromAlive(String prompt, {String? except, bool allowCancel = false}) {
    return showDialog<Player>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        title: Text(prompt),
        children: [
          for (final p in _alive)
            if (p.name != except)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, p),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(p.name),
                ),
              ),
          if (allowCancel)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text('انصراف / رد کردن'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startNight() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _isNight = true;
      _votingDone = false;
      _eliminated = '';
      _log.clear();
    });

    final log = <String>[];
    final dead = <String>[];

    // 1) انتخاب قربانی توسط مافیا
    final mafia = _alive.where((p) => p.role.team == Team.mafia).toList();
    Player? victim;
    if (mafia.isNotEmpty) {
      Player leader = mafia.first;
      for (final p in mafia) {
        if (p.role.type == RoleType.godfather) {
          leader = p;
          break;
        }
      }
      victim = await _pickFromAlive(
        '${leader.name} (مافیا): قربانی شب را انتخاب کن',
        except: leader.name,
      );
    }

    // 2) نجات توسط دکتر
    Player? saved;
    final doctor = _firstAliveWith(RoleType.doctor);
    if (doctor != null) {
      saved = await _pickFromAlive('${doctor.name} (دکتر): چه کسی را نجات بدهد؟');
    }

    // 3) استعلام خصوصی کارآگاه
    final detective = _firstAliveWith(RoleType.detective);
    if (detective != null) {
      final target = await _pickFromAlive('${detective.name} (کارآگاه): از چه کسی استعلام بگیری؟');
      if (target != null) {
        final isMafia = target.role.team == Team.mafia;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('🔍 نتیجه استعلام'),
            content: Text('${target.name}: ${isMafia ? 'مافیا است' : 'شهروند است'}'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('باشه')),
            ],
          ),
        );
      }
    }

    // 4) شلیک اختیاری حرفه‌ای
    final sniper = _firstAliveWith(RoleType.sniper);
    if (sniper != null) {
      final shot = await _pickFromAlive(
        '${sniper.name} (حرفه‌ای): به چه کسی شلیک کنی؟ (انصراف = شلیک نکن)',
        allowCancel: true,
      );
      if (shot != null) {
        if (shot.role.team == Team.mafia) {
          dead.add(shot.name);
          log.add('💥 حرفه‌ای، ${shot.name} را از پای درآورد');
        } else {
          dead.add(shot.name);
          dead.add(sniper.name);
          log.add('💥 تیر حرفه‌ای به شهروند خورد و خودش هم کشته شد');
        }
      }
    }

    // 5) اعمال قتل مافیا و نجات دکتر
    if (victim != null) {
      if (saved != null && saved.name == victim.name) {
        log.add('🩺 دکتر جان ${victim.name} را نجات داد');
      } else {
        dead.add(victim.name);
        log.add('🔪 مافیا ${victim.name} را کشت');
      }
    }

    if (!mounted) return;
    setState(() {
      _alive = _alive.where((p) => !dead.contains(p.name)).toList();
      _log.addAll(log);
      _isNight = false;
      _busy = false;
    });

    final w = _winner();
    if (w != null) widget.onGameOver(w);
  }

  Future<void> _startVoting() async {
    if (_busy) return;
    setState(() => _busy = true);

    final votes = <String, int>{};
    for (final voter in _alive) {
      final target = await _pickFromAlive(
        '${voter.name}: به چه کسی رأی می‌دهی؟',
        except: voter.name,
        allowCancel: true,
      );
      if (target != null) {
        votes[target.name] = (votes[target.name] ?? 0) + 1;
      }
    }

    String? top;
    var topCount = 0;
    var tie = false;
    votes.forEach((name, count) {
      if (count > topCount) {
        topCount = count;
        top = name;
        tie = false;
      } else if (count == topCount) {
        tie = true;
      }
    });

    if (!mounted) return;
    setState(() {
      _busy = false;
      _votingDone = true;
      if (top != null && !tie && topCount > 0) {
        _alive = _alive.where((p) => p.name != top).toList();
        _eliminated = top!;
        _log.add('🗳️ شهروندان ${top} را اعدام کردند');
      } else {
        _log.add('🗳️ رأی کافی نبود؛ کسی اعدام نشد');
      }
    });

    final w = _winner();
    if (w != null) widget.onGameOver(w);
  }

  @override
  Widget build(BuildContext context) {
    final phaseIcon = _isNight ? '🌙' : '☀️';
    final phaseTitle = _isNight ? 'شب — نقش‌های ویژه بیدار می‌شوند' : 'روز — بحث و رأی‌گیری';

    String buttonLabel;
    VoidCallback? onPressed;
    if (_isNight) {
      buttonLabel = _busy ? '...' : '🌙 شروع شب';
      onPressed = _busy ? null : _startNight;
    } else if (!_votingDone) {
      buttonLabel = _busy ? '...' : '🗳️ شروع رأی‌گیری';
      onPressed = _busy ? null : _startVoting;
    } else {
      buttonLabel = '🌙 شب بعدی';
      onPressed = _startNight;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$phaseIcon $phaseTitle'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('👥 بازیکنان زنده: ${_alive.length}'),
                if (_eliminated.isNotEmpty)
                  const Text('☠️ اعدام شد', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < _alive.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(_alive[i].name),
                  ),
                const Divider(),
                for (final line in _log)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.circle, size: 8),
                    title: Text(line),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(buttonLabel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

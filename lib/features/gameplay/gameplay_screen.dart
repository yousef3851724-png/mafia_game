import 'package:flutter/material.dart';
import '../../core/models/game_models.dart';
import '../../core/theme/radical_theme.dart';

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
    for (final player in _alive) {
      if (player.role.type == type) return player;
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

  Future<void> _showWinner(Team winner) async {
    if (!mounted) return;
    final mafia = winner == Team.mafia;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: RadicalTheme.panel,
        title: Text(mafia ? '🩸 پیروزی مافیا' : '🛡️ پیروزی شهروندان'),
        content: Text(
          mafia
              ? 'تیم مافیا اکثریت میز را به دست آورد.'
              : 'تمام اعضای مافیا از بازی خارج شدند.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('پایان بازی'),
          ),
        ],
      ),
    );
    if (mounted) widget.onGameOver(winner);
  }

  Future<Player?> _pickFromAlive(
    String prompt, {
    String? except,
    bool allowCancel = false,
  }) {
    return showDialog<Player>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: RadicalTheme.panel,
        title: Text(prompt, textAlign: TextAlign.right),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final player in _alive)
                if (player.name != except)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: ListTile(
                      onTap: () => Navigator.pop(ctx, player),
                      tileColor: RadicalTheme.panel2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: RadicalTheme.line),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: player.role.team == Team.mafia
                            ? RadicalTheme.crimson
                            : RadicalTheme.gold.withValues(alpha: .16),
                        child: Icon(
                          player.role.icon,
                          color: player.role.team == Team.mafia
                              ? Colors.white
                              : RadicalTheme.goldBright,
                          size: 19,
                        ),
                      ),
                      title: Text(
                        player.name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        player.role.nameFa,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11),
                      ),
                    ),
                  ),
              if (allowCancel)
                ListTile(
                  onTap: () => Navigator.pop(ctx),
                  leading: const Icon(Icons.close, color: RadicalTheme.smoke),
                  title: const Text('انصراف / رد کردن', textAlign: TextAlign.right),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startNight() async {
    if (_busy || _alive.length < 2) return;
    setState(() {
      _busy = true;
      _isNight = true;
      _votingDone = false;
      _eliminated = '';
      _log.clear();
    });

    final log = <String>[];
    final dead = <String>{};

    final mafia = _alive.where((p) => p.role.team == Team.mafia).toList();
    Player? victim;
    if (mafia.isNotEmpty) {
      var leader = mafia.first;
      for (final player in mafia) {
        if (player.role.type == RoleType.godfather) {
          leader = player;
          break;
        }
      }
      victim = await _pickFromAlive(
        '${leader.name} (مافیا): قربانی شب را انتخاب کن',
        except: leader.name,
      );
    }

    final doctor = _firstAliveWith(RoleType.doctor);
    Player? saved;
    if (doctor != null) {
      saved = await _pickFromAlive('${doctor.name} (دکتر): چه کسی را نجات بدهد؟');
    }

    final detective = _firstAliveWith(RoleType.detective);
    if (detective != null) {
      final target = await _pickFromAlive(
        '${detective.name} (کارآگاه): از چه کسی استعلام بگیری؟',
        except: detective.name,
      );
      if (target != null) {
        // طبق قانون این نسخه، پدرخوانده برای کارآگاه شهروند دیده می‌شود.
        final isMafiaForDetective =
            target.role.team == Team.mafia && target.role.type != RoleType.godfather;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: RadicalTheme.panel,
            title: const Text('🔍 نتیجه استعلام'),
            content: Text(
              '${target.name}: ${isMafiaForDetective ? 'مافیا است' : 'شهروند است'}',
              textAlign: TextAlign.right,
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('باشه'),
              ),
            ],
          ),
        );
      }
    }

    final sniper = _firstAliveWith(RoleType.sniper);
    if (sniper != null && !dead.contains(sniper.name)) {
      final shot = await _pickFromAlive(
        '${sniper.name} (حرفه‌ای): به چه کسی شلیک کنی؟',
        except: sniper.name,
        allowCancel: true,
      );
      if (shot != null) {
        dead.add(shot.name);
        if (shot.role.team == Team.mafia) {
          log.add('💥 حرفه‌ای، ${shot.name} را از پای درآورد');
        } else {
          dead.add(sniper.name);
          log.add('💥 تیر حرفه‌ای به شهروند خورد و ${sniper.name} هم کشته شد');
        }
      }
    }

    if (victim != null && !dead.contains(victim.name)) {
      if (saved?.name == victim.name) {
        log.add('🩺 دکتر جان ${victim.name} را نجات داد');
      } else {
        dead.add(victim.name);
        log.add('🔪 مافیا ${victim.name} را کشت');
      }
    } else if (victim != null && saved?.name == victim.name) {
      log.add('🩺 دکتر جان ${victim.name} را نجات داد');
    }

    if (!mounted) return;
    setState(() {
      _alive = _alive.where((p) => !dead.contains(p.name)).toList();
      _log
        ..clear()
        ..addAll(log);
      _isNight = false;
      _busy = false;
    });

    final winner = _winner();
    if (winner != null) await _showWinner(winner);
  }

  Future<void> _startVoting() async {
    if (_busy || _alive.length < 2) return;
    setState(() => _busy = true);

    final votes = <String, int>{};
    for (final voter in List<Player>.of(_alive)) {
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
      } else if (count == topCount && count > 0) {
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
        _log.add('🗳️ شهروندان $top را اعدام کردند');
      } else {
        _log.add('🗳️ رأی مساوی یا ناکافی بود؛ کسی اعدام نشد');
      }
    });

    final winner = _winner();
    if (winner != null) await _showWinner(winner);
  }

  Widget _phaseHeader() {
    final night = _isNight;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(17),
      decoration: RadicalTheme.glass(accent: night),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (night ? RadicalTheme.violet : RadicalTheme.gold).withValues(alpha: .13),
              border: Border.all(
                color: (night ? RadicalTheme.violet : RadicalTheme.gold).withValues(alpha: .45),
              ),
            ),
            child: Icon(
              night ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              color: night ? RadicalTheme.violet : RadicalTheme.goldBright,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  night ? 'فاز شب' : 'فاز روز',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  night
                      ? 'نقش‌های ویژه بیدار می‌شوند و اکشن خود را انجام می‌دهند.'
                      : 'بحث، تحلیل و رأی‌گیری برای حذف یک بازیکن.',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: RadicalTheme.smoke, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerTile(Player player, int index) {
    final mafia = player.role.team == Team.mafia;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: RadicalTheme.glass(radius: 17),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: (mafia ? RadicalTheme.crimson : RadicalTheme.gold).withValues(alpha: .14),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: mafia ? RadicalTheme.crimsonBright : RadicalTheme.goldBright,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(
          player.name,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          player.role.nameFa,
          textAlign: TextAlign.right,
          style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11),
        ),
        trailing: Icon(player.role.icon, color: mafia ? RadicalTheme.crimsonBright : RadicalTheme.gold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel;
    VoidCallback? onPressed;
    if (_isNight) {
      buttonLabel = _busy ? 'در حال اجرای اکشن‌های شب...' : '🌙 شروع شب';
      onPressed = _busy ? null : _startNight;
    } else if (!_votingDone) {
      buttonLabel = _busy ? 'در حال ثبت رأی‌ها...' : '🗳️ شروع رأی‌گیری';
      onPressed = _busy ? null : _startVoting;
    } else {
      buttonLabel = '🌙 شب بعدی';
      onPressed = _busy ? null : _startNight;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MAFIA • RADICAL'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: Text(
                '${_alive.length} زنده',
                style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _phaseHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              children: [
                Text(
                  'بازیکنان زنده',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 9),
                for (var i = 0; i < _alive.length; i++) _playerTile(_alive[i], i),
                if (_log.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  const Text(
                    'گزارش این راند',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: RadicalTheme.glass(radius: 17),
                    child: Column(
                      children: [
                        for (final line in _log)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(line, textAlign: TextAlign.right),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

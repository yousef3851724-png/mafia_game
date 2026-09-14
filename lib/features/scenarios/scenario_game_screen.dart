import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/radical_theme.dart';
import '../game/game_state.dart';
import '../game/player_avatar.dart';
import 'custom_scenario_system.dart';
import 'realistic_avatar.dart';
import 'scenario_catalog.dart';

class ScenarioGameScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ScenarioGameScreen> createState() => _ScenarioGameScreenState();
}

class _ScenarioGameScreenState extends ConsumerState<ScenarioGameScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(gameControllerProvider.notifier).start(
          playerCount: widget.playerCount,
          scenario: widget.scenario,
          customScenario: widget.customScenario,
        );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final night = game.phase == GamePhase.night;
    final userAlive = game.user?.alive ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: night ? const Color(0xFF060A12) : const Color(0xFF100A08),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _Header(game: game, title: _title),
                _PhaseBanner(game: game),
                Expanded(
                  child: _GameTable(
                    players: game.players,
                    selectedId: game.selectedPlayerId,
                    night: night,
                    onSelect: userAlive && game.phase != GamePhase.ended
                        ? controller.selectPlayer
                        : null,
                  ),
                ),
                _ActionPanel(
                  game: game,
                  onNightAction: controller.performNightAction,
                  onStartVoting: controller.startVoting,
                  onVote: controller.castVote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _title => widget.customScenario?.name ?? widget.scenario?.title ?? 'میز رادیکال';
}

class _Header extends StatelessWidget {
  final GameState game;
  final String title;

  const _Header({required this.game, required this.title});

  @override
  Widget build(BuildContext context) {
    final phase = switch (game.phase) {
      GamePhase.night => 'شب ${game.round}',
      GamePhase.dayDiscussion => 'روز ${game.round} • بحث',
      GamePhase.dayVoting => 'روز ${game.round} • رأی‌گیری',
      GamePhase.ended => 'پایان بازی',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: RadicalTheme.panel2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(phase, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: RadicalTheme.panel2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RadicalTheme.gold.withValues(alpha: .30)),
            ),
            child: Text(
              '${game.alivePlayers.length}/${game.players.length}',
              style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseBanner extends StatelessWidget {
  final GameState game;

  const _PhaseBanner({required this.game});

  @override
  Widget build(BuildContext context) {
    final night = game.phase == GamePhase.night;
    final ended = game.phase == GamePhase.ended;
    final color = ended ? RadicalTheme.gold : (night ? const Color(0xFF7B91C4) : RadicalTheme.crimsonBright);
    final icon = ended
        ? Icons.emoji_events_rounded
        : night
            ? Icons.nights_stay_rounded
            : Icons.wb_sunny_rounded;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: night
              ? const [Color(0xCC18243A), Color(0xAA10141D)]
              : const [Color(0xCC321914), Color(0xAA11141B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .32)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .10),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              game.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, height: 1.35),
            ),
          ),
          if (!ended)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .22),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '${game.secondsLeft}s',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameTable extends StatelessWidget {
  final List<GamePlayer> players;
  final String? selectedId;
  final bool night;
  final ValueChanged<String>? onSelect;

  const _GameTable({
    required this.players,
    required this.selectedId,
    required this.night,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final table = (constraints.maxWidth * .48).clamp(190.0, 280.0);
        final radiusX = table / 2 + 28;
        final radiusY = table / 2 + 25;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: table + 58,
              height: table + 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (night ? const Color(0xFF5C78B2) : RadicalTheme.crimson)
                        .withValues(alpha: .10),
                    blurRadius: 50,
                    spreadRadius: 7,
                  ),
                ],
              ),
            ),
            Container(
              width: table,
              height: table,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: night
                      ? const [Color(0xFF2B3A52), Color(0xFF121925), Color(0xFF080B11)]
                      : const [Color(0xFF482C20), Color(0xFF1C1210), Color(0xFF0D0908)],
                ),
                border: Border.all(
                  color: (night ? RadicalTheme.gold : RadicalTheme.crimsonBright).withValues(alpha: .48),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                        color: RadicalTheme.goldBright, size: 29),
                    const SizedBox(height: 5),
                    const Text('MAFIA', style: TextStyle(color: RadicalTheme.goldBright, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)),
                    const SizedBox(height: 3),
                    Text(night ? 'NIGHT TABLE' : 'DAY TABLE', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 9, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
            ...List.generate(players.length, (index) {
              final angle = -1.5708 + (6.283185 * index / players.length);
              final player = players[index];
              return Transform.translate(
                offset: Offset(radiusX * _cos(angle), radiusY * _sin(angle)),
                child: _PlayerSeat(
                  player: player,
                  selected: player.id == selectedId,
                  onTap: onSelect == null ? null : () => onSelect!(player.id),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  double _cos(double value) => value.cos();
  double _sin(double value) => value.sin();
}

class _PlayerSeat extends StatelessWidget {
  final GamePlayer player;
  final bool selected;
  final VoidCallback? onTap;

  const _PlayerSeat({required this.player, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = player.isUser ? RadicalTheme.gold : RadicalTheme.crimson;
    final avatar = player.avatar;

    return GestureDetector(
      onTap: player.alive && !player.isUser ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 76,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? RadicalTheme.gold.withValues(alpha: .12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? RadicalTheme.goldBright : Colors.transparent,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: player.alive ? 1 : .32,
              child: Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [accent.withValues(alpha: .95), RadicalTheme.panel2]),
                  boxShadow: [BoxShadow(color: accent.withValues(alpha: .18), blurRadius: 13)],
                ),
                child: ClipOval(child: _AvatarView(avatar: avatar)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: player.isUser ? FontWeight.w900 : FontWeight.w700,
                color: player.alive ? (player.isUser ? RadicalTheme.goldBright : Colors.white) : RadicalTheme.smoke,
              ),
            ),
            Text(
              player.alive ? '#${player.seat}' : 'حذف شد',
              style: TextStyle(fontSize: 8, color: player.alive ? RadicalTheme.smoke : RadicalTheme.crimsonBright),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarView extends StatelessWidget {
  final PlayerAvatar avatar;

  const _AvatarView({required this.avatar});

  @override
  Widget build(BuildContext context) {
    if (avatar.assetPath != null && avatar.assetPath!.isNotEmpty) {
      return Image.asset(avatar.assetPath!, fit: BoxFit.cover);
    }
    if (avatar.imageUrl != null && avatar.imageUrl!.isNotEmpty) {
      return Image.network(avatar.imageUrl!, fit: BoxFit.cover);
    }
    return RealisticAvatar(role: 'شهروند', female: avatar.female, size: 50);
  }
}

class _ActionPanel extends StatelessWidget {
  final GameState game;
  final VoidCallback onNightAction;
  final VoidCallback onStartVoting;
  final VoidCallback onVote;

  const _ActionPanel({
    required this.game,
    required this.onNightAction,
    required this.onStartVoting,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    if (game.phase == GamePhase.ended) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: RadicalTheme.panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: RadicalTheme.gold.withValues(alpha: .36)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, color: RadicalTheme.goldBright, size: 30),
            const SizedBox(width: 10),
            Text('برنده: ${game.winner ?? 'نامشخص'}', style: const TextStyle(color: RadicalTheme.goldBright, fontSize: 19, fontWeight: FontWeight.w900)),
          ],
        ),
      );
    }

    final userAlive = game.user?.alive ?? false;
    final role = game.user?.role ?? 'شهروند';

    if (!userAlive) {
      return _ObserverPanel(seconds: game.secondsLeft);
    }

    if (game.phase == GamePhase.night) {
      final action = switch (game.availableAction) {
        NightAction.kill => ('شلیک', Icons.gps_fixed_rounded),
        NightAction.save => ('نجات', Icons.health_and_safety_rounded),
        NightAction.investigate => ('استعلام', Icons.search_rounded),
        NightAction.none => ('ادامه شب', Icons.skip_next_rounded),
      };
      return _BottomPanel(
        timer: game.secondsLeft,
        hint: 'نقش شما: $role',
        label: action.$1,
        icon: action.$2,
        enabled: game.availableAction == NightAction.none || game.selectedPlayerId != null,
        onPressed: onNightAction,
      );
    }

    if (game.phase == GamePhase.dayDiscussion) {
      return _BottomPanel(
        timer: game.secondsLeft,
        hint: 'بحث روزانه؛ سپس رأی‌گیری شروع می‌شود.',
        label: 'شروع رأی‌گیری',
        icon: Icons.how_to_vote_rounded,
        enabled: true,
        onPressed: onStartVoting,
      );
    }

    return _BottomPanel(
      timer: game.secondsLeft,
      hint: game.selectedPlayerId == null ? 'یک بازیکن را برای اخراج انتخاب کن.' : 'هدف رأی: ${_nameFor(game, game.selectedPlayerId!)}',
      label: 'اخراج',
      icon: Icons.gavel_rounded,
      enabled: game.selectedPlayerId != null,
      onPressed: onVote,
    );
  }

  String _nameFor(GameState game, String id) {
    for (final player in game.players) {
      if (player.id == id) return player.name;
    }
    return 'بازیکن';
  }
}

class _BottomPanel extends StatelessWidget {
  final int timer;
  final String hint;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _BottomPanel({required this.timer, required this.hint, required this.label, required this.icon, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RadicalTheme.panel.withValues(alpha: .98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RadicalTheme.line),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, -7))],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.gold.withValues(alpha: .10)),
            child: Center(child: Text('${timer}s', style: const TextStyle(color: RadicalTheme.goldBright, fontSize: 11, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(hint, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11, fontWeight: FontWeight.w700))),
          const SizedBox(width: 9),
          FilledButton.icon(onPressed: enabled ? onPressed : null, icon: Icon(icon, size: 18), label: Text(label)),
        ],
      ),
    );
  }
}

class _ObserverPanel extends StatelessWidget {
  final int seconds;

  const _ObserverPanel({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: RadicalTheme.line)),
      child: Row(children: [
        const Icon(Icons.visibility_rounded, color: RadicalTheme.smoke),
        const SizedBox(width: 9),
        const Expanded(child: Text('شما از بازی حذف شده‌اید؛ بازی را به‌عنوان ناظر دنبال کنید.', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11, fontWeight: FontWeight.w700))),
        Text('${seconds}s', style: const TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

extension on double {
  double cos() => _cosine(this);
  double sin() => _sine(this);
}

double _cosine(double value) => value == -1.5708 ? 0 : (value == 1.5708 ? 0 : _cosApprox(value));
double _sine(double value) => _sinApprox(value);

// Small local approximations keep the table layout dependency-free.
double _cosApprox(double x) {
  const pi = 3.141592653589793;
  var y = x;
  while (y > pi) y -= 2 * pi;
  while (y < -pi) y += 2 * pi;
  final x2 = y * y;
  return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
}

double _sinApprox(double x) {
  const pi = 3.141592653589793;
  var y = x;
  while (y > pi) y -= 2 * pi;
  while (y < -pi) y += 2 * pi;
  final x2 = y * y;
  return y - y * x2 / 6 + y * x2 * x2 / 120 - y * x2 * x2 * x2 / 5040;
}

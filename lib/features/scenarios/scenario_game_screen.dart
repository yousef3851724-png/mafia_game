import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/radical_theme.dart';
import '../game/game_state.dart';
import 'custom_scenario_system.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameControllerProvider.notifier).start(
            playerCount: widget.playerCount,
            scenario: widget.scenario,
            customScenario: widget.customScenario,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final title = widget.customScenario?.name ?? widget.scenario?.title ?? 'میز رادیکال';
    final night = game.phase == GamePhase.night;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RadicalTheme.ink,
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: title, game: game),
              _PhaseBanner(game: game),
              Expanded(
                child: _GameTable(
                  players: game.players,
                  selectedId: game.selectedPlayerId,
                  night: night,
                  enabled: game.user?.alive ?? false,
                  onSelect: controller.selectPlayer,
                ),
              ),
              _ActionBar(
                game: game,
                onNight: controller.performNightAction,
                onDiscussEnd: controller.startVoting,
                onVote: controller.castVote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final GameState game;
  const _Header({required this.title, required this.game});

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
            style: IconButton.styleFrom(backgroundColor: RadicalTheme.panel2, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(phase, style: const TextStyle(color: RadicalTheme.gold, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: RadicalTheme.panel2,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: RadicalTheme.gold.withValues(alpha: .28)),
            ),
            child: Text('${game.alivePlayers.length}/${game.players.length}', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900)),
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
    final accent = ended ? RadicalTheme.gold : night ? RadicalTheme.violet : RadicalTheme.crimsonBright;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: night ? const [Color(0xDD181B30), Color(0xAA10141D)] : const [Color(0xDD321914), Color(0xAA11141B)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .36)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .11)),
            child: Icon(ended ? Icons.emoji_events_rounded : night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(game.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, height: 1.35))),
          if (!ended)
            Container(
              margin: const EdgeInsets.only(right: 7),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(color: accent.withValues(alpha: .09), borderRadius: BorderRadius.circular(10), border: Border.all(color: accent.withValues(alpha: .22))),
              child: Text('${game.secondsLeft}s', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
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
  final bool enabled;
  final ValueChanged<String> onSelect;

  const _GameTable({required this.players, required this.selectedId, required this.night, required this.enabled, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final table = (constraints.maxWidth * .46).clamp(190.0, 275.0).toDouble();
        final rx = table / 2 + 30;
        final ry = table / 2 + 24;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: table + 35,
              height: table + 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: (night ? RadicalTheme.violet : RadicalTheme.crimson).withValues(alpha: .12), blurRadius: 42, spreadRadius: 5)],
              ),
            ),
            Container(
              width: table,
              height: table,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: night ? const [Color(0xFF292744), Color(0xFF121925), RadicalTheme.ink] : const [Color(0xFF48221E), Color(0xFF1C1210), RadicalTheme.ink]),
                border: Border.all(color: (night ? RadicalTheme.gold : RadicalTheme.crimsonBright).withValues(alpha: .50), width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded, color: RadicalTheme.goldBright, size: 29),
                    const SizedBox(height: 5),
                    const Text('MAFIA', style: TextStyle(color: RadicalTheme.goldBright, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)),
                    Text(night ? 'NIGHT TABLE' : 'DAY TABLE', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 9, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < players.length; i++)
              _Seat(
                player: players[i],
                selected: players[i].id == selectedId,
                onTap: enabled && players[i].alive && !players[i].isUser ? () => onSelect(players[i].id) : null,
                offset: Offset(rx * math.cos(-math.pi / 2 + math.pi * 2 * i / players.length), ry * math.sin(-math.pi / 2 + math.pi * 2 * i / players.length)),
              ),
          ],
        );
      },
    );
  }
}

class _Seat extends StatelessWidget {
  final GamePlayer player;
  final bool selected;
  final VoidCallback? onTap;
  final Offset offset;

  const _Seat({required this.player, required this.selected, required this.onTap, required this.offset});

  @override
  Widget build(BuildContext context) {
    final accent = player.isUser ? RadicalTheme.gold : RadicalTheme.crimson;
    final initial = player.name.isEmpty ? '?' : player.name.substring(0, 1);
    final badges = <Widget>[];
    if (player.isLeader) badges.add(_SeatBadge(label: '👑 لیدر', color: RadicalTheme.gold));
    if (player.isStaff) badges.add(_SeatBadge(label: '◆ رادیکال', color: RadicalTheme.violet));

    return Transform.translate(
      offset: offset,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 92,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? RadicalTheme.gold.withValues(alpha: .12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? RadicalTheme.goldBright : Colors.transparent, width: 1.5),
            boxShadow: selected ? [BoxShadow(color: accent.withValues(alpha: .22), blurRadius: 15)] : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: player.alive ? 1 : .30,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [accent.withValues(alpha: .95), RadicalTheme.panel2])),
                  child: Center(child: Text(initial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                ),
              ),
              const SizedBox(height: 3),
              Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: player.isUser ? FontWeight.w900 : FontWeight.w700, color: player.alive ? (player.isUser ? RadicalTheme.goldBright : Colors.white) : RadicalTheme.smoke)),
              if (badges.isNotEmpty) ...[
                const SizedBox(height: 2),
                Wrap(spacing: 2, runSpacing: 2, alignment: WrapAlignment.center, children: badges),
              ],
              Text(player.alive ? '#${player.seat}' : 'حذف شد', style: TextStyle(fontSize: 8, color: player.alive ? RadicalTheme.smoke : RadicalTheme.crimsonBright)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _SeatBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: .35))),
        child: Text(label, style: TextStyle(color: color, fontSize: 6.5, fontWeight: FontWeight.w900)),
      );
}

class _ActionBar extends StatelessWidget {
  final GameState game;
  final VoidCallback onNight;
  final VoidCallback onDiscussEnd;
  final VoidCallback onVote;
  const _ActionBar({required this.game, required this.onNight, required this.onDiscussEnd, required this.onVote});

  @override
  Widget build(BuildContext context) {
    if (game.phase == GamePhase.ended) {
      return _Panel(child: Column(children: [const Icon(Icons.emoji_events_rounded, color: RadicalTheme.goldBright, size: 34), const SizedBox(height: 6), Text('برنده: ${game.winner ?? 'نامشخص'}', style: const TextStyle(fontWeight: FontWeight.w900))]));
    }
    if (!(game.user?.alive ?? false)) {
      return _Panel(child: Row(children: [const Icon(Icons.visibility_rounded, color: RadicalTheme.smoke), const SizedBox(width: 9), const Expanded(child: Text('شما حذف شده‌اید؛ بازی را به‌عنوان ناظر دنبال کنید.', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11))), Text('${game.secondsLeft}s', style: const TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900))]));
    }
    if (game.phase == GamePhase.night) {
      final action = switch (game.availableAction) {
        NightAction.kill => ('شلیک', Icons.gps_fixed_rounded),
        NightAction.save => ('نجات', Icons.health_and_safety_rounded),
        NightAction.investigate => ('استعلام', Icons.search_rounded),
        NightAction.none => ('ادامه شب', Icons.skip_next_rounded),
      };
      return _BottomAction(timer: game.secondsLeft, hint: 'نقش شما: ${game.user?.role ?? 'شهروند'}', label: action.$1, icon: action.$2, enabled: game.availableAction != NightAction.none && game.selectedPlayerId != null && !game.nightActionDone, onPressed: onNight);
    }
    if (game.phase == GamePhase.dayDiscussion) {
      return _BottomAction(timer: game.secondsLeft, hint: 'زمان بحث و تحلیل بازیکنان', label: 'پایان بحث', icon: Icons.how_to_vote_rounded, enabled: true, onPressed: onDiscussEnd);
    }
    return _BottomAction(timer: game.secondsLeft, hint: game.selectedPlayerId == null ? 'یک بازیکن را انتخاب کنید' : 'رأی شما ثبت می‌شود', label: 'ثبت رأی', icon: Icons.gavel_rounded, enabled: game.selectedPlayerId != null, onPressed: onVote);
  }
}

class _BottomAction extends StatelessWidget {
  final int timer;
  final String hint;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  const _BottomAction({required this.timer, required this.hint, required this.label, required this.icon, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) => _Panel(
        child: Row(
          children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: RadicalTheme.gold.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: RadicalTheme.goldBright)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(hint, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 10)), const SizedBox(height: 2), Text('$timer ثانیه', style: const TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900))])),
            FilledButton.icon(onPressed: enabled ? onPressed : null, icon: Icon(icon, size: 18), label: Text(label)),
          ],
        ),
      );
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: RadicalTheme.panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: RadicalTheme.line)),
        child: child,
      );
}

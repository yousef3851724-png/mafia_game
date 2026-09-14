import 'dart:math' as math;

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
  const ScenarioGameScreen({super.key, this.scenario, this.customScenario, required this.mode, required this.playerCount});
  @override
  ConsumerState<ScenarioGameScreen> createState() => _ScenarioGameScreenState();
}

class _ScenarioGameScreenState extends ConsumerState<ScenarioGameScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _emojiController;
  GamePhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    _emojiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    ref.read(gameControllerProvider.notifier).start(playerCount: widget.playerCount, scenario: widget.scenario, customScenario: widget.customScenario);
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final night = game.phase == GamePhase.night;
    final alive = game.user?.alive ?? false;
    final title = widget.customScenario?.name ?? widget.scenario?.title ?? 'میز رادیکال';
    if (_lastPhase != game.phase) {
      _lastPhase = game.phase;
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _emojiController.forward(from: 0); });
    }

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _Table(players: game.players, selected: game.selectedPlayerId, night: night, enabled: alive && game.phase != GamePhase.ended, onSelect: controller.selectPlayer),
                    if (game.phase != GamePhase.ended) _MomentEmoji(phase: game.phase, animation: _emojiController),
                  ],
                ),
              ),
              _Actions(game: game, onNight: controller.performNightAction, onDiscussEnd: controller.startVoting, onVote: controller.castVote),
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
    final phase = switch (game.phase) { GamePhase.night => 'شب ${game.round}', GamePhase.dayDiscussion => 'روز ${game.round} • بحث', GamePhase.dayVoting => 'روز ${game.round} • رأی‌گیری', GamePhase.ended => 'پایان بازی' };
    return Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 6), child: Row(children: [
      IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.close_rounded), style: IconButton.styleFrom(backgroundColor: RadicalTheme.panel2, foregroundColor: Colors.white)),
      const SizedBox(width: 7),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 2), AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: Text(phase, key: ValueKey(phase), style: const TextStyle(color: RadicalTheme.gold, fontSize: 11, fontWeight: FontWeight.w800)))])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: RadicalTheme.panel2, borderRadius: BorderRadius.circular(15), border: Border.all(color: RadicalTheme.gold.withValues(alpha: .28))), child: Text('${game.alivePlayers.length}/${game.players.length}', style: const TextStyle(color: RadicalTheme.goldBright, fontWeight: FontWeight.w900))),
    ]));
  }
}

class _PhaseBanner extends StatelessWidget {
  final GameState game;
  const _PhaseBanner({required this.game});
  @override
  Widget build(BuildContext context) {
    final night = game.phase == GamePhase.night;
    final ended = game.phase == GamePhase.ended;
    final accent = ended ? RadicalTheme.gold : night ? const Color(0xFF9C8BE0) : RadicalTheme.crimsonBright;
    return AnimatedSwitcher(duration: const Duration(milliseconds: 360), transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween(begin: const Offset(0, -.05), end: Offset.zero).animate(animation), child: child)), child: Container(key: ValueKey('${game.phase}-${game.round}'), margin: const EdgeInsets.fromLTRB(14, 2, 14, 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: night ? const [Color(0xDD181B30), Color(0xAA10141D)] : const [Color(0xDD321914), Color(0xAA11141B)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: accent.withValues(alpha: .36))), child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .11), boxShadow: [BoxShadow(color: accent.withValues(alpha: .12), blurRadius: 14)]), child: Icon(ended ? Icons.emoji_events_rounded : night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded, color: accent)),
      const SizedBox(width: 10), Expanded(child: Text(game.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, height: 1.35))),
      if (!ended) Padding(padding: const EdgeInsets.only(right: 7), child: _TimerPill(seconds: game.secondsLeft, color: accent)),
    ])));
  }
}

class _TimerPill extends StatelessWidget {
  final int seconds;
  final Color color;
  const _TimerPill({required this.seconds, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: .22))), child: Text('${seconds}s', style: TextStyle(color: color, fontWeight: FontWeight.w900)));
}

class _Table extends StatelessWidget {
  final List<GamePlayer> players;
  final String? selected;
  final bool night;
  final bool enabled;
  final ValueChanged<String> onSelect;
  const _Table({required this.players, required this.selected, required this.night, required this.enabled, required this.onSelect});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final table = (c.maxWidth * .46).clamp(190.0, 275.0).toDouble();
    final rx = table / 2 + 30;
    final ry = table / 2 + 24;
    return Stack(alignment: Alignment.center, children: [
      _TableGlow(night: night),
      AnimatedContainer(duration: const Duration(milliseconds: 700), width: table, height: table, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: night ? const [Color(0xFF292744), Color(0xFF121925), RadicalTheme.ink] : const [Color(0xFF48221E), Color(0xFF1C1210), RadicalTheme.ink]), border: Border.all(color: (night ? RadicalTheme.gold : RadicalTheme.crimsonBright).withValues(alpha: .50), width: 2)), child: Center(child: AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: Column(key: ValueKey(night), mainAxisSize: MainAxisSize.min, children: [Icon(night ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded, color: RadicalTheme.goldBright, size: 29), const SizedBox(height: 5), const Text('MAFIA', style: TextStyle(color: RadicalTheme.goldBright, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 4)), Text(night ? 'NIGHT TABLE' : 'DAY TABLE', style: const TextStyle(color: RadicalTheme.smoke, fontSize: 9, letterSpacing: 2))]))),
      ...List.generate(players.length, (i) {
        final angle = -math.pi / 2 + math.pi * 2 * i / players.length;
        final p = players[i];
        return Transform.translate(offset: Offset(rx * math.cos(angle), ry * math.sin(angle)), child: _Seat(player: p, selected: p.id == selected, active: enabled && p.alive && !p.isUser, onTap: enabled && p.alive && !p.isUser ? () => onSelect(p.id) : null));
      }),
    ]);
  });
}

class _TableGlow extends StatefulWidget {
  final bool night;
  const _TableGlow({required this.night});
  @override
  State<_TableGlow> createState() => _TableGlowState();
}
class _TableGlowState extends State<_TableGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  @override
  void initState() { super.initState(); _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true); }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _pulse, builder: (_, __) => Container(width: 335 + _pulse.value * 16, height: 335 + _pulse.value * 16, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: (widget.night ? RadicalTheme.violet : RadicalTheme.crimson).withValues(alpha: .07 + _pulse.value * .05), blurRadius: 42 + _pulse.value * 18, spreadRadius: 5)]));
}

class _Seat extends StatefulWidget {
  final GamePlayer player;
  final bool selected;
  final bool active;
  final VoidCallback? onTap;
  const _Seat({required this.player, required this.selected, required this.active, required this.onTap});
  @override
  State<_Seat> createState() => _SeatState();
}
class _SeatState extends State<_Seat> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  @override
  void initState() { super.initState(); _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true); }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final accent = widget.player.isUser ? RadicalTheme.gold : RadicalTheme.crimson;
    final highlighted = widget.selected || widget.player.isUser;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(animation: _pulse, builder: (_, __) {
        final glow = highlighted ? .10 + _pulse.value * .17 : 0.0;
        return AnimatedContainer(duration: const Duration(milliseconds: 220), width: 78, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: widget.selected ? RadicalTheme.gold.withValues(alpha: .12) : Colors.transparent, borderRadius: BorderRadius.circular(18), border: Border.all(color: widget.selected ? RadicalTheme.goldBright : Colors.transparent, width: 1.5), boxShadow: glow > 0 ? [BoxShadow(color: accent.withValues(alpha: glow), blurRadius: 15 + _pulse.value * 9, spreadRadius: 1)] : const []), child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedScale(scale: widget.selected ? 1.07 : 1, duration: const Duration(milliseconds: 180), child: Opacity(opacity: widget.player.alive ? 1 : .30, child: Container(width: 54, height: 54, padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [accent.withValues(alpha: .95), RadicalTheme.panel2]), boxShadow: highlighted ? [BoxShadow(color: accent.withValues(alpha: .24), blurRadius: 12)] : const []), child: ClipOval(child: _Avatar(widget.player.avatar))))),
          const SizedBox(height: 3), Text(widget.player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: widget.player.isUser ? FontWeight.w900 : FontWeight.w700, color: widget.player.alive ? (widget.player.isUser ? RadicalTheme.goldBright : Colors.white) : RadicalTheme.smoke)),
          Text(widget.player.alive ? '#${widget.player.seat}' : 'حذف شد', style: TextStyle(fontSize: 8, color: widget.player.alive ? RadicalTheme.smoke : RadicalTheme.crimsonBright)),
        ]);
      }),
    );
  }
}

class _Avatar extends StatelessWidget {
  final PlayerAvatar avatar;
  const _Avatar(this.avatar);
  @override
  Widget build(BuildContext context) {
    if (avatar.assetPath != null && avatar.assetPath!.isNotEmpty) return Image.asset(avatar.assetPath!, fit: BoxFit.cover);
    if (avatar.imageUrl != null && avatar.imageUrl!.isNotEmpty) return Image.network(avatar.imageUrl!, fit: BoxFit.cover);
    return RealisticAvatar(role: 'شهروند', female: avatar.female, size: 50);
  }
}

class _MomentEmoji extends StatelessWidget {
  final GamePhase phase;
  final Animation<double> animation;
  const _MomentEmoji({required this.phase, required this.animation});
  @override
  Widget build(BuildContext context) {
    final emoji = switch (phase) { GamePhase.night => '🎭', GamePhase.dayDiscussion => '😱', GamePhase.dayVoting => '🔥', GamePhase.ended => '🎉' };
    return IgnorePointer(child: FadeTransition(opacity: Tween(begin: .0, end: .22).animate(CurvedAnimation(parent: animation, curve: const Interval(0, .45, curve: Curves.easeOut))), child: ScaleTransition(scale: Tween(begin: .70, end: 1.14).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)), child: Text(emoji, style: const TextStyle(fontSize: 84))));
  }
}

class _Actions extends StatefulWidget {
  final GameState game;
  final VoidCallback onNight;
  final VoidCallback onDiscussEnd;
  final VoidCallback onVote;
  const _Actions({required this.game, required this.onNight, required this.onDiscussEnd, required this.onVote});
  @override
  State<_Actions> createState() => _ActionsState();
}

class _ActionsState extends State<_Actions> {
  int _like = 0;
  int _dislike = 0;
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    if (game.phase == GamePhase.ended) return _EndPanel(winner: game.winner, like: _like, dislike: _dislike, onLike: () => setState(() { _like++; _dislike = 0; }), onDislike: () => setState(() { _dislike++; _like = 0; }));
    if (!(game.user?.alive ?? false)) return _Panel(child: Row(children: [const Icon(Icons.visibility_rounded, color: RadicalTheme.smoke), const SizedBox(width: 9), const Expanded(child: Text('شما حذف شده‌اید؛ بازی را به‌عنوان ناظر دنبال کنید.', style: TextStyle(color: RadicalTheme.smoke, fontSize: 11))), Text('${game.secondsLeft}s', style: const TextStyle(color: RadicalTheme.gold, fontWeight: FontWeight.w900))]));
    if (game.phase == GamePhase.night) {
      final action = switch (game.availableAction) { NightAction.kill => ('شلیک', Icons.gps_fixed_rounded), NightAction.save => ('نجات', Icons.health_and_safety_rounded), NightAction.investigate => ('استعلام', Icons.search_rounded), NightAction.none => ('ادامه شب', Icons.skip_next_rounded) };
      return _BottomAction(timer: game.secondsLeft, hint: 'نقش شما: ${game.user?.role ?? 'شهروند'}', label: action.$1, icon: action.$2, enabled: game.availableAction == NightAction.none || game.selectedPlayerId != null, onPressed: widget.onNight);
    }
    if (game.phase == GamePhase.dayDiscussion) return _BottomAction(timer: game.secondsLeft, hint: 'بحث روزانه؛ بعد از پایان بحث رأی‌گیری شروع می‌شود.', label: 'شروع رأی‌گیری', icon: Icons.how_to_vote_rounded, enabled: true, onPressed: widget.onDiscussEnd);
    return _BottomAction(timer: game.secondsLeft, hint: game.selectedPlayerId == null ? 'یک بازیکن را برای اخراج انتخاب کن.' : 'هدف رأی انتخاب شد.', label: 'اخراج', icon: Icons.gavel_rounded, enabled: game.selectedPlayerId != null, onPressed: widget.onVote);
  }
}

class _EndPanel extends StatelessWidget {
  final String? winner;
  final int like;
  final int dislike;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  const _EndPanel({required this.winner, required this.like, required this.dislike, required this.onLike, required this.onDislike});
  @override
  Widget build(BuildContext context) => _Panel(child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.emoji_events_rounded, color: RadicalTheme.goldBright, size: 30), const SizedBox(width: 9), Text('برنده: ${winner ?? 'نامشخص'}', style: const TextStyle(color: RadicalTheme.goldBright, fontSize: 19, fontWeight: FontWeight.w900))]), const SizedBox(height: 11), Row(children: [_ReactionButton(icon: '👍', label: 'لایک', count: like, active: like > 0, color: RadicalTheme.goldBright, onTap: onLike), const SizedBox(width: 9), _ReactionButton(icon: '👎', label: 'دیس‌لایک', count: dislike, active: dislike > 0, color: RadicalTheme.crimsonBright, onTap: onDislike)])]));
}

class _ReactionButton extends StatefulWidget {
  final String icon;
  final String label;
  final int count;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _ReactionButton({required this.icon, required this.label, required this.count, required this.active, required this.color, required this.onTap});
  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}
class _ReactionButtonState extends State<_ReactionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320)); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    return Expanded(child: FadeTransition(opacity: Tween(begin: .72, end: 1.0).animate(curve), child: ScaleTransition(scale: Tween(begin: .90, end: 1.0).animate(curve), child: Material(color: Colors.transparent, child: InkWell(onTap: () { _controller.forward(from: 0); widget.onTap(); }, borderRadius: BorderRadius.circular(15), splashColor: widget.color.withValues(alpha: .20), highlightColor: widget.color.withValues(alpha: .08), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: widget.active ? widget.color.withValues(alpha: .12) : RadicalTheme.panel2, borderRadius: BorderRadius.circular(15), border: Border.all(color: widget.active ? widget.color.withValues(alpha: .48) : RadicalTheme.line), boxShadow: widget.active ? [BoxShadow(color: widget.color.withValues(alpha: .14), blurRadius: 16)] : const []), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.icon, style: const TextStyle(fontSize: 18)), const SizedBox(width: 6), Text(widget.label, style: TextStyle(fontWeight: FontWeight.w900, color: widget.active ? widget.color : Colors.white)), if (widget.count > 0) ...[const SizedBox(width: 6), Text('${widget.count}', style: TextStyle(color: widget.color, fontWeight: FontWeight.w900))]]))))));
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
  Widget build(BuildContext context) => _Panel(child: Row(children: [Container(width: 43, height: 43, decoration: BoxDecoration(shape: BoxShape.circle, color: RadicalTheme.gold.withValues(alpha: .10)), child: Center(child: Text('${timer}s', style: const TextStyle(color: RadicalTheme.goldBright, fontSize: 11, fontWeight: FontWeight.w900)))), const SizedBox(width: 10), Expanded(child: Text(hint, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RadicalTheme.smoke, fontSize: 11, fontWeight: FontWeight.w700))), const SizedBox(width: 9), _AnimatedActionButton(label: label, icon: icon, enabled: enabled, onPressed: onPressed)]));
}

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  const _AnimatedActionButton({required this.label, required this.icon, required this.enabled, required this.onPressed});
  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}
class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => Listener(onPointerDown: (_) => setState(() => _down = true), onPointerUp: (_) => setState(() => _down = false), onPointerCancel: (_) => setState(() => _down = false), child: AnimatedScale(scale: _down ? .94 : 1, duration: const Duration(milliseconds: 100), curve: Curves.easeOut, child: FilledButton.icon(onPressed: widget.enabled ? widget.onPressed : null, icon: Icon(widget.icon, size: 18), label: Text(widget.label), style: FilledButton.styleFrom(backgroundColor: RadicalTheme.gold, foregroundColor: RadicalTheme.ink, splashFactory: InkRipple.splashFactory, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))).copyWith(overlayColor: WidgetStatePropertyAll(RadicalTheme.goldBright.withValues(alpha: .22))))));
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.fromLTRB(14, 0, 14, 14), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: RadicalTheme.panel.withValues(alpha: .98), borderRadius: BorderRadius.circular(22), border: Border.all(color: RadicalTheme.line), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, -7))]), child: child);
}
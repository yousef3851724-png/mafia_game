import 'package:flutter/material.dart';
import '../../domain/entities/game_phase.dart';
import '../../domain/entities/game_role.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/player.dart';
import '../../domain/services/game_engine.dart';

class GameTestScreen extends StatefulWidget {
  const GameTestScreen({super.key});

  @override
  State<GameTestScreen> createState() => _GameTestScreenState();
}

class _GameTestScreenState extends State<GameTestScreen> {
  final GameEngine _engine = GameEngine();
  late GameSession _session;
  int _playerCounter = 0;
  String? _message;

  @override
  void initState() {
    super.initState();
    _session = _engine.createSession('TEST-001');
  }

  void _addPlayer() {
    if (_session.phaseState.phase != GamePhase.lobby) return;
    _playerCounter++;
    final player = Player(
      id: 'test_player_$_playerCounter',
      name: 'بازیکن $_playerCounter',
    );
    setState(() {
      _session = _engine.addPlayer(_session, player);
      _message = '${player.name} وارد اتاق شد.';
    });
  }

  void _startGame() {
    try {
      setState(() {
        _session = _engine.startGame(_session);
        _message = 'بازی شروع شد و نقش‌ها اختصاص داده شدند.';
      });
    } catch (e) {
      setState(() => _message = e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  void _nextPhase() {
    if (_session.phaseState.phase == GamePhase.ended) return;
    setState(() {
      _session = _engine.advancePhase(_session);
      _message = 'فاز بازی به «${_session.phaseState.phase.title}» تغییر کرد.';
    });
  }

  void _removePlayer(Player player) {
    if (_session.phaseState.phase != GamePhase.lobby) return;
    setState(() {
      _session = _engine.removePlayer(_session, player.id);
      _message = '${player.name} از اتاق خارج شد.';
    });
  }

  String _roleFor(String playerId) {
    for (final assignment in _session.assignedRoles) {
      if (assignment.playerId == playerId) return assignment.role.title;
    }
    return 'تعیین نشده';
  }

  @override
  Widget build(BuildContext context) {
    final phase = _session.phaseState.phase;
    final canStart = _session.players.length >= GameEngine.minimumPlayers &&
        phase == GamePhase.lobby;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تست موتور مافیا رادیکال'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('اتاق ${_session.roomId}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('فاز فعلی: ${phase.title}'),
                    Text('راند: ${_session.round}'),
                    Text('تعداد بازیکنان: ${_session.players.length}'),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(_message!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: phase == GamePhase.lobby ? _addPlayer : null,
                  icon: const Icon(Icons.person_add),
                  label: const Text('افزودن بازیکن'),
                ),
                FilledButton.icon(
                  onPressed: canStart ? _startGame : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('شروع بازی'),
                ),
                OutlinedButton.icon(
                  onPressed: phase == GamePhase.lobby ? null : _nextPhase,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('فاز بعد'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('بازیکنان', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_session.players.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('هنوز بازیکنی وارد نشده است.')),
                ),
              )
            else
              ..._session.players.map(
                (player) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${_session.players.indexOf(player) + 1}')),
                    title: Text(player.name),
                    subtitle: Text(
                      player.isHost
                          ? 'میزبان • نقش: ${_roleFor(player.id)}'
                          : 'نقش: ${_roleFor(player.id)}',
                    ),
                    trailing: phase == GamePhase.lobby
                        ? IconButton(
                            tooltip: 'حذف',
                            onPressed: () => _removePlayer(player),
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('نقش‌های اختصاص‌یافته', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_session.assignedRoles.isEmpty)
                      const Text('پس از شروع بازی نمایش داده می‌شوند.')
                    else
                      ..._session.assignedRoles.map(
                        (assignment) => ListTile(
                          dense: true,
                          leading: Icon(
                            assignment.role.team == RoleTeam.mafia ? Icons.visibility_off : Icons.shield,
                          ),
                          title: Text(
                            _session.players
                                .firstWhere(
                                  (p) => p.id == assignment.playerId,
                                  orElse: () => const Player(id: '', name: 'بازیکن حذف‌شده'),
                                )
                                .name,
                          ),
                          trailing: Text(assignment.role.title),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

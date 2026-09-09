import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MafiaGame());

class MafiaGame extends StatelessWidget {
  const MafiaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مایفا رادیکال',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0e14),
        primaryColor: const Color(0xFFd4af87),
      ),
      home: const LobbyScreen(),
    );
  }
}

// =========================== لابی ===========================
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String selectedRole = 'citizen';
  final List<Map<String, String>> roles = const [
    {'label': '👤 شهروند', 'value': 'citizen'},
    {'label': '💉 دکتر', 'value': 'doctor'},
    {'label': '🔍 کارآگاه', 'value': 'detective'},
    {'label': '🔪 مافیا', 'value': 'mafia'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _vpnBadge(),
              const SizedBox(height: 16),
              const Text('مایفا رادیکال', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFd4af87))),
              const Text('به بازی مافیا خوش آمدید!', style: TextStyle(fontSize: 18, color: Color(0xFFaab))),
              const SizedBox(height: 30),
              const Text('🎭 نقش خود را انتخاب کنید', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFd4af87))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: roles.map((role) {
                  return ChoiceChip(
                    label: Text(role['label']!),
                    selected: selectedRole == role['value'],
                    onSelected: (sel) => setState(() => selectedRole = role['value']!),
                    backgroundColor: const Color(0xFF2a3448),
                    selectedColor: const Color(0xFFd4af87),
                    labelStyle: TextStyle(color: selectedRole == role['value'] ? Colors.black : Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(userRole: selectedRole))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af87),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('▶ شروع بازی'),
                ),
              ),
              const Spacer(),
              const Center(child: Text('⏳ منتظر شروع بازی...', style: TextStyle(color: Color(0xFF8892a8)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vpnBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(30)),
      child: const Text('🔒 ۱۰۰٪ VPN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}

// =========================== بازی اصلی ===========================
class GameScreen extends StatefulWidget {
  final String userRole;
  const GameScreen({super.key, required this.userRole});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine engine;
  List<String> logs = [];
  String phaseText = '';

  @override
  void initState() {
    super.initState();
    engine = GameEngine(userRole: widget.userRole, onUpdate: updateUI);
    engine.startGame();
  }

  void updateUI(String msg, {String type = ''}) {
    setState(() {
      logs.add(msg);
      phaseText = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مایفا رادیکال', style: TextStyle(color: Color(0xFFd4af87))),
        backgroundColor: const Color(0xFF0a0e14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFd4af87)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _statusBar(),
              const SizedBox(height: 12),
              _playersGrid(),
              const SizedBox(height: 12),
              _actionArea(),
              const SizedBox(height: 12),
              Expanded(child: _logArea()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar() {
    String status = engine.phase == 'idle' ? '⏳ در انتظار...' :
                    engine.phase == 'day' ? '☀️ روز ${engine.day}' :
                    engine.phase == 'night' ? '🌙 شب ${engine.day}' :
                    '🏁 پایان بازی';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1e2634), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(status, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFd4af87))),
          Text('👥 ${engine.alivePlayers.length} زنده', style: const TextStyle(color: Color(0xFF8892a8))),
        ],
      ),
    );
  }

  Widget _playersGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1e2634), borderRadius: BorderRadius.circular(16)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: engine.players.map((p) {
          bool dead = !p.isAlive;
          bool isUser = p.id == engine.userId;
          String label = isUser ? '⭐ ${p.name}' : p.name;
          if (dead || engine.phase == 'gameover') label += ' (${roleName(p.role)})';
          return GestureDetector(
            onTap: () {
              if (engine.user.isAlive && p.isAlive && !isUser && !engine.isProcessing) {
                engine.selectTarget(p.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: dead ? const Color(0xFF2a2a2a) : const Color(0xFF2a3448),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: dead ? const Color(0xFF5a2a2a) : const Color(0xFF3f4b62)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: dead ? Colors.grey[600] : Colors.white,
                  decoration: dead ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _actionArea() {
    String content = '';
    if (engine.phase == 'day' && engine.user.isAlive) content = '✅ روی یک بازیکن زنده کلیک کنید تا رای دهید.';
    else if (engine.phase == 'night' && engine.user.isAlive) {
      if (engine.user.role == 'mafia') content = '🔪 روی یک نفر کلیک کنید تا بکشید.';
      else if (engine.user.role == 'doctor') content = '💉 روی یک نفر کلیک کنید تا نجات دهید.';
      else if (engine.user.role == 'detective') content = '🔍 روی یک نفر کلیک کنید تا بررسی کنید.';
      else content = '🌙 شب شد، شما می‌خوابید...';
    } else if (!engine.user.isAlive) content = '💀 شما مرده‌اید. تماشا کنید...';
    else content = '⏳ در حال پردازش...';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1e2634), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: Text(content, style: const TextStyle(color: Color(0xFF8892a8)))),
          if (engine.phase == 'gameover')
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بازگشت'),
            ),
        ],
      ),
    );
  }

  Widget _logArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0f151e), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF293242))),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: logs.reversed.map((msg) {
            Color color = Colors.white70;
            if (msg.contains('🎉') || msg.contains('پیروز')) color = const Color(0xFFf7c948);
            else if (msg.contains('💀') || msg.contains('کشته')) color = const Color(0xFFff5e6b);
            else if (msg.contains('🛡️') || msg.contains('نجات')) color = const Color(0xFF6fc3ff);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(msg, style: TextStyle(color: color, fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String roleName(String role) {
    switch (role) {
      case 'mafia': return '🔪 مافیا';
      case 'doctor': return '💉 دکتر';
      case 'detective': return '🔍 کارآگاه';
      default: return '👤 شهروند';
    }
  }
}

// =========================== موتور بازی ===========================
class Player {
  int id;
  String name;
  String role;
  bool isAlive;
  bool isUser;

  Player({required this.id, required this.name, required this.role, this.isAlive = true, this.isUser = false});
}

class GameEngine {
  final String userRole;
  final Function(String, {String type}) onUpdate;

  List<Player> players = [];
  int userId = 0;
  String phase = 'idle'; // idle, day, night, gameover
  int day = 1;
  bool isProcessing = false;
  Map<int, int> votes = {};
  Map<String, int?> nightActions = {'kill': null, 'heal': null, 'investigate': null};

  GameEngine({required this.userRole, required this.onUpdate});

  void startGame() {
    _initPlayers();
    onUpdate('🎭 شما نقش ${_roleName(userRole)} را دارید.');
    phase = 'day';
    _startNewDay();
  }

  void _initPlayers() {
    List<String> names = ['شما', 'ربات آرین', 'ربات سارا', 'ربات کیان', 'ربات لیلا', 'ربات امیر', 'ربات ندا', 'ربات پویا'];
    List<String> roles = ['citizen', 'citizen', 'citizen', 'citizen', 'mafia', 'mafia', 'doctor', 'detective'];
    roles.shuffle(Random());
    players = List.generate(names.length, (i) => Player(id: i, name: names[i], role: roles[i], isUser: i == 0));
    players[0].role = userRole;
    _rebalanceRoles();
    userId = 0;
  }

  void _rebalanceRoles() {
    var bots = players.where((p) => p.id != 0).toList();
    Map<String, int> need = {'mafia': 2, 'doctor': 1, 'detective': 1, 'citizen': 4};
    need[userRole] = need[userRole]! - 1;
    List<String> target = [];
    need.forEach((key, val) { for (int i=0; i<val; i++) target.add(key); });
    target.shuffle(Random());
    for (int i=0; i<bots.length; i++) {
      bots[i].role = target[i % target.length];
    }
  }

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();
  List<Player> get mafiaAlive => players.where((p) => p.isAlive && p.role == 'mafia').toList();
  List<Player> get townAlive => players.where((p) => p.isAlive && p.role != 'mafia').toList();
  Player get user => players.firstWhere((p) => p.id == userId);

  void _startNewDay() {
    if (_checkGameOver()) return;
    phase = 'day';
    votes.clear();
    onUpdate('--- روز $day ---');
    if (!user.isAlive) {
      onUpdate('💀 شما مرده‌اید. تماشا کنید...');
      Future.delayed(Duration(seconds: 2), () => _aiVoteAndExecute());
      return;
    }
    onUpdate('👤 روی یک بازیکن زنده کلیک کنید تا رای دهید.');
  }

  void startNight() {
    if (_checkGameOver()) return;
    phase = 'night';
    nightActions = {'kill': null, 'heal': null, 'investigate': null};
    onUpdate('--- شب $day ---');
    if (!user.isAlive) {
      _doAIActions();
      Future.delayed(Duration(seconds: 1), () => _resolveNight());
      return;
    }
    if (user.role == 'mafia') onUpdate('🔪 روی یک نفر کلیک کنید تا بکشید.');
    else if (user.role == 'doctor') onUpdate('💉 روی یک نفر کلیک کنید تا نجات دهید.');
    else if (user.role == 'detective') onUpdate('🔍 روی یک نفر کلیک کنید تا بررسی کنید.');
    else {
      onUpdate('👤 شب شد، شما می‌خوابید...');
      _doAIActions();
      Future.delayed(Duration(seconds: 1), () => _resolveNight());
    }
  }

  void selectTarget(int id) {
    if (isProcessing) return;
    var target = players.firstWhere((p) => p.id == id, orElse: () => Player(id: -1, name: '', role: ''));
    if (target.id == -1 || !target.isAlive || target.id == userId) return;

    if (phase == 'day') {
      votes[userId] = id;
      onUpdate('🗳️ شما به ${target.name} رای دادید.');
      _aiVoteAndExecute();
      return;
    }
    if (phase == 'night') {
      if (user.role == 'mafia') nightActions['kill'] = id;
      else if (user.role == 'doctor') nightActions['heal'] = id;
      else if (user.role == 'detective') {
        nightActions['investigate'] = id;
        onUpdate('🔍 ${target.name} → ${_roleName(target.role)}');
      }
      _doAIActions();
      Future.delayed(Duration(seconds: 1), () => _resolveNight());
    }
  }

  void _doAIActions() {
    var alive = alivePlayers;
    var mafias = mafiaAlive;
    if (mafias.isNotEmpty && nightActions['kill'] == null) {
      var targets = alive.where((p) => p.role != 'mafia').toList();
      if (targets.isNotEmpty) nightActions['kill'] = targets[Random().nextInt(targets.length)].id;
    }
    var docs = players.where((p) => p.isAlive && p.role == 'doctor' && !p.isUser).toList();
    if (docs.isNotEmpty && nightActions['heal'] == null) {
      var targets = alive.where((p) => p.role != 'doctor').toList();
      if (targets.isNotEmpty) nightActions['heal'] = targets[Random().nextInt(targets.length)].id;
    }
    var dets = players.where((p) => p.isAlive && p.role == 'detective' && !p.isUser).toList();
    if (dets.isNotEmpty && nightActions['investigate'] == null) {
      var targets = alive.where((p) => p.role == 'mafia' || p.role == 'detective').toList();
      if (targets.isNotEmpty) {
        var t = targets[Random().nextInt(targets.length)];
        nightActions['investigate'] = t.id;
      }
    }
  }

  void _resolveNight() {
    if (isProcessing) return;
    isProcessing = true;
    int? killId = nightActions['kill'];
    int? healId = nightActions['heal'];
    if (killId != null) {
      var target = players.firstWhere((p) => p.id == killId, orElse: () => Player(id: -1, name: '', role: ''));
      if (target.id != -1 && target.isAlive) {
        if (healId == killId) {
          onUpdate('🛡️ ${target.name} توسط دکتر نجات یافت!');
        } else {
          target.isAlive = false;
          onUpdate('💀 ${target.name} (${_roleName(target.role)}) کشته شد.');
        }
      }
    } else {
      onUpdate('🌙 شب آرام بود.');
    }
    if (_checkGameOver()) { isProcessing = false; return; }
    day++;
    isProcessing = false;
    _startNewDay();
  }

  void _aiVoteAndExecute() {
    if (isProcessing) return;
    isProcessing = true;
    var alive = alivePlayers;
    for (var p in alive) {
      if (p.isUser) continue;
      var targets = alive.where((t) => t.id != p.id).toList();
      if (targets.isNotEmpty) votes[p.id] = targets[Random().nextInt(targets.length)].id;
    }
    Map<int, int> count = {};
    votes.forEach((_, targetId) { count[targetId] = (count[targetId] ?? 0) + 1; });
    int max = 0;
    int? eliminated;
    count.forEach((id, c) { if (c > max) { max = c; eliminated = id; } });
    if (eliminated != null) {
      var p = players.firstWhere((e) => e.id == eliminated, orElse: () => Player(id: -1, name: '', role: ''));
      if (p.id != -1 && p.isAlive) {
        p.isAlive = false;
        onUpdate('⚖️ ${p.name} (${_roleName(p.role)}) اخراج شد.');
      }
    } else {
      onUpdate('🤝 هیچکس اخراج نشد.');
    }
    if (_checkGameOver()) { isProcessing = false; return; }
    isProcessing = false;
    Future.delayed(Duration(seconds: 1), () => startNight());
  }

  bool _checkGameOver() {
    int m = mafiaAlive.length;
    int t = townAlive.length;
    if (m == 0) { phase = 'gameover'; onUpdate('🎉 شهروندان پیروز شدند!'); return true; }
    if (m >= t) { phase = 'gameover'; onUpdate('💀 مافیاها پیروز شدند!'); return true; }
    return false;
  }

  String _roleName(String role) {
    switch (role) {
      case 'mafia': return '🔪 مافیا';
      case 'doctor': return '💉 دکتر';
      case 'detective': return '🔍 کارآگاه';
      default: return '👤 شهروند';
    }
  }
}
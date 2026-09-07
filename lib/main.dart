import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MafiaRadicalApp());
}

class MafiaRadicalApp extends StatelessWidget {
  const MafiaRadicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مافیا رادیکال',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121217),
        primaryColor: const Color(0xFFE53935),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935),
          secondary: Color(0xFFFF5252),
          surface: Color(0xFF1E1E26),
        ),
        cardColor: const Color(0xFF1E1E26),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white),
        ),
      ),
      home: const MainGameFlow(),
    );
  }
}

// ---------------------------------------------------------------------------
// MODELS & ENUMS
// ---------------------------------------------------------------------------

enum Role { godfather, mafia, doctor, detective, sniper, citizen }
enum Team { mafia, citizen }
enum GamePhase { setup, roleReveal, night, morningReport, dayDiscussion, voting, gameOver }

class Player {
  final String id;
  final String name;
  final Role role;
  bool isAlive;
  bool isProtected;
  int votesReceived;

  Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.isProtected = false,
    this.votesReceived = 0,
  });

  Team get team => (role == Role.godfather || role == Role.mafia) ? Team.mafia : Team.citizen;

  String get roleNameFa {
    switch (role) {
      case Role.godfather:
        return 'پدرخوانده';
      case Role.mafia:
        return 'مافیا ساده';
      case Role.doctor:
        return 'دکتر';
      case Role.detective:
        return 'کارآگاه';
      case Role.sniper:
        return 'اسنایپر (تک‌تیرانداز)';
      case Role.citizen:
        return 'شهروند ساده';
    }
  }

  IconData get roleIcon {
    switch (role) {
      case Role.godfather:
      case Role.mafia:
        return Icons.local_fire_department;
      case Role.doctor:
        return Icons.medical_services_outlined;
      case Role.detective:
        return Icons.search;
      case Role.sniper:
        return Icons.my_location;
      case Role.citizen:
        return Icons.person_outline;
    }
  }
}

// ---------------------------------------------------------------------------
// MAIN GAME CONTROLLER & UI
// ---------------------------------------------------------------------------

class MainGameFlow extends StatefulWidget {
  const MainGameFlow({super.key});

  @override
  State<MainGameFlow> createState() => _MainGameFlowState();
}

class _MainGameFlowState extends State<MainGameFlow> {
  GamePhase currentPhase = GamePhase.setup;

  // Setup State
  final List<TextEditingController> _playerControllers = [
    TextEditingController(text: 'بازیکن ۱'),
    TextEditingController(text: 'بازیکن ۲'),
    TextEditingController(text: 'بازیکن ۳'),
    TextEditingController(text: 'بازیکن ۴'),
    TextEditingController(text: 'بازیکن ۵'),
    TextEditingController(text: 'بازیکن ۶'),
  ];

  Map<Role, int> roleCounts = {
    Role.godfather: 1,
    Role.mafia: 1,
    Role.doctor: 1,
    Role.detective: 1,
    Role.sniper: 0,
    Role.citizen: 2,
  };

  // Game Engine State
  List<Player> players = [];
  int dayNumber = 1;
  int currentRevealIndex = 0;
  bool isCardRevealed = false;

  // Night State
  int nightStep = 0; // 0: Mafia Kill, 1: Doctor Heal, 2: Detective Check, 3: Sniper Shot
  Player? mafiaTarget;
  Player? doctorTarget;
  Player? sniperTarget;
  String? detectiveInquiryResult;
  List<String> nightReport = [];

  // Discussion & Timer
  Timer? _gameTimer;
  int _remainingSeconds = 45;
  bool _isTimerRunning = false;
  int currentSpeakerIndex = 0;

  // Winner State
  String winnerMessage = '';

  @override
  void dispose() {
    _gameTimer?.cancel();
    for (var c in _playerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    int totalRoles = roleCounts.values.fold(0, (a, b) => a + b);
    if (totalRoles != _playerControllers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعداد نقش‌ها ($totalRoles) با تعداد بازیکنان (${_playerControllers.length}) برابر نیست!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    List<Role> roleDeck = [];
    roleCounts.forEach((role, count) {
      for (int i = 0; i < count; i++) {
        roleDeck.add(role);
      }
    });
    roleDeck.shuffle();

    players = List.generate(_playerControllers.length, (index) {
      return Player(
        id: 'p_$index',
        name: _playerControllers[index].text.trim().isEmpty
            ? 'بازیکن ${index + 1}'
            : _playerControllers[index].text.trim(),
        role: roleDeck[index],
      );
    });

    setState(() {
      currentRevealIndex = 0;
      isCardRevealed = false;
      currentPhase = GamePhase.roleReveal;
    });
  }

  void _checkGameOver() {
    int aliveMafia = players.where((p) => p.isAlive && p.team == Team.mafia).length;
    int aliveCitizens = players.where((p) => p.isAlive && p.team == Team.citizen).length;

    if (aliveMafia == 0) {
      setState(() {
        winnerMessage = '🏆 شهروندان پیروز شدند! تمام مافیاها حذف شدند.';
        currentPhase = GamePhase.gameOver;
      });
    } else if (aliveMafia >= aliveCitizens) {
      setState(() {
        winnerMessage = '🔥 مافیا پیروز شد! کنترل شهر در دست مافیا قرار گرفت.';
        currentPhase = GamePhase.gameOver;
      });
    }
  }

  void _processNightResults() {
    nightReport.clear();
    List<Player> killedTonight = [];

    // Doctor Protection
    if (doctorTarget != null) {
      doctorTarget!.isProtected = true;
    }

    // Mafia Attack
    if (mafiaTarget != null) {
      if (mafiaTarget != doctorTarget) {
        killedTonight.add(mafiaTarget!);
      }
    }

    // Sniper Shot
    if (sniperTarget != null) {
      if (sniperTarget!.team == Team.mafia) {
        killedTonight.add(sniperTarget!);
      } else {
        // Sniper penalty: dies if shoots citizen
        final sniper = players.firstWhere((p) => p.role == Role.sniper, orElse: () => players.first);
        if (sniper.role == Role.sniper) killedTonight.add(sniper);
      }
    }

    // Apply deaths
    for (var victim in killedTonight) {
      victim.isAlive = false;
    }

    if (killedTonight.isEmpty) {
      nightReport.add('شب آرامی بود و خوشبختانه هیچ‌کس کشته نشد!');
    } else {
      for (var victim in killedTonight.toSet()) {
        nightReport.add('متأسفانه ${victim.name} در طول شب از بازی حذف شد.');
      }
    }

    // Reset night flags
    for (var p in players) {
      p.isProtected = false;
    }
    mafiaTarget = null;
    doctorTarget = null;
    sniperTarget = null;
    detectiveInquiryResult = null;
    nightStep = 0;

    _checkGameOver();
    if (currentPhase != GamePhase.gameOver) {
      setState(() {
        currentPhase = GamePhase.morningReport;
      });
    }
  }

  void _startTimer(int seconds) {
    _gameTimer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
      _isTimerRunning = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _isTimerRunning = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E26),
          elevation: 0,
          centerTitle: true,
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if (currentPhase != GamePhase.setup)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                tooltip: 'شروع مجدد',
                onPressed: () {
                  setState(() {
                    currentPhase = GamePhase.setup;
                    dayNumber = 1;
                  });
                },
              )
          ],
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentPhaseWidget(),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (currentPhase) {
      case GamePhase.setup:
        return 'مافیا رادیکال | تنظیمات بازی';
      case GamePhase.roleReveal:
        return 'توزیع کارت‌ها';
      case GamePhase.night:
        return 'فاز شب $dayNumber 🌙';
      case GamePhase.morningReport:
        return 'گزارش صبح روز $dayNumber ☀️';
      case GamePhase.dayDiscussion:
        return 'گفت‌وگو و نوبت روز $dayNumber 🗣️';
      case GamePhase.voting:
        return 'دادگاه و رأی‌گیری ⚖️';
      case GamePhase.gameOver:
        return 'پایان بازی 🏁';
    }
  }

  Widget _buildCurrentPhaseWidget() {
    switch (currentPhase) {
      case GamePhase.setup:
        return _buildSetupView();
      case GamePhase.roleReveal:
        return _buildRoleRevealView();
      case GamePhase.night:
        return _buildNightView();
      case GamePhase.morningReport:
        return _buildMorningReportView();
      case GamePhase.dayDiscussion:
        return _buildDayDiscussionView();
      case GamePhase.voting:
        return _buildVotingView();
      case GamePhase.gameOver:
        return _buildGameOverView();
    }
  }

  // ---------------------------------------------------------------------------
  // 1. SETUP VIEW
  // ---------------------------------------------------------------------------
  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            title: 'بازیکنان (${_playerControllers.length} نفر)',
            trailing: IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFFE53935)),
              onPressed: () {
                setState(() {
                  _playerControllers.add(TextEditingController(text: 'بازیکن ${_playerControllers.length + 1}'));
                });
              },
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _playerControllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _playerControllers[index],
                        decoration: InputDecoration(
                          hintText: 'نام بازیکن',
                          filled: true,
                          fillColor: const Color(0xFF14141A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    if (_playerControllers.length > 4)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _playerControllers.removeAt(index);
                          });
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'چینش نقش‌ها',
            child: Column(
              children: roleCounts.keys.map((role) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_getRoleIcon(role), color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(_getRoleTitle(role)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: roleCounts[role]! > 0
                              ? () => setState(() => roleCounts[role] = roleCounts[role]! - 1)
                              : null,
                        ),
                        Text('${roleCounts[role]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => roleCounts[role] = roleCounts[role]! + 1),
                        ),
                      ],
                    )
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _startGame,
            child: const Text('شروع و پخش کارت‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. ROLE REVEAL VIEW (PASS & PLAY)
  // ---------------------------------------------------------------------------
  Widget _buildRoleRevealView() {
    final player = players[currentRevealIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('گوشی را به دست بدهید به:', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
            const SizedBox(height: 8),
            Text(player.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => setState(() => isCardRevealed = !isCardRevealed),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 300,
                width: 220,
                decoration: BoxDecoration(
                  color: isCardRevealed ? const Color(0xFF1E1E26) : const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isCardRevealed ? Colors.black : Colors.red).withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ],
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Center(
                  child: isCardRevealed
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(player.roleIcon, size: 72, color: player.team == Team.mafia ? Colors.redAccent : Colors.lightBlueAccent),
                            const SizedBox(height: 16),
                            Text(player.roleNameFa, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(player.team == Team.mafia ? 'تیم مافیا' : 'تیم شهروند', style: TextStyle(color: Colors.grey[400])),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app, size: 60, color: Colors.white),
                            SizedBox(height: 12),
                            Text('لمس برای مشاهده نقش', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (currentRevealIndex < players.length - 1) {
                  setState(() {
                    currentRevealIndex++;
                    isCardRevealed = false;
                  });
                } else {
                  setState(() {
                    currentPhase = GamePhase.night;
                    nightStep = 0;
                  });
                }
              },
              child: Text(currentRevealIndex < players.length - 1 ? 'نفر بعدی ❯' : 'ورود به شب اول 🌙'),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. NIGHT VIEW
  // ---------------------------------------------------------------------------
  Widget _buildNightView() {
    List<Player> alivePlayers = players.where((p) => p.isAlive).toList();

    String title = '';
    String instruction = '';
    Player? selectedTarget;
    Function(Player)? onSelect;

    if (nightStep == 0) {
      title = '🔥 نوبت شلیک مافیا';
      instruction = 'تیم مافیا یک نفر را برای شلیک انتخاب کند:';
      selectedTarget = mafiaTarget;
      onSelect = (p) => setState(() => mafiaTarget = p);
    } else if (nightStep == 1) {
      title = '💉 نوبت دکتر';
      instruction = 'دکتر یک نفر را برای نجات انتخاب کند:';
      selectedTarget = doctorTarget;
      onSelect = (p) => setState(() => doctorTarget = p);
    } else if (nightStep == 2) {
      title = '🔍 استعلام کارآگاه';
      instruction = 'کارآگاه استعلام یک نفر را می‌گیرد:';
      selectedTarget = null;
      onSelect = (p) {
        setState(() {
          // Godfather returns negative/citizen inquiry
          detectiveInquiryResult = (p.role == Role.mafia) ? 'مثبت (مافیا است!) 🚨' : 'منفی (شهروند/پاک) ✅';
        });
      };
    } else if (nightStep == 3) {
      title = '🎯 شلیک اسنایپر';
      instruction = 'تک‌تیرانداز می‌تواند شلیک کند (یا رد شود):';
      selectedTarget = sniperTarget;
      onSelect = (p) => setState(() => sniperTarget = p);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 8),
          Text(instruction, style: TextStyle(color: Colors.grey[300])),
          const SizedBox(height: 16),
          if (detectiveInquiryResult != null && nightStep == 2)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
              child: Text('نتیجه استعلام: $detectiveInquiryResult', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: alivePlayers.length,
              itemBuilder: (context, index) {
                final p = alivePlayers[index];
                final isSelected = selectedTarget == p;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.redAccent.withOpacity(0.3) : const Color(0xFF1E1E26),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? Colors.redAccent : Colors.transparent),
                  ),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.redAccent) : null,
                    onTap: () => onSelect?.call(p),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (nightStep < 3) {
                setState(() => nightStep++);
              } else {
                _processNightResults();
              }
            },
            child: Text(nightStep < 3 ? 'گام بعدی شب ❯' : 'طلوع آفتاب و گزارش صبح ☀️'),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. MORNING REPORT VIEW
  // ---------------------------------------------------------------------------
  Widget _buildMorningReportView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.wb_sunny_rounded, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          Text('وقایع رخ داده در شب $dayNumber:', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...nightReport.map((rep) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: const Color(0xFF1E1E26), borderRadius: BorderRadius.circular(8)),
                child: Text(rep, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              )),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              setState(() {
                currentPhase = GamePhase.dayDiscussion;
                currentSpeakerIndex = 0;
                _startTimer(45);
              });
            },
            child: const Text('آغاز صحبت‌های روز 🗣️'),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. DAY DISCUSSION & TIMERS
  // ---------------------------------------------------------------------------
  Widget _buildDayDiscussionView() {
    List<Player> alivePlayers = players.where((p) => p.isAlive).toList();
    final currentSpeaker = alivePlayers[currentSpeakerIndex % alivePlayers.length];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCard(
            title: 'نوبت صحبت فعلی',
            child: Column(
              children: [
                Text(currentSpeaker.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber)),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 110,
                      width: 110,
                      child: CircularProgressIndicator(
                        value: _remainingSeconds / 45,
                        strokeWidth: 8,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(_remainingSeconds < 10 ? Colors.red : Colors.green),
                      ),
                    ),
                    Text('$_remainingSeconds', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isTimerRunning ? 'توقف' : 'شروع'),
                      onPressed: () {
                        if (_isTimerRunning) {
                          _gameTimer?.cancel();
                          setState(() => _isTimerRunning = false);
                        } else {
                          _startTimer(_remainingSeconds);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.rotate_right),
                      label: const Text('+15 ثانیه چالش'),
                      onPressed: () => _startTimer(15),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      currentSpeakerIndex = (currentSpeakerIndex + 1) % alivePlayers.length;
                      _startTimer(45);
                    });
                  },
                  child: const Text('نفر بعدی ❯'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
                  onPressed: () {
                    _gameTimer?.cancel();
                    for (var p in players) {
                      p.votesReceived = 0;
                    }
                    setState(() => currentPhase = GamePhase.voting);
                  },
                  child: const Text('ورود به دادگاه ⚖️'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. VOTING VIEW
  // ---------------------------------------------------------------------------
  Widget _buildVotingView() {
    List<Player> alivePlayers = players.where((p) => p.isAlive).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('ثبت آرا برای خروج از بازی', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: alivePlayers.length,
              itemBuilder: (context, index) {
                final p = alivePlayers[index];
                return Card(
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: p.votesReceived > 0 ? () => setState(() => p.votesReceived--) : null,
                        ),

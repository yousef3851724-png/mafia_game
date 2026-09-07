import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MafiaRadicalCompleteApp());
}

class MafiaRadicalCompleteApp extends StatelessWidget {
  const MafiaRadicalCompleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مافیا رادیکال',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        primaryColor: const Color(0xFFE53935),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935),
          secondary: Color(0xFFFF5252),
          surface: Color(0xFF181822),
        ),
        cardColor: const Color(0xFF1E1E2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181822),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF14141C),
          selectedItemColor: Color(0xFFE53935),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const RootNavigationScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// GLOBAL STATE & USER PROFILE
// ---------------------------------------------------------------------------
class UserProfile {
  static String name = "امیرعلی";
  static int level = 24;
  static int coins = 14500;
  static int gems = 120;
  static int trophies = 3420;
  static int totalGames = 158;
  static int winRate = 68; // درصد
  static String rankTitle = "گرند مستر (Grandmaster)";
}

// ---------------------------------------------------------------------------
// ROOT NAVIGATION (BOTTOM BAR)
// ---------------------------------------------------------------------------
class RootNavigationScreen extends StatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  State<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends State<RootNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const LobbyListScreen(),
    const LeaderboardScreen(),
    const ShopScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'خانه'),
            BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'لابی‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'رنکینگ'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'فروشگاه'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پروفایل'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. HOME SCREEN (داشبورد اصلی)
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.local_fire_department, color: Color(0xFFE53935), size: 28),
            SizedBox(width: 8),
            Text('مافیا رادیکال', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          _buildCurrencyBadge(Icons.monetization_on, '${UserProfile.coins}', Colors.amber),
          _buildCurrencyBadge(Icons.diamond, '${UserProfile.gems}', Colors.cyanAccent),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت وضعیت کاربری
            _buildUserSummaryCard(context),
            const SizedBox(height: 20),

            // بنر ایونت / گردونه شانس
            _buildEventBanner(context),
            const SizedBox(height: 24),

            const Text('حالت‌های بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // مودهای مختلف بازی
            _buildGameModeCard(
              context,
              title: 'بازی امتیازی (Ranked)',
              subtitle: 'رقابت نفس‌گیر برای افزایش کاپ و رتبه در فصل',
              icon: Icons.military_tech,
              gradient: const [Color(0xFF8E0E00), Color(0xFF1F1C18)],
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchmakingScreen(mode: 'امتیازی (Ranked)'))),
            ),
            const SizedBox(height: 12),
            _buildGameModeCard(
              context,
              title: 'اتاق دوستانه (Custom Lobby)',
              subtitle: 'ساخت اتاق با قوانین دلخواه و دعوت دوستان با کد',
              icon: Icons.group_add,
              gradient: const [Color(0xFF1D2671), Color(0xFFC33764)],
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LobbyListScreen())),
            ),
            const SizedBox(height: 12),
            _buildGameModeCard(
              context,
              title: 'بازی دورهمی حضوری (Pass & Play)',
              subtitle: 'گرداننده خودکار برای بازی با دوستان در یک گوشی',
              icon: Icons.phonelink_setup,
              gradient: const [Color(0xFF134E5E), Color(0xFF71B280)],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ورود به بخش گرداننده حضوری...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE53935),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UserProfile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(UserProfile.rankTitle, style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              const SizedBox(height: 2),
              Text('${UserProfile.trophies}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEventBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF880E4F)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.casino, size: 48, color: Colors.amberAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('گردونه شانس روزانه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('یک چرخش رایگان برای دریافت سکه و اسکین!', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شما 500 سکه جایزه روزانه بردید! 🎉')));
            },
            child: const Text('چرخش'),
          )
        ],
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topRight, end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyBadge(IconData icon, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. LOBBY & ROOM LIST SCREEN (لابی‌ها و لیست اتاق‌ها)
// ---------------------------------------------------------------------------
class LobbyListScreen extends StatefulWidget {
  const LobbyListScreen({super.key});

  @override
  State<LobbyListScreen> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen> {
  final List<Map<String, dynamic>> _lobbies = [
    {"id": "101", "name": "اتاق حرفه‌ای‌ها (سناریو بازپرس)", "players": 8, "max": 10, "hasPassword": false, "host": "کوروش"},
    {"id": "102", "name": "مافیا شب‌های مافیا 🔥", "players": 10, "max": 12, "hasPassword": true, "host": "سارا"},
    {"id": "103", "name": "دوستانه با ویس چت 🎙️", "players": 4, "max": 8, "hasPassword": false, "host": "رضا"},
    {"id": "104", "name": "اتاق اختصاصی کلن Radical", "players": 9, "max": 10, "hasPassword": true, "host": "امید"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لیست لابی‌های فعال'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لیست اتاق‌ها بروزرسانی شد.')));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // بخش فیلتر و جستجو
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'جستجوی نام یا آیدی اتاق...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: const Color(0xFF1E1E2A),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('ساخت اتاق'),
                  onPressed: () => _showCreateRoomDialog(context),
                )
              ],
            ),
          ),
          // لیست لابی‌ها
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _lobbies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lobby = _lobbies[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181822),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE53935).withOpacity(0.2),
                        child: Icon(lobby["hasPassword"] ? Icons.lock : Icons.lock_open, color: const Color(0xFFE53935), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lobby["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('میزبان: ${lobby["host"]} | کد: #${lobby["id"]}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${lobby["players"]}/${lobby["max"]} نفر', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              minimumSize: const Size(70, 32),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WaitingRoomScreen(roomName: lobby["name"], roomId: lobby["id"]),
                                ),
                              );
                            },
                            child: const Text('ورود', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E2A),
          title: const Text('ساخت اتاق اختصاصی', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(hintText: 'نام اتاق', filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(hintText: 'رمز عبور (اختیاری)', filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: 10,
                decoration: InputDecoration(filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: [8, 10, 12].map((e) => DropdownMenuItem(value: e, child: Text('$e نفره'))).toList(),
                onChanged: (_) {},
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WaitingRoomScreen(roomName: 'اتاق جدید من', roomId: '999')));
              },
              child: const Text('ایجاد و ورود'),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. WAITING ROOM SCREEN (اتاق انتظار قبل از شروع)
// ---------------------------------------------------------------------------
class WaitingRoomScreen extends StatelessWidget {
  final String roomName;
  final String roomId;

  const WaitingRoomScreen({super.key, required this.roomName, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(roomName),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: Text('کد: #$roomId', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
            )
          ],
        ),
        body: Column(
          children: [
            // اسلات‌های بازیکنان
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isFilled = index < 6;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isFilled ? const Color(0xFF1E1E2A) : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isFilled ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isFilled ? const Color(0xFFE53935) : Colors.white12,
                          child: Icon(isFilled ? Icons.person : Icons.add, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isFilled ? (index == 0 ? '${UserProfile.name} (میزبان)' : 'بازیکن ${index + 1}') : 'جای خالی',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isFilled ? Colors.white : Colors.white38),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            // نوار اکشن شروع
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFF181822), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.greenAccent),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بازی در حال شروع است...')));
                    },
                    child: const Text('شروع بازی 🔥', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. LEADERBOARD SCREEN (رده‌بندی و لیگ‌ها)
// ---------------------------------------------------------------------------
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> topPlayers = [
      {"rank": 1, "name": "آریا گرگینه", "trophies": 5820, "winRate": "84%", "badge": "🥇"},
      {"rank": 2, "name": "نابودگر شب", "trophies": 5340, "winRate": "79%", "badge": "🥈"},
      {"rank": 3, "name": "دکتر مرموز", "trophies": 4990, "winRate": "75%", "badge": "🥉"},
      {"rank": 4, "name": "سایلنت کیلر", "trophies": 4200, "winRate": "71%", "badge": ""},
      {"rank": 5, "name": "کارآگاه زبل", "trophies": 3950, "winRate": "69%", "badge": ""},
      {"rank": 6, "name": UserProfile.name, "trophies": UserProfile.trophies, "winRate": "${UserProfile.winRate}%", "badge": "⭐"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('برترین‌های فصل (Leaderboard)')),
      body: Column(
        children: [
          // سکوی نفرات اول تا سوم
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF200122), Color(0xFF6F0000)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodiumSpot(name: topPlayers[1]["name"], score: '${topPlayers[1]["trophies"]}', place: '2', height: 90, color: Colors.grey.shade400),
                _buildPodiumSpot(name: topPlayers[0]["name"], score: '${topPlayers[0]["trophies"]}', place: '1', height: 120, color: Colors.amber),
                _buildPodiumSpot(name: topPlayers[2]["name"], score: '${topPlayers[2]["trophies"]}', place: '3', height: 75, color: Colors.brown.shade300),
              ],
            ),
          ),
          // لیست سایر نفرات
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: topPlayers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = topPlayers[index];
                final isMe = p["name"] == UserProfile.name;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFE53935).withOpacity(0.2) : const Color(0xFF1E1E2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isMe ? const Color(0xFFE53935) : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          p["badge"].isNotEmpty ? p["badge"] : '#${p["rank"]}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(radius: 18, backgroundColor: Colors.white12, child: Icon(Icons.person, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p["name"], style: TextStyle(fontWeight: FontWeight.bold, color: isMe ? Colors.redAccent : Colors.white)),
                            Text('وین‌ریت: ${p["winRate"]}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text('${p["trophies"]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPodiumSpot({required String name, required String score, required String place, required double height, required Color color}) {
    return Column(
      children: [
        CircleAvatar(radius: 24, backgroundColor: color, child: Text(place, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18))),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text('$score کاپ', style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color),
          ),
          child: Center(child: Text('#$place', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20))),
        )
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. SHOP SCREEN (فروشگاه، خرید سکه و اسکین)
// ---------------------------------------------------------------------------
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فروشگاه مافیا رادیکال 🛒')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // کارت اشتراک ویژه
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF8008), Color(0xFFFFC837)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, size: 48, color: Colors.black),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('اشتراک مافیا پلاس (Mafia Plus)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        SizedBox(height: 4),
                        Text('قاب طلایی، چت صوتی نامحدود، ضریب ۲ برابر سکه', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.amber),
                    onPressed: () {},
                    child: const Text('خرید'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('بسته‌های سکه و الماس', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildShopItem('کیسه سکه کوچک', '۵,۰۰۰ سکه', '۲۵,۰۰۰ ت', Icons.monetization_on, Colors.amber),
                _buildShopItem('صندوقچه سکه طلایی', '۲۵,۰۰۰ سکه', '۹۰,۰۰۰ ت', Icons.savings, Colors.amber),
                _buildShopItem('بسته جم الماس', '۱۵۰ الماس', '۴۵,۰۰۰ ت', Icons.diamond, Colors.cyanAccent),
                _buildShopItem('خزانه مافیا', '۱,۰۰۰ الماس', '۱۹۰,۰۰۰ ت', Icons.diamond_outlined, Colors.cyanAccent),
              ],
            ),
            const SizedBox(height: 24),

            const Text('اسکین و پشت‌کارت‌های اختصاصی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSkinItem('پشت کارت آتشین پدرخوانده', 'آیتم لجندری', '۳۰۰ الماس', Icons.style, Colors.redAccent),
                _buildSkinItem('فریم کارآگاه کلاسیک', 'آیتم اپیک', '۱۵۰ الماس', Icons.crop_portrait, Colors.blueAccent),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(String title, String amount, String price, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(amount, style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              minimumSize: const Size(double.infinity, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: Text(price, style: const TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildSkinItem(String title, String type, String price, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(type, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
            onPressed: () {},
            child: Text(price, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. PROFILE SCREEN (پروفایل و آمار)
// ---------------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل کاربری')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(radius: 46, backgroundColor: const Color(0xFFE53935), child: const Icon(Icons.person, size: 54, color: Colors.white)),
                  CircleAvatar(radius: 14, backgroundColor: Colors.amber, child: const Icon(Icons.edit, size: 16, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(UserProfile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('لول ${UserProfile.level} | ${UserProfile.rankTitle}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),

            // آمار بازی‌ها
            Row(
              children: [
                _buildStatBox('تعداد بازی‌ها', '${UserProfile.totalGames}', Icons.games),
                const SizedBox(width: 10),
                _buildStatBox('درصد پیروزی', '${UserProfile.winRate}%', Icons.trending_up),
                const SizedBox(width: 10),
                _buildStatBox('کاپ فصلی', '${UserProfile.trophies}', Icons.emoji_events),
              ],
            ),
            const SizedBox(height: 24),

            // لیست گزینه‌های تنظیمات و اکانت
            _buildProfileOption(Icons.history, 'تاریخچه بازی‌های اخیر', () {}),
            _buildProfileOption(Icons.security, 'امنیت و تغییر رمز عبور', () {}),
            _buildProfileOption(Icons.volume_up, 'تنظیمات صدا و افکت‌ها', () {}),
            _buildProfileOption(Icons.help_outline, 'قوانین و راهنمای سناریوها', () {}),
            _buildProfileOption(Icons.exit_to_app, 'خروج از حساب', () {}, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE53935), size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF181822), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. MATCHMAKING SCREEN (صفحه انتظار بازی آنلاین امتیازی)
// ---------------------------------------------------------------------------
class MatchmakingScreen extends StatefulWidget {
  final String mode;
  const MatchmakingScreen({super.key, required this.mode});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(strokeWidth: 4, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935))),
                ),
                const SizedBox(height: 32),
                Text('در حال یافتن بازیکنان برای مود ${widget.mode}...', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('زمان سپری شده: 00:${_seconds.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16, color: Colors.amber)),
                const SizedBox(height: 48),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white38)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف و بازگشت'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

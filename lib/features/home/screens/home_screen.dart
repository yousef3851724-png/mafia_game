import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/ai_player.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final List<String> _players = [];
  int _aiCount = 2;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && _players.length < 12) {
      setState(() => _players.add(name));
      _nameController.clear();
    }
  }

  void _startGame() {
    if (_players.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل ۳ بازیکن واقعی نیاز است!')),
      );
      return;
    }
    final controller = context.read<GameController>();
    controller.initializeGameWithAI(
      playerNames: _players,
      aiCount: _aiCount,
      difficulty: _aiDifficulty,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎭 بازی مافیا')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم بازیکن',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(_players[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () => setState(() => _players.removeAt(i)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // تنظیمات هوش مصنوعی
            Card(
              color: Colors.grey[850],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🤖 تعداد ربات‌ها:'),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() {
                                if (_aiCount > 0) _aiCount--;
                              }),
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$_aiCount'),
                            IconButton(
                              onPressed: () => setState(() {
                                if (_aiCount < 6) _aiCount++;
                              }),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🎯 سطح دشواری:'),
                        DropdownButton<AIDifficulty>(
                          value: _aiDifficulty,
                          dropdownColor: Colors.grey[800],
                          items: const [
                            DropdownMenuItem(
                              value: AIDifficulty.easy,
                              child: Text('آسان'),
                            ),
                            DropdownMenuItem(
                              value: AIDifficulty.medium,
                              child: Text('متوسط'),
                            ),
                            DropdownMenuItem(
                              value: AIDifficulty.hard,
                              child: Text('سخت'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _aiDifficulty = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('شروع بازی'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

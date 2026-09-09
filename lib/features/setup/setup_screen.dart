import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_models.dart';

class SetupScreen extends StatefulWidget {
  final Function(List<Player>) onStart;
  const SetupScreen({super.key, required this.onStart});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _playerNames = [];

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_playerNames.contains(name)) {
      setState(() {
        _playerNames.add(name);
        _nameController.clear();
      });
    }
  }

  void _startGame() {
    if (_playerNames.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل ۵ بازیکن برای شروع لازم است')),
      );
      return;
    }

    List<RoleType> availableRoles = [
      RoleType.godfather,
      RoleType.doctor,
      RoleType.detective,
      RoleType.sniper,
    ];
    
    // پر کردن بقیه نقش‌ها با شهروند یا مافیای ساده بر اساس تعداد
    while (availableRoles.length < _playerNames.length) {
      if (availableRoles.length % 3 == 0) {
        availableRoles.add(RoleType.simpleMafia);
      } else {
        availableRoles.add(RoleType.simpleCitizen);
      }
    }

    availableRoles.shuffle(Random());
    
    List<Player> players = [];
    for (int i = 0; i < _playerNames.length; i++) {
      players.add(Player(
        id: i.toString(),
        name: _playerNames[i],
        role: kGameRoles[availableRoles[i]]!,
      ));
    }

    widget.onStart(players);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات بازی')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'نام بازیکن'),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _playerNames.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_playerNames[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _playerNames.removeAt(index)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                child: const Text('توزیع نقش‌ها و شروع', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

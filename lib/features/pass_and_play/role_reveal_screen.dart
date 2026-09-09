import 'package:flutter/material.dart';
import '../../core/models/game_models.dart';
import '../../core/constants/app_theme.dart';

class RoleRevealScreen extends StatefulWidget {
  final List<Player> players;
  final VoidCallback onFinished;

  const RoleRevealScreen({super.key, required this.players, required this.onFinished});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  int _currentIndex = 0;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final player = widget.players[_currentIndex];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('نوبتِ:', style: TextStyle(fontSize: 18, color: Colors.white70)),
              Text(player.name, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.accentCyan)),
              const SizedBox(height: 40),
              if (!_isVisible)
                ElevatedButton(
                  onPressed: () => setState(() => _isVisible = true),
                  child: const Text('مشاهده نقش'),
                )
              else ...[
                Icon(player.role.icon, size: 80, color: player.role.color),
                const SizedBox(height: 16),
                Text(player.role.nameFa, style: TextStyle(fontSize: 28, color: player.role.color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(player.role.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < widget.players.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _isVisible = false;
                      });
                    } else {
                      widget.onFinished();
                    }
                  },
                  child: Text(_currentIndex < widget.players.length - 1 ? 'نفر بعدی' : 'شروع بازی'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

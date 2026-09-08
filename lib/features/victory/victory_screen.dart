import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_models.dart';

class VictoryScreen extends StatelessWidget {
  final Team winner;
  final List<Player> players;
  final VoidCallback onRestart;

  const VictoryScreen({super.key, required this.winner, required this.players, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final title = winner == Team.mafia ? '🎉 پیروزی مافیا' : '🛡️ پیروزی شهروندان';
    final color = winner == Team.mafia ? AppColors.primaryRed : AppColors.detectiveBlue;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: color),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 20),
            Text('بازیکنان:', style: const TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final p = players[index];
                  return ListTile(
                    leading: Icon(p.role.icon, color: p.role.color),
                    title: Text('${p.name} — ${p.role.nameFa}'),
                    subtitle: Text(p.isAlive ? 'زنده' : 'کشته'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                child: const Text('بازی جدید', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

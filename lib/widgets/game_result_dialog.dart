import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GameResultDialog extends StatelessWidget {
  final String winner;
  final int nights;
  final List<String> players;

  const GameResultDialog({
    super.key,
    required this.winner,
    required this.nights,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🏁 بازی تمام شد!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'برنده: $winner',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('🌙 تعداد شب‌ها: $nights'),
          Text('👥 تعداد بازیکنان: ${players.length}'),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Share.share(
              '🎭 بازی مافیا\n🏆 برنده: $winner\n🌙 تعداد شب‌ها: $nights\n👥 بازیکنان: ${players.join(', ')}',
              subject: 'نتیجه بازی مافیا',
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('اشتراک‌گذاری'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text('بازگشت به خانه'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class EndGameScreen extends StatelessWidget {
  final String winner; const EndGameScreen({super.key, this.winner = 'بازی به پایان رسید'});
  @override
  Widget build(BuildContext context) => RadicalScaffold(appBar: AppBar(title: const Text('پایان بازی')), padded: true, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.emoji_events_rounded, color: Color(0xFFE3B873), size: 88), const SizedBox(height: 20), Text(winner, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 12), const Text('نتیجه بازی و آمار نهایی در این صفحه مستقل نمایش داده می‌شود.'), const SizedBox(height: 28), FilledButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('بازگشت به خانه'))])));
}

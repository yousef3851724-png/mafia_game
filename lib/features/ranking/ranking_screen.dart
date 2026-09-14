import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});
  @override
  Widget build(BuildContext context) => RadicalScaffold(appBar: AppBar(title: const Text('رقابتی')), padded: true, child: ListView(children: const [Text('جدول رقابتی', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), SizedBox(height: 16), _Rank(rank: 1, name: 'رادیکال • مدیر', score: 9999), _Rank(rank: 2, name: 'بازیکن حرفه‌ای', score: 8420), _Rank(rank: 3, name: 'بازیکن تازه‌نفس', score: 7310)]));
}
class _Rank extends StatelessWidget { final int rank; final String name; final int score; const _Rank({required this.rank, required this.name, required this.score}); @override Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: Color(0xFF211D16), child: Text('$rank', style: TextStyle(color: Color(0xFFFFDFA0), fontWeight: FontWeight.w900))), title: Text(name), trailing: Text('$score', style: TextStyle(color: Color(0xFFE3B873), fontWeight: FontWeight.w900)))); }

import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class VotingScreen extends StatelessWidget {
  final List<String> players; final ValueChanged<String>? onVote;
  const VotingScreen({super.key, this.players = const [], this.onVote});
  @override
  Widget build(BuildContext context) => RadicalScaffold(appBar: AppBar(title: const Text('رأی‌گیری')), padded: true, child: ListView(children: [const Text('انتخاب بازیکن برای رأی‌گیری', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 16), ...players.map((p) => Card(child: ListTile(title: Text(p), trailing: const Icon(Icons.how_to_vote_rounded, color: Color(0xFFE3B873)), onTap: onVote == null ? null : () => onVote!(p))))]));
}

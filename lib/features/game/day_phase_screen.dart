import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class DayPhaseScreen extends StatelessWidget {
  final int round; final VoidCallback? onContinue;
  const DayPhaseScreen({super.key, this.round = 1, this.onContinue});
  @override
  Widget build(BuildContext context) => RadicalScaffold(appBar: AppBar(title: Text('روز $round')), padded: true, child: _content());
  Widget _content() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.wb_sunny_rounded, color: Color(0xFFE3B873), size: 72), const SizedBox(height: 20), Text('روز $round', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 10), const Text('بحث و تصمیم‌گیری در یک صفحه مستقل.'), if (onContinue != null) ...[const SizedBox(height: 24), FilledButton(onPressed: onContinue, child: const Text('ادامه'))]]));
}

import 'package:flutter/material.dart';
import '../../core/widgets/radical_scaffold.dart';

class NightPhaseScreen extends StatelessWidget {
  final int round;
  final VoidCallback? onContinue;
  const NightPhaseScreen({super.key, this.round = 1, this.onContinue});
  @override
  Widget build(BuildContext context) => _PhaseShell(title: 'شب $round', icon: Icons.nightlight_round, action: onContinue, actionText: 'ادامه');
}

class _PhaseShell extends StatelessWidget {
  final String title; final IconData icon; final VoidCallback? action; final String actionText;
  const _PhaseShell({required this.title, required this.icon, this.action, required this.actionText});
  @override
  Widget build(BuildContext context) => RadicalScaffold(
    appBar: AppBar(title: Text(title)),
    padded: true,
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFFE3B873), size: 72), const SizedBox(height: 20), Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 10), const Text('این فاز یک صفحه مستقل از جریان بازی است.'), if (action != null) ...[const SizedBox(height: 24), FilledButton(onPressed: action, child: Text(actionText))]])),
  );
}

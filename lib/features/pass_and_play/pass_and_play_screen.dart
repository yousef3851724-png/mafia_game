import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/radical_theme.dart';
import '../../core/models/scenario_catalog.dart';

class PassAndPlayScreen extends ConsumerStatefulWidget {
  const PassAndPlayScreen({super.key});
  @override
  ConsumerState<PassAndPlayScreen> createState() => _PassAndPlayScreenState();
}

class _PassAndPlayScreenState extends ConsumerState<PassAndPlayScreen> {
  int _playerCount = 6;
  String _scenarioId = 'classic';

  @override
  Widget build(BuildContext context) {
    final scenario = ScenarioCatalog.byId(_scenarioId);
    return Scaffold(
      appBar: AppBar(title: const Text('شروع سریع'), backgroundColor: RadicalTheme.panel),
      body: Container(
        decoration: const BoxDecoration(gradient: RadicalTheme.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: RadicalTheme.panel,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('تعداد بازیکنان: $_playerCount', style: RadicalTheme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Slider(
                      value: _playerCount.toDouble(),
                      min: 2,
                      max: 20,
                      divisions: 18,
                      label: '$_playerCount',
                      onChanged: (val) => setState(() => _playerCount = val.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: RadicalTheme.panel,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سناریو:', style: RadicalTheme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: _scenarioId,
                      isExpanded: true,
                      dropdownColor: RadicalTheme.panel3,
                      items: ScenarioCatalog.allScenarios.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayNameFa))).toList(),
                      onChanged: (val) => setState(() => _scenarioId = val ?? 'classic'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/pass-and-play/game/$_scenarioId/$_playerCount'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('شروع بازی'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: RadicalTheme.gold, foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
